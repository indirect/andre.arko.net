---
layout: post
title: "Safari extensions in Lion"
microblog: false
guid: http://indirect-test.micro.blog/2011/07/23/safari-extensions-in-lion/
post_id: 4971367
date: 2011-07-23T00:00:00-0800
lastmod: 2011-07-22T16:00:00-0800
type: post
url: /2011/07/22/safari-extensions-in-lion/
---

### tl;dr

Install [Safari Omnibar][so] from the provided [installer package][ip], and then download [my customized version][mcv] and install it to `/Library/Application Support/SIMBL/Plugins/`. Edit keywords in the file `SafariOmnibar.bundle/Resources/SearchProviders.plist`. Tada, now you have a single location bar for URLs, searches, and keyword searches.

[so]: https://github.com/rs/SafariOmnibar
[ip]: https://github.com/downloads/rs/SafariOmnibar/Safari%20Omnibar-1.1.pkg
[mcv]: http://cl.ly/3o023c4026201S060p27

**Update**: So as of today, you can just [install SafariOmnibar 1.2][12] now and then update SearchProviders.plist yourself. If you'd like to, you can [copy my plist][sp].

[12]: https://github.com/downloads/rs/SafariOmnibar/Safari%20Omnibar-1.2.pkg
[sp]: https://gist.github.com/1101586

Install [the Safari extension version][sectf] of ClickToFlash, get video downloading for free.

[sectf]: http://hoyois.github.com/safariextensions/clicktoplugin/

### The state of Safari extensions in Lion

I have been a dedicated user of [Saft][saft], [Keywurl][kw], [GlimmerBlocker][gb], and [ClickToFlash][ctf] for years. When I upgraded to [Lion][lion], however, I discovered that none of them work.

Saft mainly provided automatic restoration of open windows when quitting and restarting Safari. Keywurl provided searching directly in the location bar, and keyword searches to limit the search to specific sites. GlimmerBlocker provided ad-blocking and page transformations like a "download video" link on YouTube pages.

When I upgraded to Lion, none of them worked.

GlimmerBlocker was updated pretty quickly, but it turns out that YouTube download links download corrupted video files. Keywurl and Saft haven't been updated yet, and will probably take time. ClickToFlash likewise only supports Snow Leopard, and tickets reporting issues with Lion haven't been responded to for months. So, we need replacements.

Happily, Saft's biggest feature (restore open windows) is now built in to Safari on Lion. Theoretically, GlimmerBlocker supports keyword searches in the location bar, but I couldn't figure out how to configure it and eventually gave up. I was really excited to find [SafariOmnibar][so], which merges the search and location bars into a single bar that supports both. At that point, I only needed keyword searching to replace Keywurl completely.

I was pretty excited to discover that keyword searches were already implemented in git, so I checked it out and compiled [my own release][mcv] of version 1.1 with keyword support. Then my only task was to import the Keywurl keyword plist into the SafariOmnibar keyword plist format. Now I have a complete replacement for Keywurl, albeit without a UI for adding new keywords.

Unable to discover any obvious options for downloading YouTube videos with a quick Google search, I gave up on that and went to replace ClickToFlash. There is [a Safari extension version][sectf] that works quite well in Safari 5.1. It not only replaces Flash videos with HTML5 videos if possible, it even provides a "Download video" contextual menu item on those videos.

So at this point I'm pretty happy. The combination of SafariOmnibar and ClickToFlash replaced all of the extension functionality that I had previously been using, albeit coming from entirely different software. Woo.

[saft]: http://haoli.dnsalias.com/saft/
[kw]: http://alexstaubo.github.com/keywurl/
[gb]: http://glimmerblocker.org/
[ctf]: http://clicktoflash.com/
[lion]: http://www.apple.com/macosx/
