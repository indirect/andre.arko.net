---
title: "Rails in 0.5 seconds"
layout: post
---
You too can boot a Rails app in as little as 500ms! Here's how, using lazy require statements and not loading Bundler or Rubygems at runtime.

🏃💨💫💞

A couple of weeks ago, I had a great conversation with a Ruby developer in Paris, and we talked about the things we liked and didn't like about Ruby and Rails when compared to other options. He had just tried Node.js and Python for the first time, and was very excited about how fast everything was in development. It surprised me that he thought all Ruby projects were slow, and as I asked him more about what he meant, it became clear that he had never used Ruby without a Rails app, a huge Gemfile, and a 5-10 second boot time before being able to do anything at all.

To me, the saddest part of this is that Ruby is really fast! The Ruby interpreter only takes about 35ms to start up. It's entirely possible to have scripts or even test suites that run so quickly that they seem instant. Knowing that Ruby itself was already quite fast, I decided to see just how quickly Rails could load and provide a running application.

Getting a Rails 4 app booting without Bundler or Rubygems requires a few changes to the way things load, and a shim that pretends to be Rubygems so that parts of Rails that expect Rubygems to be there won't throw exceptions. Let's start with a new Rails 4.1.1 application:

```bash
$ rails new fast-rails --skip-bundle --skip-spring
      create
[...]
$ cd fast-rails
```

Let's get a baseline, so we know how long it takes to boot our Rails environment, and we know how much of a difference our changes make:

```bash
$ time bin/rails runner '0'
real	0m1.066s
```

Now that we have a baseline, let's set up our hard-coded replacement for all the work that Bundler and Rubygems do at runtime. Bundler includes a little-known feature called standalone mode. This mode creates a Ruby file that simply adds each gem from your bundle to the `$LOAD_PATH`. Let's start there.

```bash
$ bundle install --standalone --path .bundle --jobs 0
Fetching gem metadata from https://rubygems.org/.........
[...]
Your bundle is complete!
It was installed into ./.bundle
```

If you'd like to see the contents of the standalone file, you can look at `.bundle/bundler/setup.rb`. That's the file that we're going to use to set up the app environment, instead of having Bundler do it every time the app starts up.

This approach comes with a _big_ disadvantage, though: Bundler doesn't set up the app environment every time the app starts up. That means that any change to your `Gemfile` requires running `bundle install --standalone --path .bundle --jobs 0` again after the change, to write out a new standalone file that honors those changes.

This is similar to the approach the Bundler team took in Bundler version 0.9, but it caused a lot of confusion when changes to the Gemfile didn't take effect until after another `bundle install`. So keep that in mind if you decide to do this! I recommend creating a bootstrapping script that you can run to make sure the application is ready to go. I called mine `bin/setup`.

```bash
#!/bin/bash
gem list -i bundler > /dev/null || gem install bundler
bundle install --standalone --path .bundle --jobs 0
bin/rake db:create db:schema:load db:seed
```

If your application has other requirements, you could potentially install them using that script as well. Just remember that you need to re-run `bundle install --standalone` every time you change your Gemfile!

Now that we have a standalone bundle, we need to tell Rails how to load it instead of using Rubygems. We can do that using `config/boot.rb`.

```ruby
# config/boot.rb
require_relative "../.bundle/bundler/setup"
require_relative "rubygems_shim"
```

Next step (you probably guessed it already) is `config/rubygems_shim.rb`. It's the absolute minimum set of Rubygems constants and methods that mean that Rails will function. Using this shim instead of Rubygems removes one specific thing from Rails: the version of your database adapter will not be checked by ActiveRecord. Make sure you have the latest compatible version!

When I first figured out how to do this, I was using Ruby 2.1.1. About halfway through, I decided that I should upgrade to Ruby 2.1.2, and I discovered a very sad thing: the version of RDoc that ships with Ruby 2.1.2 has a file, `rdoc/tasks.rb`, that actually has the statement `require "rubygems"` inside it. The only way to work around it was to monkeypatch require, and block Rubygems from loading. This is a terrible idea, and honestly I don't recommend that anyone do it. I couldn't figure out how to make this work on Ruby 2.1.2 without it, though, so it's here in the shim. 

