require 'sinatra'
require 'haml'
require 'redcarpet'
require 'yaml'
require 'fileutils'


class Settings
  FILE = 'settings.yml'

  def self.load
    unless File.exist?(FILE)
      File.open(FILE, 'w') do |f|
        f.puts <<EOS
location: #{File.expand_path('~/Words')}
target: 750
EOS
      end
    end

    YAML.load File.read(FILE)
  end

  def self.font
    load['font']
  end

  def self.location
    load['location']
  end

  def self.target
    load['target']
  end

  def self.write(params)
    if params['location'] != Settings.location
      params['location'] = File.expand_path(params['location'])
      FileUtils.cp_r Settings.location, params['location']
    end

    params['target'] = params['target'].to_i

    File.open(FILE, 'w') do |f|
      f.write params.to_yaml
    end
  end
end

class Words
  def self.list
    Dir["#{Settings.location}/*.txt"].map {|w| Words.new(w) }
  end

  def self.today
    from_date Date.today
  end

  def self.from_date(date)
    new "#{Settings.location}/#{date.to_s}.txt"
  end

  def initialize(loc)
    @location = loc
  end

  def exist?
    File.exist? @location
  end

  def read
    exist? ? File.read(@location) : ""
  end

  def write(text)
    File.open(@location, 'w') {|f| f.write(text) }
  end

  def date
    @location =~ /(\d{4})-(\d{2})-(\d{2})/
    Date.new($1.to_i, $2.to_i, $3.to_i)
  end

  def words
    read.gsub(/(^\s*)|(\s*$)/i, '').
         gsub(/\n/i, ' ').
         gsub(/[ ]{2,}/i, ' ').
         split(' ').
         size
  end

  def word_str
    if words == 1
      "1 word"
    else
      words.to_s + ' words'
    end
  end

  def rendered
    Redcarpet::Markdown.new(
      Redcarpet::Render::HTML,
      :fenced_code_blocks => true
    ).render(read)
  end

  def data
    {
      :date  => date,
      :raw   => read,
      :text  => rendered,
      :url   => "/#{date.to_s}",
      :words => words,
      :word_str => word_str
    }
  end

end

get '/' do
  date = Date.today
  @words = Words.from_date(date).data
  @next  = Words.from_date(date.next_day).data
  @prev  = Words.from_date(date.prev_day).data

  @target = Settings.target

  haml :index
end

get '/settings' do
  @settings = Settings.load
  haml :settings
end

post '/settings' do
  Settings.write params
  redirect '/settings'
end

get '/list' do
  @words = Words.list.map(&:data)
  haml :list
end


get '/style.css' do
  content_type 'text/css'
  File.read(File.join(settings.public_folder, 'styles.css'))
    .gsub('@@FONT@@', Settings.font)
end


get %r{/(\d{4}-\d{2}-\d{2})} do |date|
  date = Date.parse(date)
  @words = Words.from_date(date).data
  @next  = Words.from_date(date.next_day).data
  @prev  = Words.from_date(date.prev_day).data

  haml :show
end

post '/save' do
  text = params[:text]
  file = Words.today
  file.write text
  true
end
