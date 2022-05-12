---
title: "Use a Thunderbolt 3 display from Windows"
layout: post
---
Since 2016, when the [LG UltraFine 5k was announced](https://www.anandtech.com/show/10798/lg-introduces-new-4k-and-5k-ultrafine-monitors), the only high-DPI 5k screens have been for (or inside) Macs. The external displays, all three of them, have used Thunderbolt 3. There have been some non-Thunderbolt 5k panels that are ultra widescreen, but none of them have been the high-quality high-DPI screen I wanted.

With the field narrowed down to the UltraFine 5k, the [Apple Pro Display XDR](https://www.apple.com/pro-display-xdr/), and the [Apple Studio Display](https://www.apple.com/studio-display/), I spent a lot of time wildly searching the internet trying to figure out some way to also use the monitor with my gaming PC. Everything I could find from searching basically boiled down to either “lol it’s impossible” or “you have to add a PCIe Thunderbolt card to your PC”.

I eventually found a passing reference somewhere on Twitter to “bi-directional” DisplayPort to USB-C cables, and that turned out to be the miracle I was looking for. With [a bi-directionable cable that supports DisplayPort 1.4](https://amzn.to/39WrlRp), you can drive an UltraFine 5k, an Apple Studio Display, or even an Apple Pro Display XDR at 6k and 60hz, directly from your graphics card’s DisplayPort port. The magic is provided by Display Stream Compression (DSC), which reduces the bandwidth needed down to a level that USB-C can sustain.

I turns out someone had [already written a blog post about this](https://ntk.me/2021/10/12/pro-display-xdr-on-windows-pc/), but I wasn’t able to find it when I was searching. Unlike that blog post, my simple one-cable connection also doesn’t support using the displays’ internal USB hub, or using any speakers or cameras that might be attached. I’m happy with that because I already have other speakers and a camera set up.

In the end, this post is partly a note so I can look this up later if I need to, and partly to try to spread the word that bidirectional DisplayPort cables exist and work with 5k and 6k displays. Hopefully future me, and others with this problem, can spend fewer days searching the internet and just [buy the cable](https://amzn.to/39WrlRp) and get on with their lives.
