---
title: A Tale of Two ‘Y’s
layout: post
---

Today marks a momentous occasion: today, [scheduled Do Not Disturb mode on iOS starts working again](http://support.apple.com/kb/TS4510)! While the exact reasons that the feature stopped working between January 1 and January 7 are unlikely to ever be explained, investigating date bugs during the new year led me to discover a fascinating (and horrifying) aspect of dates on modern computers: the [ISO 8601](http://en.wikipedia.org/wiki/ISO_8601) [Week Date](http://en.wikipedia.org/wiki/ISO_week_date).

The best (or worst, really, if you're a programmer) part of the Week Date is the Week Year -- it's a four-digit year that looks identical to the regular year. Except between December 28th and January 4th, when it might be one year later or one year earlier than the regular year. Awesome, right?

In Ruby, or C, or any language that uses `strftime()` to format dates, it's not that hard to make sure that you get the regular year instead of the week year. According to the [IEEE standard](http://pubs.opengroup.org/onlinepubs/009695399/functions/strftime.html), `%Y` and `%y` are both the regular year (in four and two digits, respectively), while `%G` and `%g` are the week year. Where it gets tricky is in other languages, like Objective-C, that use [Unicode date format patterns](http://www.unicode.org/reports/tr35/tr35-25.html#Date_Format_Patterns). In those strings, `mm` represents the minute, and `MM` represents the month. `DD` will print the two-digit day of the year, while `dd` will print the two-digit day of the month. So, to get the month and day, you use a string like `MM-dd`. With that precedent, you might think that adding the year would mean using `YYYY-MM-dd`. Unfortunately, in a case of horrible ambiguity that is extremely hard to catch in advance, `YYYY` is the week year, while `yyyy` is the regular year.

At that point, the main way to find out that you're using the wrong capitalization in your pattern is to notice that your application thinks it's a different year for a few days around the new year. And that seems bad. So everybody that uses date format patterns: write a script that will complain about uses of `YYYY`. Seriously. You'll probably need it later.

<p class="aside">Reposted from the <a href="http://dev.mavenlink.com/blog/2013/1/9/a-tale-of-two-ys">Mavenlink Dev Blog</a>.</p>