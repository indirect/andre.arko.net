---
title: Haml-rails gem for Haml with Rails 3
layout: post
---
I'm setting up a new Rails 3 app, and I discovered that the [rspec-rails](http://github.com/rspec/rspec-rails) plugin is a very well-behaved Rails 3 gem plugin. All you have to do is add it to your Gemfile, and then (via a Railtie) it adds RSpec rake tasks, adds some RSpec generators, and replaces Test/Unit as the testing framework for anything newly generated.

[Haml](http://haml-lang.com), on the other hand, has zero Rails 3 integration. It doesn't even come with generators, so the current generators have been living in my [rails3-generators](http://github.com/indirect/rails3-generators) gem. However, that gem was supposed to just be a stopgap measure while plugin authors got around to integrating with Rails3 themselves.

Since Haml doesn't seem to have gotten around to integrating with Rails3, I just did it myself: presenting [haml-rails](http://gemcutter.org/gems/haml-rails), the gem that not only adds Haml generators, but hooks into Rails to replace ERB with Haml automatically. No configuration required.

The source is [on github](http://github.com/indirect/haml-rails) if you want to check it out.

Installation is pretty complicated, but I'm sure you can get the hang of it:

    # Gemfile
    gem "haml-rails"

Enjoy!
