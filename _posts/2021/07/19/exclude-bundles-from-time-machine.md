---
layout: post
title: "Exclude bundles from Time Machine and Spotlight"
microblog: false
guid: http://indirect-test.micro.blog/2021/07/20/exclude-bundles-from-time-machine/
post_id: 4971977
date: 2021-07-19T16:00:00-0800
lastmod: 2021-07-19T16:00:00-0800
type: post
url: /2021/07/19/exclude-bundles-from-time-machine/
---

**short version:** run `cd; bundle plugin install bundler-mac`, never think about it again.


**long version:**

Last week I noticed that Time Machine was taking an incredibly long time to finish a backup. I investigated using [The Time Machine Mechanic](https://eclecticlight.co/consolation-t2m2-and-log-utilities/) and discovered that at least one of the slow things was many thousands of files from installed gems.

I have a lot of Ruby projects checked out on my machine at any given time. To keep all of those projects completely isolated from each other, I use `bundle config set --global path .bundle`. That config means each bundle will be installed into the `.bundle` directory inside that project.

It turns out that installing tens or hundreds of gems each into tens or hundreds of projects is... a lot of files. And all those files need to be backed up anytime I check out a new project or update a project and change the installed gems. Realizing that I don't actually need to back up those files, since I can reinstall the ones I need by running `bundle install`, I started looking for ways to automatically exclude bundled gems from backups.

I was able to find [a pretty good wrapper function](https://gist.github.com/peterdemartini/4c918635208943e7a042ff5ffa789fc1) posted to Github. It can handle `npm`, `bundler`, and `cargo` fairly effectively, but replacing commands with shell functions always feels kind of hacky. Then I discovered that Cargo actually [excludes built files from Time Machine automatically](https://github.com/rust-lang/cargo/issues/3884). If Cargo can do it, Bundler ought to be able to do it, right?

This led me on a multi-week quest, wherein I discovered [the 12-year-old `xattr` gem](https://rubygems.org/gems/xattr), then had to learn enough about [`fiddle`](https://github.com/ruby/fiddle) to [update `xattr` to use it](https://github.com/indirect/xattr), then [write tests until I was confident that it worked](https://github.com/indirect/xattr/blob/main/spec/xattr_spec.rb). Once I had a new `xattr` gem, I was finally ready to tackle the original idea: making Bundler exclude gems from backups automatically.

Somewhat ironically, I mentored the Google Summer of Code student who implemented Bundler plugins, but I had never written one myself. Fortunately, [the docs for writing a Bundler plugin](https://bundler.io/guides/bundler_plugins.html) were actually pretty good! It took much less time to actually make it work than it had to figure out what I wanted to do in the first place. In an afternoon of work, [bundler-mac](https://github.com/indirect/bundler-mac) was born.

While researching Time Machine and how to exclude files from backups, I discovered the answer to something else that had annoyed me: Spotlight indexing. If I use the Finder to search for "module", I don't want to see every file from every gem I have ever installed that defines a module... but that's what I get by default. So I added something to `bundler-mac` that also creates a magic dotfile to warn Spotlight away. No more 25 search results from 25 copies of the same gem!

Bundler plugins have one somewhat surprising aspect: if `pwd` has a Gemfile, installing a plugin will only apply to the current application bundle. If there is no Gemfile present, installing a plugin will apply at the user level, to all application bundles. Because of that, you'll want to make sure that you `cd` into your home directory before installing this plugin.

Maybe, if this works well, it can eventually be part of Bundler itself! If we're incredibly lucky, maybe this can eventually be part of every package manager, and not just Cargo and Bundler.

With that, we've made it through all the explanations to the very end! Run `cd` to get to your home directory, and then run `bundle plugin install bundler-mac` to get the plugin. Now anytime you run `bundle install` in the future, your bundled gems will be excluded from Time Machine backups and Spotlight search indexing. Hooray!
