---
layout: post
title: "TextMate strip whitespace and preserve cursor position"
microblog: false
guid: http://indirect-test.micro.blog/2009/12/27/textmate-strip-whitespace-and-preserve/
post_id: 4967465
date: 2009-12-27T00:00:00-0800
lastmod: 2009-12-26T16:00:00-0800
type: post
url: /2009/12/26/textmate-strip-whitespace-and-preserve/
---
There are a lot of bundles and macros out there that exist solely to strip trailing whitespace from the current file whenever you save it. Unfortunately, (almost) all of the whitespace stripping options that I have found share a fatal flaw: they move the cursor to the beginning of the line. This seriously messes with my head, as I never expect saving the file to move the cursor.

I somehow wound up with a bundle that doesn't move the cursor while it strips whitespace, so I'm posting it here for myself (and anyone else who doesn't like their cursor jumping around).

[Strip whitespace on save bundle for TextMate](Strip%20Whitespace%20on%20Save.zip)
