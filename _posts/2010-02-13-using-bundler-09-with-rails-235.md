---
title: Bundler 0.9 and Rails 2.3.5
layout: post
---
[Bundler](http://github.com/carlhuda/bundler) 0.9 is out, and people have been having trouble getting it working with Rails 2.3.5 applications. In order to help with that, I'll be keeping this blog post updated with the latest instructions on converting a Rails 2.3.5 application over to use Bundler 0.9.

The first step in converting is to tweak the configuration and startup files in your app. You'll need to add a monkeypatch to your app's `config/boot.rb` file:

<script src="https://gist.github.com/302406.js?file=boot.rb"></script>

Next, you'll need to add a new file at `config/preinitializer.rb`, and put this into it:

<script src="https://gist.github.com/302406.js?file=preinitializer.rb"></script>

Last, you'll need to move your gem requirements list from `config/environment.rb` to your `Gemfile`. Here's an example `Gemfile`:

<script src="https://gist.github.com/302406.js?file=Gemfile"></script>

By the time you have finished, there shouldn't be any `config.gem` statements left in your `environment.rb` file. All the gems that your application depends on should be listed in your `Gemfile` instead. If you have gems that should only be loaded in certain environments, like development-only or test-only gems, you can put those in the "development" and "test" groups.

When you're done, you can install your gems and record the specific versions that you are using, so that they won't change unexpectedly as you deploy:

    bundle install
    bundle lock

After you have installed and locked your bundle, you can run Rails scripts directly. However, you _must_ run all other commands via `bundle exec`. For example:

    ./script/server
    bundle exec rake db:migrate

When you deploy your application, you will need to run `bundle install` as part of your deploy process, typically after your code has been updated but before you restart your app servers. If you have development gems that you can't (or don't want to) install on your production machine, you can run `bundle install --without development`.

There are a lot more things you can do with the Bundler. If you want to read about them, I suggest checking out the [Bundler README](http://github.com/carlhuda/bundler/tree/master/README.markdown).
