---
title: "Never `bundle exec` again"
layout: post
---
If you work with a lot of Ruby and/or Rails codebases, you probably spend a significant amount of time using `bundle exec` to run commands. Over the years, I've spent a lot of time explaining why `bundle exec` exists, what it does, and how to avoid it. I'm writing this post now in hopes that it will spread across the Ruby community, and over time hopefully everyone will know the answers to those questions.

### Why does `bundle exec` exist?

The `bundle exec` command is needed to tell your computer when you want to run a command using a gem from the current application's Gemfile.

When you `gem install`, it puts the gem in a ruby-wide location. When you `bundle install`, the gem is just for that codebase. That means running `rake` will get you the newest rake version installed with `gem install`, while `bundle exec rake` will get you the rake from your Gemfile.

If you don't use `bundle exec`, you might happen to get exactly the same version from your Gemfile, and not even notice. You might happen to get a version close enough that everything still works. Sometimes, however, you  will eventually get a version of the command that doesn't work with your application, and suddenly everything is broken, confusing, and hard to debug.

### How to type it less

1. I have heard that `rvm` overwrites all gem commands to automatically load your Bundle, so you don't have to use `bundle exec`. I don't recommend doing that, but it seems to work for at least some people.
1. Create a shell alias to make it shorter to type. I'm partial to `alias b="bundle exec"`.

To be honest, neither one of these options strikes me as particularly good, and I wasn't ever very happy with them. Fortunately, there's another option.

### How to avoid it

Use per-app binstubs. Rails has already shipped with binstubs for `rails` and `rake` for several years. To use the built-in Rails binstubs to run a rake command, execute `bin/rake something`. To run a Rails command, run `bin/rails something`.

To add your own commands, run `bundle binstubs GEM` and then check in anything added to `bin/` that you want to keep and use. For example, run `bundle binstubs rspec-core` and then commit your new `bin/rspec` file. Or `bundle binstubs puma` and then commit `bin/puma`.

Once you have binstubs, it's always clear which gem you're going to get when you run a command: `rspec` will get you whatever the newest rspec gem is, while `bin/rspec` will get you the rspec gem that this particular application has in its Gemfile.lock.

Use binstubs. That's the post!
