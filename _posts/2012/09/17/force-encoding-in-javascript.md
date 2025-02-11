---
layout: post
title: "Force encoding in JavaScript"
microblog: false
guid: http://indirect-test.micro.blog/2012/09/18/force-encoding-in-javascript/
post_id: 4971395
date: 2012-09-18T00:00:00-0800
lastmod: 2012-09-17T16:00:00-0800
type: post
url: /2012/09/17/force-encoding-in-javascript/
---
So first, I should probably set the scene: in a special-purpose browser, automated and driven by JavaScript, there was a string that made no sense. Anytime it should have contained an apostrophe, it produced invalid JSON. Why would it do that, you ask? Well, after far too long digging into the way that smart quotes are represented in Unicode, I finally figured it out. A single left apostrophe, also known as \u2019, takes up three bytes. The third byte happens to be \x19, the obscure ^Y control character. Control characters aren't allowed in JSON strings, and so things exploded.

Some investigation of the website in question turned up the encoding problem, which was a `meta` tag that declared the page was encoded as ISO-8859-1. The actual code writing out the contents of the page, however, was apparently set to output UTF-8. As it turns out, if those three bytes that represent an apostrophe are decoded as ISO-8859-1, they look like `â€˜` in a browser.

Finally knowing what the problem was, I was still pretty stumped -- how can I take the string containing UTF-8 bytes, but interpreted as ISO-8859-1, and force the encoding to UTF-8 instead? It would be trivial in Ruby 1.9, where the String class has a `force_encoding` method, or in Ruby 1.8, where I could just use the Iconv library. But JavaScript, as a language, doesn't even have a concept of string encodings! Strings are all stored in UTF-16 or UCS-2 format, and so there's no way to manually force a string to be interpreted as a certain encoding.

Right as I was getting ready to despair, though, I had an inkling of an idea. I realized that one of the blog posts I had just read, about [encoding and decoding UTF-8 in JavaScript](http://ecmanaut.blogspot.com/2006/07/encoding-decoding-utf8-in-javascript.html), might provide me with a way to decode the bytes I had as if they were UTF-8 bytes. Pretty surprisingly (at least to me), you can use `encodeURIComponent()` to turn a stream of bytes into a percent-escaped stream of bytes, and then use `unescape()` to interpret the stream of percent escaped bytes as UTF-8. So I tried it, and it worked perfectly.

```javascript
function forceUnicodeEncoding(string) {
  return unescape(encodeURIComponent(string));
}
```

So after all that, I can happily inform you that you _can_ force the encoding of a JavaScript string! But only to UTF-8, and only when the encoding has mistakenly been declared to be something else. Lucky for me, that's exactly what I needed.
