+++
title = 'Chrome “Print to PDF” and headless <code>--print-to-pdf</code> aren’t the same!'
slug = 'chrome-headless-print-to-pdf'
date = 2025-05-25T02:39:27-07:00
+++

For some recent client work, I needed to create a PDF out of a webpage. I already had CSS to create the underlying design, so all I really needed to do was set the page size, and add some header and footer images to each page.

As of late 2024, all the major browsers now support the [`@page`](https://developer.mozilla.org/en-US/docs/Web/CSS/@page) CSS rule, which works like the `@keyframes`  rule in that it lets you created named pages, and give those pages set dimensions and margins. Then you can apply that rule to some DOM element using the `page:` CSS property. As long as you set `page-break-before:` (or `after` or `inside`) to put the elements on a new page, those rules will apply to that printed page.

There are some big and annoying caveats to all of this, though.

First, styling margins. There are rules for three sections per side plus four corners, but if all you need is a per-page header and footer you can just use `@top-center` and `@bottom-center`. Chrome is the only browser that supports any of those at-rules, so you are forced to use Chrome, and only Chrome, to generate your PDF. Hope that’s ok.

Second, previewing any `@page` CSS while developing it is an absolute nightmare. The Chrome dev tools claim to allow you to preview print CSS, but that preview mode just sets the media-type to “print” and then renders directly into the same regular browser window, with no pagination. You have to actually open the Print… dialog to even see a thumbnail of how the page breaks and page styles are going to render. And you have to fully print (even if only to a saved PDF) to see anything bigger than a thumbnail of the first page.

The closest I managed to get to actually having a preview through all of this was by using [Paged.js](https://pagedjs.org/documentation/1-the-big-picture/ "Paged.js: W3C paged media polyfill"), a polyfill for the entire W3C paged media specification, which happens to have an option to use Javascript to render a preview of the pages into the browser being polyfilled. Unfortunately, Paged.js and Chrome disagree about several important aspects of how to interpret the W3C paged media specification, and so in the end I was reduced to printing to PDF and opening the PDF in Preview.app over and over again until I had the CSS fully correct.

Finally, the bit that drove me to write this blog post is that Chrome can’t even agree with itself about how the margin rules are supposed to work. If you open Chrome in graphical mode and choose Print…, you will get a different result than if you run the exact same copy of chrome from the command line with `--headless --print-to-pdf`.

The first problem is that graphical Chrome will not respect the page dimensions that you’ve set in your CSS, and will instead use the size of the window to decide how wide your PDF pages should be. If you render using headless Chrome, it seems like you’ll actually get the page dimensions you chose.

Much worse, though, is that that headless Chrome will silently refuse to fetch any resources referenced in your `@page` CSS rules, so your `url()` images are fully invisible. For once, graphical Chrome and paged.js even agreed on how the images in my page margins ought to look, making me even more surprised and confused by the way headless Chrome insisted those images did not exist at all.

After a huge diversion into [using Puppeteer to print](https://pptr.dev/api/puppeteer.pdfoptions), I was forced to conclude that printing through Puppeteer and printing directly from `chrome --headless` use the same codepaths, and it didn’t help or matter which one I did.

In the end, I was saved by Nathan Friend’s blog post about [PDF Gotchas With Headless Chrome](https://nathanfriend.com/2019/04/15/pdf-gotchas-with-headless-chrome.html), which revealed that data URLs that included the entire content of the image as base64 would actually work. Some painful CSS fiddling later, my PDF started rendering correctly in headless mode, and I was able to write a script to wrap `chrome --headless --print-to-pdf` and automate the creating and saving of the PDF.
