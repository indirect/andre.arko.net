+++
title = 'How to Install a Gem'
slug = 'how-to-install-a-gem'
date = 2026-03-24T18:55:18-07:00
+++

<small>This post was originally given as a talk at <a href="https://sfruby.com">SF Ruby Meetup</a>. The [slides](https://speakerdeck.com/indirect/how-to-install-a-gem/) are also available.</small>

<iframe class="speakerdeck-iframe" style="border: 0px; background: padding-box rgba(0, 0, 0, 0.1); margin: 0px; padding: 0px; border-radius: 6px; box-shadow: rgba(0, 0, 0, 0.2) 0px 5px 40px; width: 100%; height: auto; aspect-ratio: 560 / 315;" frameborder="0" src="https://speakerdeck.com/player/3bf2a60d63cb4a40a23c0e0dccb6a601" title="How to install a gem" allowfullscreen="true" data-ratio="1.7777777777777777"></iframe>

### It's more complicated than it sounds

Hello, and welcome to _How To Install A Gem_. My name is André Arko, and I go by @indirect on all the internet services. You might know me from being 1/3 of the team that shipped Bundler 1.0, or perhaps the 10+ years I spent trying to keep RubyGems.org up and running for everyone to use.

More recently, I've been working on new projects: [`rv`](https://rv.dev), a CLI to install Ruby versions and gems at unprecedented speeds, and [gem.coop](https://gem.coop), a community gem server designed from the ground up so Bundler an `rv` can install gems faster and more securely than ever before.

So, with that introduction out of the way, let’s get started: do you know how to install a gem? Okay, that’s great! You can come up and give this talk instead of me. I’ll just sit over here while you write the rest of this post.

Slightly more seriously, do you know how `gem install` converts the name that you give it into a URL to download a .gem file? It’s called the “compact index”, and we’ll see how it works very soon.

Next, who in the audience knows how to unpack a .gem file? Do you know what format .gem files use, and what's inside them? We’ll look at gem structure and gemspec files as well.

Then, do you know where to put the files from inside the gem? Where do all of these files and directories get put on disk so we can use them later? Does anyone know off the top of their head?

Once those files have been unpacked into the correct places, the last thing we need to know is how to require them. How do these unpacked files on disk get found by Ruby, so you can `require "rails"` and have that actually work?

This exercise was mostly to show that using gems every day actually skips over most of the way they work underneath. So let’s look at what a gem is, and examine how they work. By the end of this talk, you’ll know what’s inside a gem, where how RubyGems figures out what to download, and where and how that download gets installed so you can use it.

And if you already everything we just talked about, please feel free to go straight to [rv.dev](https://rv.dev) and start sending us pull requests!

### How does a name become a .gem URL?

First, we're going to look at how the name of a gem becomes a URL for a .gem file. Let's use `rails` as our example. Historically, there have been at least five or six different ways to look up information about a gem based on its name, but today there is one canonical way: the compact index. It's so simple that you can do it yourself using curl. Just run `curl https://gem.coop/info/rails`, and you'll be able to read the exact output that every tool uses to look up the versions of a gem that exist. Each line in the file describes one version of the gem, so let's look at one line.

	❯ curl -s https://gem.coop/info/rails | tail -n 1
	8.1.3 actioncable:= 8.1.3,actionmailbox:= 8.1.3,actionmailer:= 8.1.3,actionpack:= 8.1.3,actiontext:= 8.1.3,actionview:= 8.1.3,activejob:= 8.1.3,activemodel:= 8.1.3,activerecord:= 8.1.3,activestorage:= 8.1.3,activesupport:= 8.1.3,bundler:>= 1.15.0,railties:= 8.1.3|checksum:6d017ba5348c98fc909753a8169b21d44de14d2a0b92d140d1a966834c3c9cd3,ruby:>= 3.2.0,rubygems:>= 1.8.11

We can break down that line with `split(" ")`, and tackle each part one at a time.

First, `8.1.3`. That's the version of `rails` that this line is about. So we now know for sure that `rails 8.1.3` exists.

Next, a list of dependencies. The `rails` gem (version `8.1.3`) declares dependencies on a bunch of other gems: `actioncable`, `actionmailbox`, `actionmailer`, `actionpack`, `actiontext`, `actionview`, `activejob`, `activemodel`, `activerecord`, `activestorage`, `activesupport`, `bundler`, and `railties`. Each dependency has a version requirement attached, and for almost every gem it is exactly version `8.1.3`, and only version `8.1.3`. For `bundler`, Rails is a little bit more flexible, and allows any version `1.15.0` and up.

The final section contains a checksum, a ruby requirement, and a rubygems requirement. The checksum is a sha256 hash of the .gem file that contains the gem, so after we download the gem we can check to make sure we have the right file by comparing that checksum.

For this version of Rails, the required Ruby version is `3.2.0` or greater, and the required RubyGems version is `1.8.11` or greater. It's up to the client to do something with that information, but hopefully you'll see an error if you are using Ruby or RubyGems that's too old.

Great! So now we know the important information: Rails version `8.1.3` is real, and strong, and is our friend. We can download it, and check the checksum against the checksum we were given in the info file line. Let's do that now:

	❯ curl -sO https://gem.coop/gems/rails-8.1.3.gem
	❯ sha256sum rails-8.1.3.gem
	6d017ba5348c98fc909753a8169b21d44de14d2a0b92d140d1a966834c3c9cd3  rails-8.1.3.gem

Notice that the checksum produced by `sha256sum` exactly matches the checksum we previously saw in our line from the info file: `6d017ba5348c98fc909753a8169b21d44de14d2a0b92d140d1a966834c3c9cd3`. That lets us know that we got the right file, and there were no network or disk errors.

### What exactly is in a gem?

Now that we have the gem, we can investigate: what exactly is inside a gem? At this point, we're going to pivot from the `rails` gem to the `railties` gem. There's a good reason for that, and the reason is... the `rails` gem doesn't actually have any files in it. So it's a bad example. In order to show off what a gem looks like when it has files in it, we'll use `railties-8.1.3.gem` instead.

So, we have our .gem file downloaded with curl. What do we do now? The first piece of secret knowledge that we need: gems are tarballs. That means we can open them up with regular old `tar`. Let's try it.

	❯ tar xfvz railties-8.1.3.gem
	x metadata.gz
	x data.tar.gz
	x checksums.yaml.gz

So what's inside the .gem tarball is... another tarball. And also two gzipped files. Let's look at the files first.

	❯ gzcat checksums.yaml.gz
	---
	SHA256:
	  metadata.gz: 8326ab6cc8e325055394ebd19c41d895e9ebd48e4752ec90d5c4675935516e6e
	  data.tar.gz: 4152d8f55ae639d899f1cb6c54e1e93bb158bb76026b253482c5ae0343ac5aec
	SHA512:
	  metadata.gz: f6aa3390b6b1699255f1dbc6c6f24c6d9c18d3bfa48f10b6d720595384b4d1bb26f92232adb7011d3b1e7e977ca775cd253a12a135fe83eaa21e10dd0f14f779
	  data.tar.gz: a001cebc5b97f627336a3e8d394c4ecac4a5d2b9e62c82de3b484470a58deac7c8ff0a8e8b497843386b1639c9cbfdfabee2cc7b2d483469e00a0b01da6bd41d

As you might expect from its name, the `checksums.yaml.gz` file is a gzipped YAML file, containing checksums for the other two files. It's maybe a bit silly to have multiple layers of checksumming here, but it does confirm that the outer layer of tarball and zip was removed without any errors.

Okay, so what's inside `metadata.gz`? The answer is... Ruby, sort of. It's a YAML-serialized instance of the `Gem::Specification` class. We can see exactly what was put into this object at the time the gem was built.

After snipping out the YAML that lists the dependencies (which we already looked at, because they are included in the info file), what's left is some relatively simple information about the gem. Author, author's email, description, homepage, license, various URLs.

	❯ gzcat metadata.gz
	--- !ruby/object:Gem::Specification
	name: railties
	version: !ruby/object:Gem::Version
	  version: 8.1.3
	platform: ruby
	bindir: exe
	executables:
	- rails
	require_paths:
	- lib
	authors:
	- David Heinemeier Hansson
	summary: Tools for creating, working with, and running Rails applications.
	description: 'Rails internals: application bootup, plugins, generators, and rake tasks.'
	email: david@loudthinking.com
	homepage: https://rubyonrails.org
	licenses:
	- MIT
	metadata:
	  bug_tracker_uri: https://github.com/rails/rails/issues
	  changelog_uri: https://github.com/rails/rails/blob/v8.1.3/railties/CHANGELOG.md
	  documentation_uri: https://api.rubyonrails.org/v8.1.3/
	  mailing_list_uri: https://discuss.rubyonrails.org/c/rubyonrails-talk
	  source_code_uri: https://github.com/rails/rails/tree/v8.1.3/railties
	  rubygems_mfa_required: 'true'
	rubygems_version: 4.0.6
	specification_version: 4
	files:
	- CHANGELOG.md
	- MIT-LICENSE
	- RDOC_MAIN.md
	- README.rdoc
	- exe/rails
	- lib/minitest/rails_plugin.rb
	- lib/rails.rb
	[...]

For the purposes of installing and using the gem, we care about exactly six pieces of information: `name`, `version`, `platform`, `bindir`, `executables`, and `require_paths`.

We're going to combine those items with the files in the remaining `data.tar.gz` file to get our unpacked and installed gem.

### What gets unpacked, and where?

Now that we know what's in the gem specification, let's look at what's inside the data tarball. It matches up very closely with the long list of entries in the `files` array in the gemspec.

	❯ mkdir railties-8.1.3
	❯ tar xfvz data.tar.gz -C railties-8.1.3
	x CHANGELOG.md
	x MIT-LICENSE
	x RDOC_MAIN.md
	x README.rdoc
	x exe/rails
	x lib/minitest/rails_plugin.rb
	x lib/rails.rb
	[...]

So now we have a bunch of files. Where are we going to put these files? Enter: the magic of RubyGems. The scheme that RubyGems has come up with is largely shaped by the constraints of how Ruby finds files to require, which we're going to look at soon. For now, it is enough for us to know that RubyGems keeps track of a list of directories, a lot like the way `$PATH` works for your shell to find commands to run. To find the current directory, you can run `ruby -e 'puts Gem.dir`. Here's what that looks like:

	❯ ruby -e 'puts Gem.dir'
	/Users/andre/.gem/ruby/4.0.0
	❯ ls ~/.gem/ruby/4.0.0 | xargs -L1 echo
	bin
	build_info
	cache
	doc
	extensions
	gems
	plugins
	specifications

From this list, we can see that RubyGems organizes its own files into a few directories. To install a gem, we're going to need to put the files we have into each of those directories, with specific paths and filenames.

Just to recap, the files we need to place somewhere are:
- railties-8.1.3.gem (the .gem file itself)
- metadata.gz (the YAML Gem::Specification object from inside the gem)
- the unpacked data.tar.gz files (the contents of the gem)

So let's move the files into the directories we see RubyGems offers.

First, cache the .gem file so RubyGems doesn't need to download it again later:

	mv railties-8.1.3.gem ~/.gem/ruby/4.0.0/cache/

Then, add the gem specification so that RubyGems will be able to find it. There's a small twist here, which is that the `specifications` directory doesn't contain YAML files, it contains Ruby files. So we also need to convert the YAML file back into a Ruby object, and then write out the Ruby code to create that object into a file that RubyGems can load later.

	❯ gunzip metadata.gz
	❯ ruby -ryaml -e 'puts YAML.unsafe_load_file("metadata").to_ruby' > ~/.gem/ruby/4.0.0/specifications/railties-8.1.3.specification

Next, we need to put the files that make up the contents of the gem into the `gems/` directory.

	❯ mv railties-8.1.3 ~/.gem/ruby/4.0.0/gems/
	❯ ls ~/.gem/ruby/4.0.0/gems/railties-8.1.3
	CHANGELOG.md
	exe
	lib
	MIT-LICENSE
	RDOC_MAIN.md
	README.rdoc

One more thing we need to do: set up the executables provided by the gem.

You can check out the files that RubyGems generates by looking in `~/.gem/ruby/4.0.0/bin`, but for our purposes we just need to tell RubyGems what gem and executable it needs to run, so we can do that:

	❯ cat <<EOF > ~/.gem/ruby/4.0.0/bin/rails
	#!/usr/bin/env ruby
	require "rubygems"
	Gem.activate_and_load_bin_path("railties", "rails")
	EOF
	❯ chmod +x ~/.gem/ruby/4.0.0/bin/rails

And with that, we've installed the gem! You can run the `rails` file that we just created to prove it:

	❯ ~/.gem/ruby/4.0.0/bin/rails
	Usage:
	  rails COMMAND [options]
	
	You must specify a command:
	
	  new          Create a new Rails application. "rails new my_app" creates a
	               new application called MyApp in "./my_app"

As we wrap up here, there are three aspects of gems that we haven't touched on at all: docs, extensions, and plugins. We don't have time to talk about them today in this meetup talk slot. Hopefully a future (longer) version of this talk will have space to include all of those things, because they are all super interesting, I promise.

In the meantime, I will have to direct you to the [docs for RDoc](https://ruby.github.io/rdoc/) to learn more about docs, to [the source code of `rv`](https://github.com/spinel-coop/rv/blob/75786fe29c55452abfc725d43165a1b3035a552e/crates/rv/src/commands/clean_install.rs#L1504) or [RubyGems itself](https://github.com/ruby/rubygems/blob/master/lib/rubygems/ext/ext_conf_builder.rb) if you want to learn more about gem extensions and plugins.

### How does `require` find a gem?

There's one last thing to figure out before we wrap up: how does `require` find a gem for us to be able to use it? To explain that, we'll have to drop down to some basic Ruby, and then look at the ways that RubyGems monkeypatches Ruby's basic `require` to make it possible to have gems with versions.

The first thing to know about `require` is that it works exactly like `$PATH` does in your shell. There's a global Ruby variable named `$LOAD_PATH`, and it's an array of paths on disk. When you try to require something, Ruby goes and looks inside each of those paths to see if the thing you asked for is there.

You can test this out for yourself in just a few seconds! Let's try it.

	❯ mkdir lib
	❯ echo 'puts "this is some ruby"' > lib/my-file.rb
	❯ ruby -Ilib -e 'puts $LOAD_PATH.first; require "my-file"'
	/Users/andre/lib
	this is some ruby

The Ruby CLI flag `-I` lets you add directories to the `$LOAD_PATH` variable, and then the `require` function looks inside that directory to find a file with the name that you gave to require. No magic, just a list to check against for files on disk.

Now that you understand how the `$LOAD_PATH` variable makes `require` work, how does RubyGems work? You can't just put ten different versions of `rake` into the `$LOAD_PATH` and expect `require` to still work. RubyGems handles multiple versions of the same `rake.rb` file by monkeypatching `require`. 

Let's look at what happens when we `require "rails"`, which is a file located inside the `railties` gem that we just installed. RubyGems starts by looking at all of the gem specifications, including the one we saved earlier. In each specification, it combines the name and version with the values in `require_paths` to come up with a path on disk.

So for our just-installed `railties` gem, that would mean a path of: `~/.gem/ruby/4.0.0/gems/railties-8.1.3/lib`.  RubyGems knows that directory contains a file named `rails.rb`, so it is a candidate to be "activated", which is what RubyGems calls it when a gem is added to your `$LOAD_PATH`.

As long as internal bookkeeping shows that no other versions of `railties` have already been added to the `$LOAD_PATH`, we're good! RubyGems adds this specific directory to the `$LOAD_PATH`, and delegates to the original implementation of `require`. Require finds the file at `~/.gem/ruby/4.0.0/gems/railties-8.1.3/lib/rails.rb`, reads it, and evaluates it.

### Gem installed, congratulations

With that, we've done it! We have found, downloaded, unpacked, and installed a gem so that Ruby is able to run a command and load ruby files, without ever touching the `gem install` command.

If you're interested in contributing to an open source project that works a lot with gems, we would love to work with you on `rv`, where we are working to create the fastest Ruby and gem manager in the world.

And of course, if your company could use faster, easier, or more secure gems for developers, for CI, and for production deployments, we can help. We'd love to talk to you and you can find our contact information at [spinel.coop](https://spinel.coop).
