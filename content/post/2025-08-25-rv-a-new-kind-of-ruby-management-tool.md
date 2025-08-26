+++
title = '<code>rv</code>, a new kind of Ruby management tool'
slug = 'rv-a-new-kind-of-ruby-management-tool'
date = 2025-08-25T23:21:07-07:00
+++

For the last ten years or so of working on Bundler, I’ve had a wish rattling around: I want a better dependency manager. It doesn’t just manage your gems, it manages your ruby versions, too. It doesn’t just manage your ruby versions, it installs pre-compiled rubies so you don’t have to wait for ruby to compile from source every time. And more than all of that, it makes it completely trivial to run any script or tool written in ruby, even if that script or tool needs a different ruby than your application does.

During all those years of daydreaming, I’ve been hoping someone else would build this tool and I could just use it. Then I discovered that someone _did_ build it… but for Python. It’s called [`uv`](https://docs.astral.sh/uv/), and almost exactly one year ago [version 0.3 shipped](https://astral.sh/blog/uv-unified-python-packaging) with all the features I had wished for, and even a few more that I hadn’t thought to wish for.

Originally created as an alternative to `pip`, `poetry`, and all the other Python dependency managers, `uv` grew to encompass several existing tools, and has a few completely new tricks up its sleeve.

At this point, I’ve been using `uv` for almost a year and I have to say, it is really, really good. The combination of speed, reliability, and functionality creates a spectacularly good experience. No more changing a package as you install something new only to realize later you broke something old, no more setting up dependencies manually only to have the cronned script break later.

About a month ago, I decided that if there was no tool like this for Ruby, I would make one rather than keep dreaming about it. I want to bring all the tricks and innovations of `cargo`, `npm`, and `uv` into a tool for Ruby: `rv`.

The first and biggest trick is simply how fast everything is because `rv` is written in Rust, like `uv` is. We expect to be able to silently run equivalents of both `rvm install` and `bundle install` at the beginning of every `bundle exec`, with everything still feeling faster than it ever has before.

The next innovation is `rvx`/`rv tool run`, inspired by `uvx`/`uv tool run`. It’s like `npx`/`npm exec` or `gem exec`, but with superpowers. Any CLI command can run directly and immediately. No messing around with versions or dependencies, because they get installed as part of running the command. It will also be impossible for a CLI tool to conflict with your current project’s Ruby or gems, because the tool’s Ruby and gems will be installed in a separate and isolated environment.

Closely related to `rv tool run` is `rv tool install`, which lets you install any gem as a CLI tool with its own separate, isolated Ruby and gems. Want to use the `gist` gem, even while working on an app that needs a different Ruby? No problem. `rv tool install gist`, and then you have a `gist` command that you can run anywhere, whether you’re in another Ruby app or not.

Another “powered up” feature is script support, where a single file script contains the information from `.ruby-version`, from `Gemfile`, and from `Gemfile.lock`, together with the code. You can simply `rv run script.rb`, and you get the Ruby you need, the gems with versions you need, and the script runs.

Ultimately, though, the biggest change from anything that exists today is combining all these tools together into one place. By managing both Ruby versions and gems at once, `rv` is a tool that can just run whatever you want to run. Whether it’s a CLI tool, a webapp, or a random script, `rv` will always ensure your entire environment is correct as part of running the command.

Our end goal is a completely new kind of management tool, where you don’t need to install rvm and then install ruby and then update rubygems and then update bundler and then bundle install your gems and then run your actual command—you just run your command, and everything is handled.

Not a version manager, or a dependency manager, but both of those things and more. I’m currently calling this category a “language manager”, but if you have a better name idea, let me know!

After a few weeks, the team now includes [Samuel Giddins](https://segiddins.me) from the RubyGems team, and [Sam Stephenson](https://sls.name), the original creator of [rbenv](https://rbenv.org). We have the first step in the plan working: `rv` can auto-switch between installed Ruby versions in zsh, but most importantly **it can install precompiled Ruby 3.4.x on macOS and Ubuntu in one second flat**.

If you just want to try what we have so far, [check out the `rv` repo](https://github.com/spinel-coop/rv). You can also read more about [our future plans](https://github.com/spinel-coop/rv/blob/main/docs/PLANS.md).

Meanwhile, if your company could use faster, more productive developers, [let’s talk](mailto:hello+introducing-rv@spinel.coop). We can definitely make that happen.


<small>

updated 2025-08-26: `uv exec` (which doesn't exist) replaced with `uvx`, which does exist. thanks [@xor.blue](https://bsky.app/profile/xor.blue) and [@edmorley](https://github.com/edmorley) for pointing that out.

</small>