```ruby
# config/rubygems_shim.rb
if defined?(Gem)
  STDERR.puts "Running without Rubygems, but Rubygems is already loaded!"
else
  module Gem
    # ActiveRecord requires Gem::LoadError to load
    class LoadError < ::LoadError; end

    # BacktraceCleaner wants path and default_dir
    def self.path; []; end
    def self.default_dir
      @default_dir ||= File.expand_path("../../.bundle/#{RUBY_ENGINE}/#{RbConfig::CONFIG["ruby_version"]}", __FILE__)
    end

    # irb/locale.rb calls this if defined?(Gem)
    def self.try_activate(*); end
  end

  module Kernel
    # ActiveSupport requires Kernel.gem to load
    def gem(*); end
    # rdoc/task.rb in Ruby 2.1.2 requires rubygems itself :(
    alias_method :require, :orig_require
    def require(*args); args.first == "rubygems" || orig_require(*args); end
  end
end
```

Next, we need to stop calling the `Bundler.require` method, which is how Rails automatically requires every gem that is listed in `Gemfile`. From here on out, we'll have to require everything that we use ourselves, by hand. The upside to this additional work is that we can wait to load things until we need them. If we only need to load part of our application (for example, to test a specific thing), we won't have to load anything else. Edit the `config/application.rb` file, and delete the line `Bundler.require(*Rails.groups)`.

Last, we need to stop loading Rubygems whenever we run Ruby. The easiest way to do that, at least if you're on OS X, is by editing `bin/rails` and `bin/rake`. Change the first line of each file from `#!/usr/bin/env ruby` to `#!/usr/bin/env ruby --disable-gems`.

If everything went as expected, you're now able to boot your Rails application in less than a second:

```bash
$ time bin/rails runner '0'
real    0m0.728s
```

Cutting out Bundler and Rubygems has saved us about 300ms so far, but it's done something else much more important: it's removed `Bundler.require`. Now simply adding gems to your Gemfile won't increase the amount of time that your application takes to load. As long as you put your `require` statements in strategicly lazy places, you'll be able to keep the base loading time for your app down extremely low. Being able to start a console, server, or Rake task in less than a second is pretty amazing.

If you plan to write tests for your Rails app (and you do, right?), I highly recommend using the brand-new RSpec 3.0. The rspec-rails gem creates two helpers, `spec_helper.rb` and `rails_helper.rb`. RSpec automatically requires `spec_helper`, but lets you only require `rails_helper` inside tests for your models or controllers. That way, you can run Rails tests with less than a second of waiting for Rails to load, but you can run tests on regular Ruby classes with only 50ms of waiting for RSpec to load! After a week like this, I want all my projects to be this fast and responsive while I work on them.

In order to make the `rspec` command work without loading Bundler or Rubygems, you'll need to create a binstub that knows exactly where the rspec gem's command is located. If you don't have a binstub for a command, you can `bundle exec gem_command` exactly like you normally would, and everything will still work. It'll just be a little bit slower. Here's a `bin/rspec` file that will load RSpec without Bundler or Rubygems.

```ruby
#!/usr/bin/env ruby --disable-gems
require_relative '../config/boot'
load Dir[File.join(Gem.default_dir, "gems/rspec-core-*/exe/rspec")].first
```

"That's cool, but hang on!", I can hear you saying. "Where is the 500ms Rails application I was promised?". To get that, we need to do a little bit of creative surgery on the application, cutting out more things that are expensive to load. We're going to remove two lines from `config/application.rb`:

```ruby
require "action_mailer/railtie"
require "sprockets/railtie"
```

Building an API service in Rails that returns JSON means that I don't need ActionMailer or Sprockets. If you do, you'll either need to figure out how to load those frameworks lazily, when you need to send mail or generate assets, or just bite the bullet and load your Rails app in 700ms instead of 500. At last, loading Rails (including ActiveRecord, ActionController, and ActionView) takes less than 500ms:

```bash
$ time bin/rails runner '0'
real    0m0.498s
```

🎉🎊🌟
