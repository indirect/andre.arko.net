---
layout: post
title: "Bundler for gem development"
microblog: false
guid: http://indirect-test.micro.blog/2010/05/01/bundler-for-gem-development/
post_id: 4967471
date: 2010-05-01T00:00:00-0800
lastmod: 2010-04-30T16:00:00-0800
type: post
url: /2010/04/30/bundler-for-gem-development/
---
[Bundler](http://gembundler.com) was written to manage the gem dependencies of ruby applications, and it has gotten to the point where it is pretty good at that. What you probably don't know is that it can manage the gem dependencies of any gem that you are working on, as well.

Tools like [Jeweler](http://github.com/technicalpickles/jeweler) have attempted to help with this problem in the past. Jeweler comes with a rake task that tells you if some of your gem's dependencies aren't installed. Bundler takes this idea one step further, allowing you to install all of your gem's dependencies with a single command. This makes it very simple to check out a gem's source and start working on it right away.

------------------

**Update** While the stuff below worked in Bundler 0.9, it has been removed in 1.0. Integrating Bundler with gemspecs proved to be a fantastic idea, but the version that shipped with Bundler 0.9 had some issues. Gemspecs are executable Ruby code, and adding a dependency on the Bundler gem to your gemspec didn't work in practice, because many machines that needed to process gemspecs didn't have the right version of Bundler already installed.

Replacing `Gem::Specification#add_bundler_dependencies` is the `gemspec` method for your Gemfile. You can use it like this:

    source :rubygems
    gemspec

For more information about the `gemspec` method and managing your gems with Bundler, please see the official docs, written by myself and the incomparable Josh Hull over on [the official Bundler documentation site](http://gembundler.com/rubygems.html).

------------------

Specifying your gem's dependencies is simple: just like any other bundler project, you create a [Gemfile](http://gembundler.com/gemfile.html). That file is some ruby code declaring the other gems that you gem needs to have installed in order to run. It will look something like this:

    source :rubyforge
    gem "json"

    group :development do
      gem "rspec"
    end

Once you have a Gemfile, you just add a couple of lines to your gemspec. Require the bundler library at the top, and then call the `add_bundler_dependencies` method on your gemspec object. In the simplest form, it looks like this:

    require 'bundler'
    Gem::Specification.new do |s|
      s.add_bundler_dependencies
    end

Once you've done that, all the gems in your gemfile that are in the default group will be added to your gem as dependencies. If you specify version requirements in the Gemfile, they will be reflected in the built gemspec. If you have gems that are only needed for development of your gem, put them in a group named :development and they will be added to your gemspec as development dependencies. Lastly, if you have gems that you want bundler to install, but not list inside the gemspec, put them in a group named anything besides :development.

At this point, what I usually do is add the standard bundler snippet to the top of my spec_helper.rb file so that i can run my specs without bundle exec:

    require 'rubygems'
    require 'bundler'
    Bundler.setup

That's really all you need to use bundler while you develop a gem. If you have any questions, feel free to email, tweet, or ask me in #bundler on freenode.
