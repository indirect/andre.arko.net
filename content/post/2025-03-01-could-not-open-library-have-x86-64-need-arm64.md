---
date: '2025-03-02T02:30:37+00:00'
title: Could not open library, have <code>x86_64</code>, need <code>arm64</code>
---
This week I re-encountered a problem that has been plaguing me for months, but I never took the time to try to debug it before now. The problem came with a really specific and confusing symptom: any time I installed a newer version of Ruby on my machine, a daily cronjob running a Ruby script would start failing. The specific error was always an FFI exception, with the exact error message `FFI::DynamicLibrary.load_library: Could not open library`.

Even more mysteriously, the error message also said:

```
dlopen tried 'gems/llhttp-ffi-0.5.0/ext/aarch64-darwin/libllhttp-ext.bundle’ (mach-o file, but is an incompatible architecture (have 'x86_64', need 'arm64e' or 'arm64'))
```

So somehow, this library was compiled to only contain a `x86_64` binary, put that binary was located in a directory for `aarch64-darwin` binaries, which means it should have been the exact `arm64` format that the error message claims to want!

Checking my Ruby installation just made me more confused, since my installation was compiled solely for `arm64`, and shouldn’t even be able to run in `x86_64` mode at all:</p>

```
ruby -v
ruby 3.4.2 (2025-02-15 revision d2930f8e7a) +PRISM [arm64-darwin24]
```

From past experience, I knew that running `gem pristine llhttp-ffi` to re-install the gem would fix the problem, and I wouldn't see it again until the next time I upgraded to a new Ruby version. Tired of that happening, I decided to figure out how to reproduce the issue, and that's when I ran into the next problem: I couldn't reproduce the issue.

The script used `bundler/inline` to automatically install any missing gems, and started off something like this:

```ruby
require "bundler/inline"
gemfile do
  source "https://rubygems.org"
  gem "llhttp-ffi"
end
```

If I deleted the `llhttp-ffi` gem, and ran the script again, it would reinstall successfully, and the script would work. I complained about my issue in the Bundler Slack, and [Sam](https://segiddins.me) asked if it was possible there was an x64 binary somewhere in the chain running my script... and he was right!

To make this script work as a cronjob, the actual launchd command is something like:

```
fdautil exec zsh -c 'source chruby.zsh; cronitor exec ruby script.rb'
```

Systematically checking each of `fdautil`, `zsh`, `cronitor`, and `ruby` with `lips -archs` revealed the culprit: the cronitor daemon is x86_64 only. Somehow running `cronitor` via Rosetta and then `exec`ing to the arm64 Ruby executed completely fine... but installing new gems produced the wrong architecture binary.

I was able to solve the problem by adding one more layer of exec, using the `arch` command to force the correct architecture when running Ruby itself:

```
fdautil exec zsh -c 'source chruby.zsh; cronitor exec arch -arm64 ruby script.rb'
```

With that change, deleting the gem and running the command again started working! And now my scheduled job will stop failing every time I upgrade to a new Ruby. I hope.