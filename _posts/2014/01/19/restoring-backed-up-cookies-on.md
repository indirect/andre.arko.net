---
layout: post
title: "Restoring backed up cookies on Mac OS X 10.9 Mavericks"
microblog: false
guid: http://indirect-test.micro.blog/2014/01/20/restoring-backed-up-cookies-on/
post_id: 4971612
date: 2014-01-20T00:00:00-0800
lastmod: 2014-01-19T16:00:00-0800
type: post
url: /2014/01/19/restoring-backed-up-cookies-on/
---

You can restore a backup of your `Cookies` file on 10.9 by quitting Safari and then running these commands in the Terminal:

```bash
$ killall cookied
$ mv ~/path/to/backed/up/Cookies.binarycookies ~/Library/Cookies/
$ open -a Safari
```

For reasons that aren't clear to me, every once in a while OS X will clear my entire cookies file, logging me out of every website in Safari and every other Mac app that uses a system WebKit browser window. It's pretty annoying, but in the past I've always been able to fix it by restoring the `Cookies` file from my Time Machine backup. (You have a Time Machine backup, right? If not, please [go buy one][1].)

That seems to have changed with OS X 10.9, with the `cookied` process that runs and seems to act as a central control point for Safari and other applications to access your cookies. It stays running even when Safari is closed, so restoring a backup of your cookies after quitting Safari doesn't help. `cookied` still has your old cookies in memory, and the next time you open Safari, it erases your carefully restored backup and overwrites it with your newly empty cookies file.

As a result, the only way to restore a backup of your cookies is to quit Safari (so that cookied won't automatically get run again), then run `killall cookied` in the Terminal, *then* copy your backup into `~/Library/Cookies`, and finally re-open Safari. I searched the internet for instructions on how to do that for about 20 minutes before giving up and figuring it out myself. Hopefully this post will mean that future me and other people like him will just see the answer right away when they search.

[1]: http://www.apple.com/airport-time-capsule/
