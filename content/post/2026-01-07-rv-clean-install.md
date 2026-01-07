+++
title = 'Announcing <code>rv clean-install</code>'
slug = 'rv-clean-install'
date = 2026-01-07T12:31:16+08:00
canonical = 'https://spinel.coop/blog/rv-clean-install/'
+++

<small>Originally posted [on the Spinel blog](https://spinel.coop/blog/rv-clean-install/).</small>

As part of our [quest to build a fast Ruby project tool](https://andre.arko.net/2025/08/25/rv-a-new-kind-of-ruby-management-tool/), we've been hard at work on the next step of project management: installing gems. As we've learned over the last 15 years of working on Bundler and RubyGems, package managers are really complicated! It's too much to try to copy all of rbenv, and ruby-build, and RubyGems, and Bundler, all at the same time.

Since we can't ship everything at once, we spent some time discussing the first project management feature we should add after Ruby versions. Inspired by `npm` and `orogene`, we decided to build `clean-install`. Today, we're releasing the `rv clean-install` command as part of [`rv` version 0.4.](https://github.com/spinel-coop/rv/releases/tag/v0.4.0)

So, what is a clean install? In this case, clean means "from a clean slate". You can use `rv ci` to install the packages your project needs after a fresh checkout, or before running your tests in CI. It's useful by itself, and it's also concrete step towards managing a project and its dependencies.

Even better, it lays a lot of the groundwork for future gem management functionality, including downloading, caching, and unpacking gems, compiling native gem extensions, and providing libraries that can be loaded by Bundler at runtime.

While we don't (yet!) handle adding, removing, or updating gem versions, we're extremely proud of the progress that we've made, and we're looking forward to improving `rv` based on your feedback.


Try running `brew install rv; rv clean-install` today, and see how it goes. Is it fast? Slow? Are there errors? What do you want to see next? [Let us know what you think](https://github.com/spinel-coop/rv/issues/new).
