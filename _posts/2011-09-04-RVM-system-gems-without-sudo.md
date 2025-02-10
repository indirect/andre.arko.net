---
date: "2011-09-04T00:00:00Z"
title: RVM system gems without sudo
---
Somewhat unusually (I guess?) I sometimes use system Ruby on OS X. I use RVM for other versions of Ruby, like 1.9.2 and JRuby. System Ruby is still the easiest Ruby version to use on OS X, however. Furthermore, because it is so common with developers, I need to make sure that each new version of [Bundler][1] is compatible with OS X system Ruby.

[1]: https://github.com/carlhuda/bundler

System Ruby has a problem, though: it is hardcoded to install gem executables into `/usr/bin`. This is very awkward because it means you need to run `sudo gem install` so Rubygems can install the binaries. A less awkward setup (IMHO), is to leave /Library/Ruby/Gems/1.8 owned by the staff group, as it is in a fresh OS X install. In order to make that setup work, however, you have to override the Rubygems binary directory by adding `-n/Library/Ruby/Gems/1.8/bin` to your `~/.gemrc` file, or pass that to the `gem` command every time you run it. Once you add that directory to the front of your `$PATH` environment variable, you're set. Install gems without sudo, and everything is good.

This is all well and good until you install RVM and it tries to install gems for other versions of Ruby. Those other versions of Ruby will honor your `~/.gemrc` file and install your gem binaries into the system gems binary directory. In order to work around this, I have written an after_use hook for RVM. It redefines the `gem` function that RVM sets up when you change between Ruby versions to include the -n option or not, depending on the version of Ruby that you have switched to. Here's the code:

``` bash
#!/usr/bin/env bash

if [ $rvm_ruby_string == "system" ]; then
  function gem {
    local result
    command gem "-n/Library/Ruby/Gems/1.8/bin $@" ; result="$?"
    hash -r
    return $result
  }
else
  function gem {
    local result
    command gem "$@" ; result="$?"
    hash -r
    return $result
  }
fi
```

In order to install it, run these commands:

``` bash
curl http://bit.ly/after_use_system_binstubs > ~/.rvm/hooks/after_use_system_binstubs
chmod +x ~/.rvm/hooks/after_use_system_binstubs
```

Once the hook is installed, RVM will redefine the `gem` function to include the -n option for system gem installs, and not include the -n option for non-system gem installs. It's really pretty nice, since you no longer have to use `sudo` to install any gems, system or not.