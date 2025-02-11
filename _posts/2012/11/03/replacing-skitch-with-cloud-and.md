---
layout: post
title: "Replacing Skitch with Cloud and Alfred"
microblog: false
guid: http://indirect-test.micro.blog/2012/11/04/replacing-skitch-with-cloud-and/
post_id: 4971397
date: 2012-11-04T00:00:00-0800
lastmod: 2012-11-03T16:00:00-0800
type: post
url: /2012/11/03/replacing-skitch-with-cloud-and/
---
Recently, I was sad to discover that Evernote's purchase of Skitch has finally resulted in the dreaded "discontinuation of service" for the truly great Skitch.com service. While searching for a replacement, I briefly contemplated downgrading Skitch and setting up my own server for images. After a little more thought, though, I remembered how terrible the uptime was on the last personal service I ran, and decided to go with something hosted instead. [Cloud](http://cl.ly) is a neat service that provides super easy upload of text, audio, files, and even images. The screenshot integration, though, is what got me to take a serious look.

By combining CloudApp's upload hotkey with an Alfred extension that extracts direct image links, I was able to recreate my Skitch Pro workflow pretty closely. It doesn't provide the nice "scribble on your screenshot" functionality that the Skitch app does, but the workflow I settled on means I can use the new Skitch for that without having to upload to Evernote.

So, without further ado, here's the setup:

1. Install the Cloud Mac app. It's on the Mac App Store or free to download at [cl.ly](http://cl.ly).
2. Create a Cloud account (the paid accounts can even use a custom subdomain for links, if you like.)
3. Using the Keyboard sytem preference pane, change the keyboard shortcut ⌘⇧4 to copy the screenshot to the clipboard instead of saving it to a file on your desktop. Or just always use ⌘⇧⌃4 to take a screenshot.
4. Set a keyboard shortcut to upload the clipboard in CloudApp. I use the default, ⌘⌃C.
5. Install [this Alfred extension](https://cl.ly/0Q05361j243G/download/CloudApp%20Image.alfredextension).

Now you're set! To share a screenshot, push take your screenshot, hit ⌥⌃C and then run the Alfred action. Now you can paste a direct link to the image into Campfire or wherever you like.
