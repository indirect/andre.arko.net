---
title: Towards a Bundler plugin system
layout: post
---

### Where we are now

Bundler 1.2 has reached [release candidate][rc] status, and as we wind down that release, I’ve been thinking a lot about how Bundler can grow into a flexible underpinning for dependency-based tools. As it stands today, Bundler provides a relatively small set of tools to help you manage dependencies. The Ruby community has shown that they are interested in adding to those tools. We’ve been supplied with pull requests that add commands like `bundle viz`, `bundle outdated`, `bundle grep`, `bundle ack`, `bundle do`, and others.

While it’s fantastic that the community is actively interested in expanding the functionality of a tool that they use frequently, we’ve discovered two main downsides to collecting everything in the core Bundler gem and repository. The first downside is that accepting features into Bundler core means that the people maintaining Bundler (currently just [hone][hone] and myself) have to take over maintenance of that code. With the notable exception of [joelmoss][joelmoss], the author of the `outdated` command, contributors have tended to not maintain their code in Bundler.

As the surface area of Bundler has grown, a larger and larger portion of our time working on it has been spent just providing support for and maintenance on features that already exist — this unfortunately slows down both bugfixes and new features. Because of this, I’ve become more and more hesitant to accept contributed commands and features into Bundler. That hesitance makes me sad. The community has created some awesome things, and I’m sure they would be extremely useful to some users. The unpleasant reality is that every new feature reduces the amount of time available to improve the core of Bundler (unless the new feature is both universally applicable and well-maintained by its contributor, like `outdated`).

In an effort to have my cake and eat it too, I’m hoping to come up with a system for Bundler plugins that will allow contributors to create new commands and features, and then provide them to anyone in the community who wants them. Plugins that have a solid track record would then become excellent candidates for inclusion into core. Plugins allow developers to show that they’re willing to fix bugs and keep their code running, and allow users to demonstrate which features are the most universally useful. So, now that I’ve talked your ear off, how will these plugins work? After mulling things over for a while, here’s what I’ve come up with.

### An opt-in extension system

Plugins for Bundler need to do a few main things. They should be easy to install and easy to manage. I also think it’s important that they aren’t enabled automatically — just downloading a plugin onto your system shouldn’t modify Bundler’s behaviour unless you explicitly opt-in to using the plugin. Enabling plugins that way has a convenient side-effect: one user can enable a plugin without enabling it for other users who share their system gems. So, how can we accomplish those goals?

#### Distribution

Plugins can be written and distributed as gems, using the extension namespace convention. For example, the `bundler-grep` gem could provide the command `bundle grep`. However, simply installing a gem plugin can’t activate it, so we need a way to track which plugins are enabled.

Happily, Bundler already ships with a config system to handle per-user settings. Activating plugins can be managed using the `bundle config` command (or possibly using a direct `bundle plugin` command that wraps config). When Bundler starts, it can check the user’s config to see if there are any plugins that it should load. If there are, it can load those plugins using the standard Rubygems require system.

#### Capabilities

So what will plugins be able to do? Based on pull requests so far, the most common request is to add a new command. A great example of this are the recent proposals to add the commands [`licenses`][license] and [`grep`][grep]. Past commands that would have been much easier to ship with a plugin system include `viz` and `outdated`. With the ability to release plugins, direct oversight isn’t needed for additional functionality to be available to those who want to write it or use it.

Along with new commands, the plugin system should also provide hooks for typical activites. For example, some users want to be able to generate documentation (or even generate ctags) for any gems that are installed in their bundle. Callbacks for the gem installation process would allow that to happen. The events that I’m sure could use callbacks are installing gems, updating gem versions, and resolving a Gemfile for the first time. I’m open to suggestions about other times when callbacks would be useful, though.

### So what now?

I’m going to start implementing the plugin system that I outlined in this post. If I’m very lucky, I might even finish it in time for Bundler 1.3. Since things are just getting going, I’m very interested in feedback, questions, and concerns. I’ve opened a [plugins ticket][ticket] for discussion. I would like to make sure that the plugin system that gets implemented can address the needs of most users immediately. If you’re interested in writing a plugin, maybe we can work together. I’m looking forward to seeing what the Ruby community will come up with once they have more room to experiment.

[rc]: https://github.com/carlhuda/bundler/blob/4f022aa998ee642c61740f1a011798aaf3a05cc7/CHANGELOG.md#120rc-jul-17-2012
[hone]: http://github.com/hone
[joelmoss]: http://github.com/joelmoss
[license]: https://github.com/carlhuda/bundler/pull/1898
[grep]: https://github.com/carlhuda/bundler/pull/2024
[ticket]: https://github.com/carlhuda/bundler/issues/1945