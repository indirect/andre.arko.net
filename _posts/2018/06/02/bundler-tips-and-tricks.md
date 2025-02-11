---
layout: post
title: "Bundler Tips and Tricks"
microblog: false
guid: http://indirect-test.micro.blog/2018/06/03/bundler-tips-and-tricks/
post_id: 4971629
date: 2018-06-03T00:00:00-0800
lastmod: 2018-06-02T16:00:00-0800
type: post
url: /2018/06/02/bundler-tips-and-tricks/
---
<small>This post was originally [a guest episode of Ruby Tapas](https://www.rubytapas.com/2018/03/27/bundler-tips-and-tricks-andre-arko/), a series of regular, short screencasts about Ruby topics. If that sounds good to you, [try out Ruby Tapas](https://www.rubytapas.com).</small>

As a Ruby developer, chances are really good that you already know and use [Bundler](https://bundler.io) on a daily basis, and you can `git pull && bundle install` with the best of them. What you might not know is that Bundler has changed and grown over the last 8 years. The newer, lesser-known features can provide a lot of help with other gem-related workflows and problems. What other problems, you ask? Let’s take a look.

### Creating and releasing your own gems

The first thing Bundler can help with is making your own gems. It’s as easy as `bundle gem foobar`, and you end up with a new gem named `foobar` ready for you to add code.

There’s a one-time setup to tell Bundler if you want [rspec](http://rspec.info) or minitest, an [MIT license](https://github.com/bundler/bundler/blob/master/lib/bundler/templates/newgem/LICENSE.txt.tt), or a [code of conduct](https://github.com/bundler/bundler/blob/master/lib/bundler/templates/newgem/CODE_OF_CONDUCT.md.tt). After that, you can create gem after gem in just a few seconds each.

    $ bundle gem foobar
    Creating gem 'foobar'...
    Do you want to generate tests with your gem?
    Type 'rspec' or 'minitest' to generate those test files now and in the future. rspec/minitest/(none): rspec
    Do you want to license your code permissively under the MIT license?
    This means that any other developer or company will be legally allowed to use your code for free as long as they admit you created it. You can read more about the MIT license at http://choosealicense.com/licenses/mit. y/(n): y
    MIT License enabled in config
    Do you want to include a code of conduct in gems you generate?
    Codes of conduct can increase contributions to your project by contributors who prefer collaborative, safe spaces. You can read more about the code of conduct at contributor-covenant.org. Having a code of conduct means agreeing to the responsibility of enforcing it, so be sure that you are prepared to do that. Be sure that your email address is specified as a contact in the generated code of conduct so that people know who to contact in case of a violation. For suggestions about how to enforce codes of conduct, see http://bit.ly/coc-enforcement. y/(n): y
    Code of conduct enabled in config
          create  foobar/Gemfile
          create  foobar/lib/foobar.rb
          create  foobar/lib/foobar/version.rb
          create  foobar/foobar.gemspec
          create  foobar/Rakefile
          create  foobar/README.md
          create  foobar/bin/console
          create  foobar/bin/setup
          create  foobar/.gitignore
          create  foobar/.travis.yml
          create  foobar/.rspec
          create  foobar/spec/spec_helper.rb
          create  foobar/spec/foobar_spec.rb
          create  foobar/LICENSE.txt
          create  foobar/CODE_OF_CONDUCT.md
    Initializing git repo in /Users/andre/Downloads/foobar

Any gem created by Bundler comes with a couple of nice touches: first, a `bin/setup` file that acts as a centralized, well-known location to install dependencies and do any other specific setup needed to develop on your library. By default, it creates a bash script that echoes commands, and runs `bundle install`, but it’s very easy to add your own commands.

    $ cd foobar
    $ cat bin/setup
    #!/usr/bin/env bash
    set -euo pipefail
    IFS=$'\n\t'
    set -vx

    bundle install

    # Do any other automated setup that you need to do here

Every gem also includes a `bin/console`, to load your gems and then launch [IRB](https://ruby-doc.org/stdlib-2.5.1/libdoc/irb/rdoc/IRB.html), [Pry](http://pryrepl.org/), [Fir](https://github.com/dnasseri/fir), or whatever interactive prompt you prefer. It’s the fastest way to experiment with the code from your gem.

    $ cat bin/console
    #!/usr/bin/env ruby

    require "bundler/setup"
    require "foobar"

    # You can add fixtures and/or initialization code here to make experimenting
    # with your gem easier. You can also use a different console, if you like.

    # (If you use this, don't forget to add pry to your Gemfile!)
    # require "pry"
    # Pry.start

    require "irb"
    IRB.start(__FILE__)

Finally, every gem includes two extremely helpful [rake](https://ruby.github.io/rake/) tasks. The `rake install` will build your gem into a literal `.gem` file, and then run `gem install` to install it onto your local machine.

    $ rake install
    foobar 0.1.0 built to pkg/foobar-0.1.0.gem.
    foobar (0.1.0) installed.
    $ gem list foobar

    *** LOCAL GEMS ***

    foobar (0.1.0)

You can easily test that building, installing, and using your gem all work the way that you expect them to.

    $ ruby -rfoobar -e 'puts Foobar::VERSION'
    0.1.0

The other extremely useful task is `rake release`, which creates and pushes a git tag for your version, builds a `.gem` file, and releases the gem on [RubyGems.org](https://rubygems.org/)! What used to be an error-prone process that could take minutes is now just a single command and a few seconds. It’s marvelous.

    $ rake release
    foobar 0.1.0 built to pkg/foobar-0.1.0.gem.
    Tagged v0.1.0.
    Pushed git commits and tags.
    Pushed foobar 0.1.0 to rubygems.org

### Developing multiple repos at once

Now that you have a gem, what if you need to make changes to the gem and your app that depends on it at the same time? Bundler already has a feature to make this work as smoothly as possible: **Local Git Repos**.

To start, you tell Bundler where your local checkout of a git repo is. For example, we could continue to work on our `foobar` gem locally while using it in an application by running this configuration command in the application. Now that we’ve done that, running the application locally will use the code from our checkout. We can make changes, reload the application, and see them live.

    $ cd app
    $ bundle config local.foobar ~/src/indirect/foobar
    $ bundle exec ruby -rfoobar -e 'puts Foobar::VERSION'
    0.1.0

### Adding gems

Now that we're up to speed on creating and using our own gems, the next tip is about speeding up using gems that already exist. Starting with Bundler 1.15, there is an `add` command that will automatically add a gem to your Gemfile and install it.

Given a gem name, Bundler will look up the gem by name, add it to your Gemfile, and then resolve and install your entire bundle.

Adding new gems to your application got easier starting with Bundler 1.15–now, you can simply run `bundle add GEM` and watch as Bundler adds the gem.

    $ bundle add rack
    Fetching gem metadata from https://rubygems.org/..............
    Resolving dependencies...
    Fetching gem metadata from https://rubygems.org/..............
    Resolving dependencies...
    Using bundler 1.16.1
    Fetching rack 2.0.4
    Installing rack 2.0.4

Now that the command has run, we can take a look inside the Gemfile using `cat` to see the changes that Bundler made.

    $ cat Gemfile
    source "https://rubygems.org"

    gem "rack", "~> 2.0"

Adding gems is pretty basic so far, but we’re continuing to improve gem management from the command-line. Watch for this to keep getting better.

### Editing installed gems

After we've installed all of our gems, it's a common wish to want to see the code for a gem directly. Bundler makes it easy to open any installed gem directly in your editor so you can see (or even edit) that gem's code.

When you run `bundle open GEM`, Bundler will look up the location of that gem on your machine, and then open it in your editor.

    $ bundle open rack

The default editor is Vim, but Bundler will respect the `EDITOR` variable to open any editor you want.

Once you've got the gem open in your editor, you can browse the source for the gem, search for the definition of a method, and even edit that gem to change behavior or add debugging code. In this example, we're editing the the rack gem's main file, `rack.rb`. To show how this works, we'll change the `VERSION` constant.

Any changes that you make will be picked up by the next Ruby process you run. We can see the effect of our changes by printing the VERSION constant that we just edited.

    $ bundle exec ruby -rrack -e 'p Rack::VERSION'
    [5,0]

As you can probably imagine, being able to change your gems locally is an incredibly valuable tool for the times when it seems like the bug might be in a gem rather than in your own code.

### Searching gems

If you’re not yet sure which gem to open, you can do a search across exactly the gems in this particular application by using the slightly-obscure command `bundle show --paths`. Combine that command with grep, [ack](https://beyondgrep.com), [ripgrep](https://github.com/BurntSushi/ripgrep), or your favorite search tool to get extremely precise results.

In this example, we're using the [Rails app that powers RubyGems.org](https://github.com/rubygems/rubygems.org). Running `bundle show --paths` will print out the list of directories, one for each gem used by the application.

    $ bundle show --paths
    /Users/andre/src/rubygems/rubygems.org/.bundle/ruby/2.3.0/gems/actioncable-5.0.3
    /Users/andre/src/rubygems/rubygems.org/.bundle/ruby/2.3.0/gems/actionmailer-5.0.3
    /Users/andre/src/rubygems/rubygems.org/.bundle/ruby/2.3.0/gems/actionpack-5.0.3
    /Users/andre/src/rubygems/rubygems.org/.bundle/ruby/2.3.0/gems/actionview-5.0.3
    /Users/andre/src/rubygems/rubygems.org/.bundle/ruby/2.3.0/gems/activejob-5.0.3
    /Users/andre/src/rubygems/rubygems.org/.bundle/ruby/2.3.0/gems/activemodel-5.0.3
    /Users/andre/src/rubygems/rubygems.org/.bundle/ruby/2.3.0/gems/activerecord-5.0.3
    /Users/andre/src/rubygems/rubygems.org/.bundle/ruby/2.3.0/gems/activesupport-5.0.3
    [...]

Once we have that list of paths, we can combine it with a search tool. In this example, we're using `rg`, which is the `ripgrep` tool. Ripgrep is a search tool similar to `grep`, but optimized for source code. Finding places in our gems where the method `create_or_update` is defined is suddenly a breeze once we have Bundler and Ripgrep working together.

    $ rg 'def create_or_update' $(bundle show --paths)
    /Users/andre/.gem/ruby/2.3.3/gems/bundler-1.14.6/lib/gems/bundler-1.14.6: No such file or directory (os error 2)
    /Users/andre/src/rubygems/rubygems.org/.bundle/ruby/2.3.0/gems/activerecord-5.0.3/lib/active_record/callbacks.rb
    297:    def create_or_update(*) #:nodoc:

    /Users/andre/src/rubygems/rubygems.org/.bundle/ruby/2.3.0/gems/activerecord-5.0.3/lib/active_record/persistence.rb
    546:    def create_or_update(*args, &block)

### bundler/inline for single-file scripts

We're starting to run out of time, but before we wrap up I want to highlight one more feature that offers developers a very powerful tool. Every tip so far has been about managing gems for an application. What about the times when an application is overkill, and you just want to write a few lines of code into a single file?

Ruby was originally created for that kind of small, helpful script, and makes it very easy… until your small script starts depending on gems. Then you have to think about installing them, making sure the right version is available, and all the other thing that Bundler was invented to help with. If you have a small script that could use some gems, Bundler can help with that as well. This feature is called ‘inline Gemfiles', and it gives your single-file scripts superpowers.

At the top of your script, require `bundler/inline`. Then, use the `gemfile` method to declare your dependencies just like you would in a standalone file. When you run the script, Bundler will jump in and make sure the gems you need are installed and loaded, and your script will always be able to run successfully.

    $ vim script.rb

    require "bundler/inline"

    gemfile do
      source "https://rubygems.org"
      gem "rack-obama"
    end

    puts "rack-obama's version is: #{Rack::Obama::VERSION}"

Once we've created a script that uses inline Gemfiles, just running it means Bundler will take care of everything else. Any missing gems are automatically installed, all installed gems are automatically used, and you never have to think about it. As you can see, we do not currently have the `rack-obama` gem installed on this machine.

    $ gem list rack-obama

    *** LOCAL GEMS ***

Under normal circumstances, our script would fail with an error about a missing constant. Bundler is going to silently install our missing gem as part of running our script. Take a look:

    $ ruby script.rb
    rack-obama's version is: 0.1.1

Bundler made the script's dependencies work, completely automatically! If we check on installed gems again, we can see that Bundler installed the gems we needed exactly as if we had run `gem install` ourselves:

    $ gem list rack-obama

    *** LOCAL GEMS ***

    rack-obama (0.1.1)

With that, it’s time to wrap things up! If you’re interested in the latest developments (ha) in Bundler, check out the Bundler blog at [bundler.io/blog](http://bundler.io/blog/), or follow us on [twitter](https://twitter.com/bundlerio) at [@bundlerio](https://twitter.com/bundlerio). We post and tweet about what changed anytime there’s a new release.

If you want to support development work and maintenance on [Bundler](https://bundler.io), [RubyGems](https://github.com/rubygems/rubygems), and [RubyGems.org](https://rubygems.org/), check out [Ruby Together](https://rubytogether.org/) and follow us at [@rubytogether](https://twitter.com/rubytogether).
