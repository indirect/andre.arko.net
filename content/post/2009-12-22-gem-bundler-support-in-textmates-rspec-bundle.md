---
date: "2009-12-22T00:00:00Z"
title: Gem bundler support in TextMate's RSpec bundle
---
For the last couple of weeks, I've been working with Merb and Rails 3 apps that use the [gem bundler](http://github.com/wycats/bundler). To my dismay, Textmate's RSpec bundle doesn't know how to run specs in bundled apps. The bundler doesn't come with a way to automatically load its environment yet, so I resorted to a hacky check for a Gemfile. It's working perfectly for me, though, in both Merb and Rails 3 apps.

So if you're using the gem bundler, I suggest installing [Bundled RSpec.tmbundle](http://github.com/indirect/rspec-tmbundle).