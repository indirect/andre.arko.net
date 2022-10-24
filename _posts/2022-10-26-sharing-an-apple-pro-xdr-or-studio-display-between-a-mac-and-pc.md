---
title: "Sharing an Apple Pro XDR or Studio Display between a Mac and PC"
layout: post
---
During the last episode of monitor shenanigans, I figured out how to [connect my PC’s Nvidia GeForce GPU to an Apple Display](/2022/10/24/apple-studio-display-from-a-pc-without-thunderbolt). The new challenge began when I realized that I wanted to switch back and forth between my M1 Mac and my PC by pushing a button, instead of by standing up, moving the monitor, and changing the cable plugged in to the back.

After an enormous amount of research, it seemed like I would probably be able to use the [CKL-62DP-4](https://cklkvm.com/products/ckl-2-port-usb-3-0-kvm-switch-displayport-1-4-8k-30hz-for-2-computers-1-monitor-pc-screen-keyboard-mouse-peripheral-audio-sharing-selector-box-with-all-cables-62dp-4) KVM switch, which explicitly supports the DisplayPort 1.4 standard needed for 5k or 6k screens at 60hz. So I ordered the KVM, waited two weeks for it to arrive, and connected everything up using my existing cables. It even almost worked!

I was able to switch an Apple Pro XDR Display and an Apple Studio Display between a 14" MacBook Pro (M1 Max) and and a Mac Studio (M1 Ultra) using [this CKL KVM](https://cklkvm.com/products/ckl-2-port-usb-3-0-kvm-switch-displayport-1-4-8k-30hz-for-2-computers-1-monitor-pc-screen-keyboard-mouse-peripheral-audio-sharing-selector-box-with-all-cables-62dp-4), using two generic USB-C to DisplayPort cables from the Macs, and sending the output to the Studio Display with [this bi-directional DisplayPort to USB-C cable](https://rads.stackoverflow.com/amzn/click/com/B08BY78C42).

The problem arose with one Mac and one PC—the one configuration that I actually want to use. Plugging in the PC works great. Plugging in the Mac works great. Switching from the Mac to the PC works great. Switching from the PC to the Mac… doesn’t work at all. The screen never comes back on, and the monitor has to be unplugged and replugged to start working again.

Since I was never able to get the KVM to work with one Mac and one PC, I kept scouring the internet for things that might meet my needs. I eventually found [this unknown brand USB-C switch](https://rads.stackoverflow.com/amzn/click/com/B092VHC166), with a lone review mentioning that it had worked to switch between a PC and a Mac. When it arrived, I connected the switch to my Mac with [this USB-C cable](https://rads.stackoverflow.com/amzn/click/com/B07X31FG6Z) and to the GTX 3080 in my PC with [this DisplayPort to USB-C cable](https://rads.stackoverflow.com/amzn/click/com/B07R1NBCXK).

Shockingly, it worked perfectly. After the amount of cables, devices, and configurations that I tried while attempting to get the CKL KVM to work, I had thought maybe that was impossible, so it was a big relief.

Unfortunately, I couldn’t figure out a way to get the fancy Belkin cable that adds a USB connection (in addition the the DisplayPort) to work through the switch—the PC says there is a USB error and only the display works, with no speakers or camera.

Since the switch doesn’t include a true KVM, you might need to also add a [regular USB switch like this one]([https://www.amazon.com/UGREEN-Selector-Computers-Peripheral-One-Button/dp/B01MXXQKGM]) if you want to share a single keyboard and mouse between the two machines.

That was enough to meet my needs, and so I have actually settled on that as my permanent setup, with no camera and speakers from the PC, since I have a different camera and speakers that I prefer to use.
