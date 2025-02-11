---
layout: post
title: "Custom styles for Notion"
microblog: false
guid: http://indirect-test.micro.blog/2020/05/18/custom-styles-for-notion/
post_id: 4971964
date: 2020-05-17T16:00:00-0800
lastmod: 2025-02-10T22:18:58-0800
type: post
images:
- https://cdn.uploads.micro.blog/205145/2025/54eee2f97f.jpg
photos:
- https://cdn.uploads.micro.blog/205145/2025/54eee2f97f.jpg
photos_with_metadata:
- url: https://cdn.uploads.micro.blog/205145/2025/54eee2f97f.jpg
url: /2020/05/17/custom-styles-for-notion/
---

I recently helped [someone with strong aesthetic preferences](https://instagram.com/sailorhg) set up a custom Mac app for [Notion](https://notion.so). It’s approximately the same thing you could get with a browser extension like [Stylus](https://add0n.com/stylus.html), but it retains the convenient Electron app parts of getting its own app icon and its own separate cookie storage. 

Luckily enough, someone else had [already figured out how to do it on Linux](https://github.com/Peter-JanGootzen/notion-custom-css-builder), which was close enough for me to [reuse most of the work for Mac](https://github.com/indirect/notion-custom-css-builder).

Custom CSS in Notion turned out to be more interesting than I expected, since almost all of the CSS in the app is inlined directly into `style` attributes. That makes it… awkward to apply site-wide styles using CSS files.

Changing the font to Latin Modern Mono Italic turned out to be easy enough, but led to a somewhat unexpected result: slanted emoji. 😆 Adding an override for `span[role=image]` turned out to be enough.

Changing colors, though, was a real challenge. There’s no class, there’s no element, there’s no attribute… wait. The `style` attribute is always going to have the color in it, right? You can select based on “attribute value contains”, right? Turns out yes, you can select elements based on the inline style that gives them the color that you want to overrule. 😂

This is probably the most cursed CSS I have ever written.

```css
div[style*="rgb(173, 26, 114)"] {
    color: #F9D2EE !important;
}
```

It works, though!

<img src="uploads/2025/54eee2f97f.jpg">
