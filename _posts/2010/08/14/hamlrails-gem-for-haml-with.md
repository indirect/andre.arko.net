---
layout: post
title: "Haml-rails gem for Haml with Rails 3"
microblog: false
guid: http://indirect-test.micro.blog/2010/08/15/hamlrails-gem-for-haml-with/
post_id: 4971343
date: 2010-08-15T00:00:00-0800
lastmod: 2010-08-14T16:00:00-0800
type: post
url: /2010/08/14/hamlrails-gem-for-haml-with/
---
I'm setting up a new Rails 3 app, and I discovered that the [rspec-rails](http://github.com/rspec/rspec-rails) plugin is a very well-behaved Rails 3 gem plugin. All you have to do is add it to your Gemfile, and then (via a Railtie) it adds RSpec rake tasks, adds some RSpec generators, and replaces Test/Unit as the testing framework for anything newly generated.

[Haml](http://haml-lang.com), on the other hand, does not integrate with the new features that Rails 3 provides. You need to run `haml --rails .` to generate an initializer yourself, and it doesn't come with any generators. The current haml generators had been living in my [rails3-generators](http://github.com/indirect/rails3-generators) gem, but that repo was just supposed to be a stopgap measure while plugin authors got around to integrating with Rails3 themselves.

Since Haml doesn't seem to have gotten around to integrating with Rails 3, I just did it myself: presenting [haml-rails](http://gemcutter.org/gems/haml-rails), the gem that not only adds Haml generators, but hooks into Rails to activate Haml and replace ERB with Haml automatically. No configuration required.

The source is [on github](http://github.com/indirect/haml-rails) if you want to check it out.

Installation is pretty complicated, but I'm sure you can get the hang of it:

    {{< highlight ruby >}}
    # Gemfile
    gem "haml-rails"
    {{< / highlight >}}

Enjoy!
