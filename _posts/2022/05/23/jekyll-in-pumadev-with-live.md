---
layout: post
title: "Jekyll in puma-dev with live reload"
microblog: false
guid: http://indirect-test.micro.blog/2022/05/24/jekyll-in-pumadev-with-live/
post_id: 4971985
date: 2022-05-24T00:00:00-0800
lastmod: 2022-05-23T16:00:00-0800
type: post
url: /2022/05/23/jekyll-in-pumadev-with-live/
---
It isn't a secret (and probably not even interesting) that this blog has used [Jekyll](https://jekyllrb.com) for many years. Almost as many years ago, I discovered [puma-dev](https://github.com/puma/puma-dev) and used it to set up all of the Rails and Sinatra apps that I work on. I don’t have to start or stop any local development servers, I just browse to `appname.local`, and a Puma worker will start up and let me see the app. It even handles SSL, which is very handy.

Ever since I set up puma-dev for the apps I work on, it has annoyed me that I can’t do that for my blog. Instead, Jekyll requires me to actively start a server to see a local preview, and if I close that terminal window I’m just out of luck.

I believe it was originally written to let you host your Jekyll blog on Heroku without a build step, but the [`rack-jekyll` gem](https://github.com/adaoraul/rack-jekyll) turns out to be exactly what I wanted: I can open https://blog.test and see a freshly-rendered copy of my blog. The trick is setting up a `config.ru` for Puma to use:

	require "bundler/setup"
	require "rack/jekyll"
	run Rack::Jekyll.new(auto: true, future: true)

Once you have that file, run `bundle add rack-jekyll; bundle add puma; puma-dev link blog`, and you’re off to the races.

Okay, great, I hear you saying, but what about the live reload you promised? That turns out to be a little bit trickier. I wound up having to write a Jekyll plugin to run the livereload server. But it works! Here’s the setup:

1. Run `bundle add rack-livereload`.
2. Download <a href="https://andre.arko.net/2022/05/24/jekyll-in-puma-dev-with-live-reload/live_reload_server.rb">`live_reload_server.rb`</a> and copy it into `_plugins`. You might have to `mkdir _plugins` first.
3. Update your `config.ru` file to include `rack-livereload` and the Jekyll plugin:
		require "bundler/setup"
		require "rack/jekyll"
		require "rack-livereload"
		
		require_relative "_plugins/live_reload_server"
		Jekyll::LiveReloadServer.start!
		
		use Rack::LiveReload
		run Rack::Jekyll.new(auto: true, future: true)
4. Restart Puma by running `touch tmp/restart.txt`.
5. Reload your Jekyll site in your browser.
6. Edit your markdown files and luxuriate in the bliss of watching them reload automatically in your browser as you save.
