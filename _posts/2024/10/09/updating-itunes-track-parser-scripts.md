---
layout: post
title: "Updating iTunes Track Parser Scripts for Music.app"
microblog: false
guid: http://indirect-test.micro.blog/2024/10/10/updating-itunes-track-parser-scripts/
post_id: 4971994
date: 2024-10-10T00:00:00-0800
lastmod: 2024-10-09T16:00:00-0800
type: post
url: /2024/10/09/updating-itunes-track-parser-scripts/
---

Moving from my usual niche interests to a niche so small that I have only seen two people on the internet who care about this: I have some really great news if you still want to manage metadata tags like it’s 2010 and you’re ripping CDs into iTunes. I’ve updated the most useful iTunes track naming script to ever exist, so you can use it in Music.app on macOS 15.1 Sequoia in the year 2024.

The scripts are named `Track Parser (Clipboard)` and `Track Parser (Song name)`, and they were written by [Dan Vanderkam](https://www.danvk.org) in 2004. He maintained them until 2009, put them into a public Google Code project, and eventually moved on with his life. I used both scripts hundreds or maybe even thousands of times between 2004 and 2014. That’s when I switched to Bandcamp purchases and Apple Music streaming, so I haven’t had much track renaming to automate since then. (Well, besides downloading [jwz mixtapes](https://www.dnalounge.com/webcast/mixtapes/), but I wrote [a dedicated script](https://github.com/indirect/dotfiles/blob/main/dot_bin/executable_jwz-download) for that years ago.)

Then I ran across [the soundtrack to the recent official expansion for DOOM](https://www.youtube.com/playlist?list=PLAwkDjVcJePggQv6qM9cPWqrqoWkuD_h_) (not for DOOM (2016), for the original DOOM! in 2024!). I downloaded the FLAC version, and slowly recollected my pipeline for batch converting audio files and dropping them into iTunes to add to my cloud library. I had the track listing in text, so I naturally expected I would run `Track Parser (Clipboard)` to take care of naming and numbering all of the songs for me.

That’s when I discovered that the scripts had never been updated for Music.app. Several minutes of searching later, I found out that Dan is now the author of [Effective TypeScript](https://amzn.to/402nk5R), and his undergraduate iTunes AppleScripts don’t seem to be on his GitHub profile anywhere. I eventually turned up [the Google Code repo](https://code.google.com/archive/p/trackparser/) where he published the scripts, which is happily still available in archive form even though Google Code shut down years ago.

Armed with the AppleScript source files, I was able to puzzle my way through a bunch of error messages that mostly boiled down to “that’s a keyword now”. I eventually got the script working, and that’s when I realized… I messed up converting the FLAC files. As soon as I fixed the issue, the M4A metadata was  fully populated, and I didn’t need to parse the clipboard for track names after all.

At least I had fun tracking down the history of what happened to these scripts that were really significant to me once in the past, and updated them so anyone weird enough to be mass-editing song names today can do that more easily.

If that’s you, feel free to grab the `Track Parser` scripts from [the Releases page](https://github.com/indirect/trackparser/releases) in my new [trackparser GitHub repo](https://github.com/indirect/trackparser).
