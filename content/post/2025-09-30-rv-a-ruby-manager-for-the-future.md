+++
title = '<code>rv</code>, a Ruby manager for the future'
slug = 'rv-a-ruby-manager-for-the-future'
date = 2025-09-30T12:25:36-07:00
+++

<small>This post was originally given as a talk at the <a href="">SF Ruby Meetup</a>. The [slides](https://speakerdeck.com/indirect/rv-a-ruby-manager-for-the-future) are also available.</small>

<script defer class="speakerdeck-embed" data-id="4591b4b2d21d42c399dea04572cc8cff" data-ratio="1.7777777777777777" src="//speakerdeck.com/assets/embed.js"></script>

For the last ten years or so of working on Bundler, I’ve had a wish rattling around: I want a bigger, better dependency manager. It doesn’t just manage your gems, it manages your ruby versions, too. It doesn’t just manage your ruby versions, it installs pre-compiled rubies so you don’t have to wait for ruby to compile from source over and over. And more than all of that, it makes it completely trivial to run any script or tool written in ruby, even if that script or tool needs a different ruby and gems than your application does.

For the entire ten years of daydreaming, I’ve been hoping someone else would build it and I could just use it. Then I discovered that someone _did_ build it… but for Python. It’s called [`uv`](https://docs.astral.sh/uv/), and almost exactly one year ago [version 0.3 shipped](https://astral.sh/blog/uv-unified-python-packaging) with all the features I had wished for, and even more that I hadn’t thought to wish for.

At this point, I’ve been using `uv` for almost a year and every time I use a project written in Python, the experience is delightful. Not only can you run a command directly out of any package that isn’t even installed, you can run a command that requires a python you don’t have installed, and `uv` takes care of installing the right python, installing the right packages, and running your command, in just a second or two.

Whether you want to run a CLI tool, a webapp, or a random script, `uv` always ensures the environment is correct as part of running the command. No more installing a new package version only to realize later you broke something old, no more setting up dependencies manually only to have the script running inside cron silently break later.

Earlier this year, my long time consulting job disappeared and I found myself looking for something to replace it. One of my ideas was to start a company inspired by [Geomys](https://geomys.org) in the Go language, offering expert advice from open source maintainers, but the idea felt weak to me without a “spotlight” project to show off our expertise.

In July of this year, I finally realized that these two ideas could go together extremely well—the company can show our expertise by building this developer tool, and clients paying for our advice to solve their problems can ensure we are able to support and expand the tool.

I talked to some Ruby friends about the idea, and it resonated with them, so we started working on both the company and the open source project. Today, Spinel Cooperative has a website at [spinel.coop](https://spinel.coop), and `rv` has a website at [rv.dev](https://rv.dev). The team has expanded, and includes notable RubyGems and Bundler contributors [Samuel Giddins](https://segiddins.me) and [David Rodriguez](https://github.com/deivid-rodriguez), notable Rails contributors [Kasper Timm Hanson](https://kaspth.com) and [Sam Stephenson](https://sls.name), who is also the original creator of [rbenv](https://rbenv.org) and ruby-build.

Our goal is a completely new kind of management tool, where you don’t need to install rvm and then some ruby and then update rubygems and bundler and then bundle install your gems—you just run your command, and everything is handled. Not a version manager, or a dependency manager, but both of those things and much more.

With that vision in place, we were now faced with a very practical question. What can we build that would be useful right away? We landed on precompiled rubies for development work as the most useful place to start, and got to work.

We're using Rust to build `rv`, for two reasons. The obvious reason is that Rust produces very fast results, which is also why our biggest inspiration `uv` is written in Rust. The less obvious reason is based on years of trying to onboard new contributors to Bundler and RubyGems—it turns out if you are a Ruby developer, you unfortunately don't (yet) know the subset of Ruby that we are forced to use for Bundler and RubyGems.

There are two major things that basically every Ruby program does that you can't do if you are managing gems. First, you can't use any gems. If you want to use code that's inside a gem, you need to copy that code wholesale into Bundler or RubyGems, and then you need to constantly update it anytime that gem has any changes. Second, you can't use anything with native extensions, ever. JSON gem? Psych gem for YAML? Completely impossible, because Bundler and RubyGems need to be installable even if there is no compiler present.

So with those constraints in mind, and with a clear goal in mind of a tool so fast you normally can't even tell it's running, we settled on Rust, and started building a CLI. I've used Rust for smaller personal projects in the past, but never created a full CLI tool. I am happy to report that the `clap` library for creating CLIs in Rust is great, and recommend it to anyone who might be interested.

The next piece that we needed was precompiled Rubies. There are a few big projects out there compiling Ruby in advance, mostly for use on servers. The `setup-ruby` GitHub action and the official Ruby docker images are both based on the `ruby-build` project originally started as part of `rbenv`.

Unfortunately, those existing precompiled Ruby versions aren't usable for our needs because they aren't **statically compiled** and because they aren't **relocatable**. Statically compiled (as opposed to dynamically compiled) means that Ruby copies the code from a shared library into its own binary.

Show of hands... have any of you ever had trouble compiling Ruby because of OpenSSL? Okay, put your hands down. Now, how many of you have had an already-installed Ruby suddenly stop working because of OpenSSL, and you had to install it again? Good news, `rv` fixes both of those problems by putting the OpenSSL inside the Ruby, so they can never get separated.

There is a tradeoff here—if there is a critical security flaw in OpenSSL, we will need to compile Ruby again to include the critical security update. The first reason we are okay with this tradeoff is that OpenSSL doesn't have huge security issues very often. The second reason we are okay with this is that your production servers are probably using the official Ruby docker images and not Ruby installed by `rv`, so it's even less of a concern.

In the end, the closest existing system we were able to build on top of was Homebrew's `portable-ruby` project. That's the system Homebrew uses to build the Ruby install that Homebrew itself runs on. The Homebrew team built some excellent infrastructure for building a statically linked Ruby, and even added the changes needed to make sure that Ruby could be relocated.

Since Homebrew needs to be able to install into `/usr/local` on x86, but `/opt/homebrew` on Apple Silicon, and into any user's home directory for Linuxbrew, they need to be able to take a single precompiled Ruby and put it in any location on disk. That's another one of the requirements that isn't met by the `setup-ruby` or Docker image Rubies—if you move them to another directory, they stop working.

Using Homebrew's `portable-ruby` as a base, we were able to start with macOS ARM and Ubuntu x86, add Ubuntu on ARM, and then build every version in the Ruby 3.4.x series. After a few weeks of work, we had some initial functionality working. `rv` could switch between installed Ruby versions in zsh, but most importantly **it could install precompiled Ruby 3.4.x on macOS and Ubuntu in one second flat**. Yes, you heard that right. `rv ruby install 3.4.5`. Wait 1 second. Done. You can run Ruby commands now.

With that proof of concept complete, we announced version 0.1. People got very excited! It was fantastic to see how many people were excited by the vision for a new, fast tool for Ruby development.

It's been a few weeks since that 0.1 release, and we have been hard at work. We've expanded the team to include community contributors, merged pull requests, and compiled more Rubies than ever.

When 0.2 is released, in the very near future, it will include support for not just zsh, but bash, fish, and nushell. We have also added support for macOS on x86, meaning we now fully support x86 and ARM on both macOS and Linux. Finally, the precompiled Ruby versions available will expand to include all of Ruby 3.3 as well as 3.4. Just to top all of that off, every version of Ruby will have YJIT built in.

Our short-term plans include finishing support for Ruby 3.2, adding rubies that work with musl libc on Linux, and testing on more Linux distributions. Our longer-term plans including improving the way gems are compiled, so that installing your entire application and all of its gems can happen in just a few seconds.

We want to live in a future where anyone can run a Ruby command, or tool, or application in seconds (or less!). We're going to build that future, for ourselves and for everyone else.
