# words

I've been using [750words.com][750] for the past month or so, but found 
myself not really needing it. What I wanted was something that could work
offline (since this was when I tended to be wanting to write). 

I'd ended up writing text files in a folder on my Desktop, but this I
started missing the web app; the ability to look back over previous
entries without resorting to opening 20 TextEdit windows. So I created
this.

You'll need Ruby installed, and these instructions assume you have [pow][pw]
installed.

``` bash
$ git clone https://github.com/hawx/words.git
$ cd words
$ cd ~/.pow
$ ln -s /path/to/words
$ cd -
```

You can now open words by visiting `http://words.dev/` in a web browser.

By default it will store your words in `~/Words`, to change this go to
`http://words.dev/settings` and change "Words location" to the folder you
want to use. You can also change the word target here from the default 750.

[750]: 750words.com
[pw]:  pow.cx