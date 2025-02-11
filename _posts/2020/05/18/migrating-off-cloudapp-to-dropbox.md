---
layout: post
title: "Migrating off CloudApp (to Dropbox + Dropshare)"
microblog: false
guid: http://indirect-test.micro.blog/2020/05/19/migrating-off-cloudapp-to-dropbox/
post_id: 4971965
date: 2020-05-19T00:00:00-0800
lastmod: 2020-05-18T16:00:00-0800
type: post
url: /2020/05/18/migrating-off-cloudapp-to-dropbox/
---
I've been using [CloudApp](https://getcloudapp.com/) since 2010. It was a pioneer in a service category that's incredibly busy today, full of companies like Droplr, Jumpshare, Dropshare, and honestly way more than I could possibly name. The concept is pretty simple: you get a keyboard shortcut and a menu bar icon that let you upload a screenshot or file, and your clipboard fills with a URL you can paste.

The screenshot taking and markup is more or less copied from an earlier app, Skitch. (RIP Skitch, you were amazing until Evernote bought you.) The appeal of "you take your screenshots and there is always a permanent link directly to them in the clipboard" made me feel like it was worth paying for.

### the good

When I started, it had a cleverly short url (`cl.ly`), [an open API](https://github.com/cloudapp/api), a native Mac app, multiple RubyGems. Later, I discovered that I was friends with someone who would listen to my complaints and feature requests (\<3 @lmarburger), and that made it even better.

Eventually, the service changed hands, sold to a holding company that believed they could turn it into a dramatically more profitable business. That's completely understandable, especially given my understanding that the tiny team wasn't even making a living from it at the time.

### the bad

Sadly, over the past few years, CloudApp has been incredibly pushy and aggressive about how much I should be using "CloudApp Teams". I don't need a team, and it absolutely sucks that you are showing me ads even though I pay $10/mo. 😠

After a while, teams wasn't even enough. The Mac app started aggressively telling me that I was using an obsolete version of CloudApp and I "need to upgrade soon". Calling it an upgrade was absolutely a lie: it was a completely different app, and much, much worse.

### the ugly

The new Mac app lost the ability to copy direct links to images to the clipboard, and didn't get it back for months. To add insult to injury, it also gained prominent buttons telling me to sign up for a team. Even today, every time I open the Mac app menu to see my uploaded files, the tiny modal window includes a prominent button that says "Need a TEAM? Sign up today!".

The new web app is... really, really bad. The old web app had search by file name, date, upload type, and even the colors present in the image. The new webapp has... nothing. It shows me 221 pages of uploads, in chronological order. I can't sort them, I can't search them, I can only click through all 221 pages hoping my eyes find the old upload I am looking for.

The old web app had an API, making me feel comfortable about keeping my files in someone else's service. If something went wrong, I could easily pull all my data out using a Ruby library maintained by the company itself, which is very reassuring. But this week, I found out that the new webapp doesn't have an API! They threw it away, and then said "Curious what you used the API for?" when I complained about it being gone on Twitter.

Even though the new web app launched 6 months ago, and still doesn't have search or an API, it has new features that CloudApp has put enormous effort into promoting: call to action buttons directly on uploads! So if I want to... sell someone something... from my uploaded screenshot... I can do that. This is the exact opposite of what I want in a personal file sharing service.

In a final bit of horror to me, as a web developer, I just noticed that the entire contents of every page on the new website is rendered directly from a Javascript string full of HTML. Apparently, adding a toggle between grid and list view requires sending two JS strings full of an entire page worth of HTML, and using an if/else statement to decide which HTML string to dump into the page to be visible. I shivered with horror just writing that. 😬

So today I'm screen-scraping the new webapp to get a copy of my uploads, to take them somewhere else. Unfortunately, "somewhere else" turns out to be a huge problem, too.

### the cloudapp bundle

CloudApp provides, in a bundle, these four things:

- Screenshot/video capture and annotation
- File uploads from a Mac menu bar app
- Permanent cloud storage
- URL shortening on my own domain

There don't seem to be any competitors that hit all four, which just... ugh, of course not, why would there be.

Droplr only allows custom domains on their enterprise plan. Jumpshare has been promising an API "very soon" for *eight years*. Dropshare has unusably bad annotation tools. CleanShot X doesn't offer a cloud service (yet).

### build-a-bundle

After giving up on the entire bundle, I started with Dropbox: I already pay for Dropbox, so can I get a Mac app that uploads to Dropbox and copies a share URL to the clipboard? Confusingly, the answer is Dropshare: the Mac app is also a standalone purchase, and works with any cloud storage, including Dropbox.

CleanShot X is by far the best capture and annotation tool, surpassing even CloudApp in my estimation. It is also available as a standalone purchase, so I can drag directly from CleanShot to Dropshare and have something that seems pretty good, I guess?

### oh no, url shortening

With that, I have annotation, menu bar uploads, and cloud storage, so I just need URL shortening for the share links. Amazingly, Dropshare also supports URL shortening, with built-in support for Rebrand, Bitly or custom services. As great as that is, Rebrand and Bitly charge $29/mo for their cheapest plans, so, uh, that's not gonna happen. Maybe a custom shortener service that I run myself?

After two hours of trying to find a URL shortener that I could easily deploy to Heroku... I gave up. There are thousands of URL shorteners, some of them even seem actually quite nice, and none of them can be deployed in less than 15 minutes.

### tl;dr

As long as you have cloud storage that you already pay for, like Dropbox, Box, OneDrive, or a cloud server (S3 and SSH both work), you can get pretty close to replacing CloudApp for Mac like this:

- Buy [CleanShot X](https://getcleanshot.com/) for $29
- Buy [Dropshare](https://dropshare.app/) for $25
- Connect Dropshare to your cloud storage
- Stop paying CloudApp $10/mo
- Profit?

If you find a good URL shortening option, [let me know](mailto:andre@arko.net).
