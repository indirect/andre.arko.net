---
title: "Apple Studio Display from a PC without Thunderbolt"
layout: post
---
So maybe you have an Apple Studio Display (or possibly even an Apple Pro XDR Display), and you followed [my instructions from last time](/2022/05/19/use-a-thunderbolt-3-display-from-a-windows-pc/) to connect your display to your PC. You may have noticed a shortcoming: it’s impossible to adjust the brightness of the monitor from your Windows PC. Or maybe you noticed that the built-in webcam and speakers on your Studio Display don’t do anything.

In theory, USB-C can provide both DisplayPort for a monitor and a USB channel for software brightness control, the monitor’s USB hub, camera, speakers, etc. In practice, there seems to be only one cable in the world that is a single combined USB-C on one end and DisplayPort 1.4 + USB on the other end. That cable is the [Belkin Charge and Sync Cable for Huawei VR Glass](https://www.belkin.com/us/support-article?articleNum=316883). Since the Huawei VR Glass is only sold in China, that cable is also only sold in China.

Several visits to Ali Express and other generic commerce websites later, I spent $90 on this cable plus shipping and waited just over three weeks for it to arrive. The outcome, though, is surprisingly solid.

After I downloaded the latest Boot Camp image using [Bombardier](https://github.com/ninxsoft/Bombardier) and then followed [these instructions to install the Boot Camp drivers](https://nielsleenheer.com/articles/2022/using-the-apple-studio-display-on-a-windows-machine/), the Apple Studio Display not only had working brightness controls, it worked perfectly as both speakers and camera for the PC.

If your PC doesn’t have a Thunderbolt card, this seems like a genuinely good option to get full resolution and hardware support for Apple displays on your PC. It also seems like it's probably the only option?
