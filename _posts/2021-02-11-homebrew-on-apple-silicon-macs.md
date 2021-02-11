---
title: "Homebrew on Apple Silicon Macs"
layout: post
---

A mere five and a half weeks after I ordered it, my M1 MacBook Air has finally arrived! Phew. Here are my notes from porting my dotfiles and setting it up.

### Homebrew

Installing Homebrew on M1 Macs is blessedly straightforward: you go to [brew.sh](https://brew.sh) and copy and paste the install command into your terminal.

However! On an M1 Mac, using the Homebrew installer puts your entire installation into `/opt/homebrew` instead of the previous usual `/usr/local`. You’ll want to check for that, and put it in your path ahead of `/usr/local`, if it exists. Here’s my snippet to make sure I always get the right `brew` on my path:

	export BREW_PREFIX=$([[ "$(arch)" == "arm64" ]] && echo "/opt/homebrew" || echo "/usr/local")
	[[ "$PATH" != "*$BREW_PREFIX/bin*" ]] && export PATH="$BREW_PREFIX/bin:$PATH"

### Strap

If you use [`strap`](https://macos-strap.herokuapp.com) to set up new computers, keep in mind that it will skip the Homebrew installer and instead copy it directly into `/usr/local`. You'll need to use the regular Homebrew install process above to get a copy installed into `/opt/homebrew` as well.

### architectures

If you need bottles that only exist for Intel (like `mas`), you can create shell aliases to help you access that stuff more easily:

	alias ibrew="arch -x86_64 /usr/local/bin/brew"

With that alias, you can use `ibrew` to manually force the Intel Homebrew installation, to install something you might not otherwise be able to install. The rest of the time, you can use regular `brew` to get native binaries that have been compiled for your machine.

### `brew bundle` and `mas`

Speaking of things that you might not be able to install compiled for Apple Silicon, let’s talk about `mas`.

I use the `brew bundle` command (run automatically by Strap) to install a bunch of Homebrew formulas, casks, and even Mac App Store apps. However, the `mas` CLI tool used to manage apps from the Mac App Store [hasn’t been ported to Apple Silicon yet](https://github.com/mas-cli/mas/issues/308).

For now, that means running `brew bundle` twice: first, comment out all the Mac App Store apps and run `/opt/homebrew/bin/brew bundle`. Then, comment out everything _but_ the Mac App Store apps, and run `arch -x86_64 /usr/local/bin/brew bundle` to use the Intel version of `mas` to tell the OS to install the Mac App Store apps.

You’ll still get Apple Silicon native versions of the apps from the App Store, since Hombrew has no control over that, and is just asking the App Store to install an app by ID number.

### share and enjoy

and with that, you’re all caught up! I’ve really been enjoying the improved keyboard, absurdly fast compilation speeds, and even more absurdly long battery life. For my uses, switching from Intel to Apple silicon feels a lot like the first time I got an SSD—my computer is visibly faster for almost everything I do. Running for 10 hours on a single battery charge is just ridiculous gravy on top.
