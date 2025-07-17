---
date: "2020-07-10T00:00:00Z"
title: <code>sudo</code> with TouchID and Apple Watch, even inside <code>tmux</code>
slug: sudo with TouchID and Apple Watch, even inside tmux
---

Ever since TouchID was introduced in the 2016 MacBook Pro, I wondered why it could replace user authentication dialogs in the GUI, like System Preferences or Installer, but not in the command line, for things like `sudo`. Perhaps predictably, many nerds on the internet had the same idea, and for a while you could [install a fork of sudo](https://github.com/mattrajca/sudo-touchid) (!!) or a [custom PAM module](https://github.com/hamzasood/pam_touchid) to get TouchID support.

It turns out that none of that was actually needed, though, and a (somewhat obscure) built-in way to enable it was [shared on Twitter in 2017](https://twitter.com/cabel/status/931292107372838912). Surprisingly, Apple actually ships a PAM module named [`pam_tid.so`](https://opensource.apple.com/source/pam_modules/pam_modules-173.1.1/modules/pam_tid/pam_tid.c.auto.html) in every copy of macOS. If you [configure `sudo` to use it](https://apple.stackexchange.com/a/306324), you can skip typing your password and just TouchID instead, without having to completely destroy the security of your machine.

Unfortunately, it never worked for me. 😭 Some debugging later, I figured out that it worked inside a regular shell, but not inside shells opened by `tmux` or `ssh`. Since I pretty much exclusively use shells opened by `tmux` and `ssh`, I spent some time frantically googling around for how to fix them, and found pretty much nothing. It worked outside of tmux, it didn't work inside tmux, and that was that.

Fast forward three years to today, and while griping to a friend about how it didn't work inside tmux, I discovered that technology has advanced and there is now [a fix, named `pam_reattach`](https://github.com/fabianishere/pam_reattach)! It's a PAM module that you configure to run before the built-in `pam_tid.so`, and it makes the `sudo` command able to find and use the TouchID module to authenticate, even from inside `tmux`.

Amazingly, I was even able to find a written explanation of the thought process that produced the PAM module, in the form of this [Stack Overflow answer](https://superuser.com/a/1348180). Based on that answer and the linked discussion, it seems the steps were:

1. Apple patches `screen` to stay attached to a user's GUI login session, so that CLI tools like `pbcopy`, `security`, and system calls like TouchID checks will continue to work.
1. [@ChrisJohnsen](https://github.com/ChrisJohnsen) uses some of the undocumented functions called by the `screen` patch to implement the now-ubiquitous [`reattach-to-user-namespace`](https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard/) command that allows `pbcopy` and `pbpaste` to continue working inside `tmux` or non-Apple `screen`.
1. Once TouchID MacBooks have emerged, [@Cabel](https://twitter.com/cabel/) reveals the existence of `pam_tid.so` and TouchID authentication for `sudo`. Unfortunately, it doesn't work in non-GUI processes like SSH, tmux, or homebrewed screen.
1. [@fabianishere](https://github.com/fabianishere), again inspired by Apple's patches to `screen`, sends pull requests that re-enable TouchID to both [reattach-to-user-namespace](https://github.com/ChrisJohnsen/tmux-MacOSX-pasteboard/pull/70) and [tmux](https://github.com/tmux/tmux/pull/1434).
1. After some discussion of unfortunate tradeoffs, both PRs are closed, and they create a new PAM module, analogous to `reattach-to-user-namespace` but just for the PAM flow: [`pam_reattach`](https://github.com/fabianishere/pam_reattach). This enables TouchID for `sudo` in both `tmux` and homebrewed `screen`.
1. In macOS Catalina, Apple adds Apple Watch confirmations to the "TouchID" system. If you have an Apple Watch configured to unlock your Mac, you can also double-tap the watch button to confirm a TouchID prompt instead of scanning your finger.
1. Enterprising Swift coder [@Reflejo](https://github.com/Reflejo) wrote a new PAM module to enable TouchID support named [`pam-touchid`](https://github.com/Reflejo/pam-touchID). Implemented in Swift, it is 1/3 shorter and (in my opinion) about 1000x easier to understand than the [straight C module from Apple](https://opensource.apple.com/source/pam_modules/pam_modules-173.1.1/modules/pam_tid/pam_tid.c.auto.html).
1. [@biscuitehh](https://github.com/biscuitehh/), not content with Apple Watch `sudo` exclusively on Macs with TouchID hardware, forked `pam-touchid` into [`pam-watchid`](https://github.com/biscuitehh/pam-watchid), a PAM module that allows `sudo` via Apple Watch on any Mac.

I'm pretty excited that I can finally `sudo` using my fingerprint or my watch, and a little bit in awe of the way determined nerds manage to figure things out eventually. Nice work, everyone.
