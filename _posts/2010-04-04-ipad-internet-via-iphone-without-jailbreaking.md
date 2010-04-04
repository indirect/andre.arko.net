---
title: iPad internet via iPhone, without jailbreaking
layout: post
---
I am a big fan of the [iProxy](http://github.com/tcurdt/iProxy) project, which lets you get your laptop online via your iPhone without having to jailbreak it, provided you are (or at least know) someone in the iPhone developer program. I got my iPad today, and took it out to the park. Once I was there, I of course instantly wanted to look something up online. To solve this problem until the iPad 3G comes out, I figured out a mildly annoying hack that will suffice for the time being. So here's what to do:

  1.  Install iProxy onto your iPhone.
  
      I can't really help you with this part, but there's instructions in various parts of the internet.
  
  2.  Create a file named `socks.pac`, and put this in it:
  
          function FindProxyForURL(url, host) {
            return "SOCKS 10.0.0.1:8888";
          }

  3.  Upload that file to Air Sharing on your iPhone, so you can host it for the iPad later.
  
  4.  Get your iPhone and iPad onto the same wifi network.
  
      If you don't have any networks available, you might have to create one using a laptop. Once one of them has joined, the laptop doesn't have to be involved anymore.
  
  5.  Set up static IP addresses for the iPhone and iPad.
  
      I used 10.0.0.1 for the iPhone and 10.0.0.2 for the iPad.
  
  6.  Launch Air Sharing on the iPhone, and configure the iPad to use your socks.pac file.
  
      On the iPad, under the IP Address section, is HTTP Proxy. Choose "Auto", and type in the URL of the file you are sharing from the iPhone. For me, that was "http://10.0.0.1/socks.pac". Open Safari on your iPad and try to browse to a website. It will fail.
  
  7.  Run iProxy on your iPhone, and then try to browse to a website on your iPad again. Success!

For some reason, I didn't have very much luck getting applications other than Safari to use the SOCKS proxy that my iPhone was providing. But I was very happy to be able to surf the web on the bigger screen.