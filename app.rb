require 'sinatra'
require 'haml'
require 'redcarpet'
require 'yaml'
require 'fileutils'
require 'cal'


module Cal
  class Month
    def to_s
      date.strftime "%b"
    end
  end

  class Day

    def words
      Words.from_date(date)
    end

    # @return True if this day is _actually_ in the month, false otherwise.
    def over?
      date.month != calendar.month.number
    end

    def future?
      date > Date.today
    end

    def passed?
      words.words >= Settings.target
    end

    def missed?
      words.words == 0
    end

    def classes
      return "over"   if over?
      return "today"  if today?
      return "over"   if future?
      return "passed" if passed?
      return "missed" if missed?
    end
  end
end

class Settings
  FILE = File.expand_path('~/.words.yml')

  def self.load
    unless File.exist?(FILE)
      File.open(FILE, 'w') do |f|
        f.puts <<EOS
location: #{File.expand_path('~/Words')}
target: 750
font: 23px/1.5em Helvetica, sans-serif
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
  def self.calendars
    oldest = self.list[0].date

    (oldest..Date.today).to_a.map {|date|
      [date.year, date.month]
    }.uniq.map {|y,m|
      Cal::MonthlyCalendar.new(y, m, :start_week_on => :monday)
    }.group_by {|cal|
      cal.year
    }
  end

  def self.list
    Dir["#{Settings.location}/*.txt"].map {|w| Words.new(w) }.sort_by(&:date)
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
    dir = File.dirname(@location)
    unless File.exist?(dir)
      FileUtils.mkdir(dir)
    end
    File.open(@location, 'w') {|f| f.write(text) }
  end

  def date
    @location =~ /(\d{4})-(\d{2})-(\d{2})/
    Date.new($1.to_i, $2.to_i, $3.to_i)
  end

  def words
    read.gsub(/(^\s*)|(\s*$)/i, '')
      .gsub(/\n/i, ' ')
      .gsub(/[ ]{2,}/i, ' ')
      .split(' ')
      .size
  rescue
    warn "Error reading: #{@location}"
    0
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

  def url
    if date.today?
      "/"
    else
      "/#{date.to_s}"
    end
  end

  def data
    {
      :date  => date,
      :raw   => read,
      :text  => rendered,
      :url   => url,
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

post '/save' do
  text = params[:text]
  file = Words.today
  file.write text
  true
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
  t = File.read(File.join(settings.public_folder.to_s, 'styles.css'))
  t.gsub('@@FONT@@', Settings.font)
end

get %r{/(\d{4}-\d{2}-\d{2})} do |date|
  date = Date.parse(date)
  @words = Words.from_date(date).data
  @next  = Words.from_date(date.next_day).data
  @prev  = Words.from_date(date.prev_day).data

  haml :show
end
