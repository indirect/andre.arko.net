---
title: "Everyone Knows a Lunar Cycle is 28 Days"
layout: post
---
<h3 class="subtitle">or, falsehoods werewolves believe about time</h3>

<small>This blog post was eventually given as a talk at [@bangbangconwest](https://bangbangcon.com/west). The [slides](https://speakerdeck.com/indirect/how-to-calculate-the-phase-of-the-moon-very-very-badly) and [video](https://www.youtube.com/watch?v=syx4pWxu_sk) are also available.</small>

A few years ago, I collaborated with [@sailorhg](https://twitter.com/sailorhg) to make an iPhone app: a lunar calendar (for witches and werewolves), [Luna](https://itunes.apple.com/us/app/luna-lunar-calendar-for-witches/id1052484934). She also made a swanky website for it over at [witchy.co](http://witchy.co).

She created the concept and visual design, as well as managing the freelancers who provided the music and lunar horoscopes. I wrote the code, excited to have the chance to ship a mobile app and learn Swift.

Fast forward a few weeks, and I just couldn’t find a library in Swift or Objective-C to calculate the current phase of the moon. Thinking I could crib from one of the many public C or JavaScript implementations, I tried to port one. And then another. And then another. After trying to port three separate algorithms, and never once getting results that were anywhere close to the actual phase of the moon, I gave up.

At that point, I read on Wikipedia that lunar cycles are exactly 27.321661 days long and had an epiphany: I could use the precise date and time of the most recent full moon, adding 27.321661 days over and over to predict the phase of the moon in the future.

Amazingly, this worked! For the very first time, my predicted moon phases lined up with the many free lunar calendars on the internet. I was extremely relieved, and the app went live on the app store.

Fast forward two years: the app has sold three copies per week, and has 150 active users. @sailorhg gets the nicest, sweetest message on Twitter from someone who says, approximately, “I am a practicing wiccan and I LOVE your app but also it is wrong about when the full moon is, is there any chance you could fix it?”.

Hearing this, I open the app myself (for the first time in about 18 months) and discover that the app is _three days off_. I knew that there would eventually be compounding error from multiplication with floats, but that was way, way more error than seemed reasonable.

Hours of investigation later, I discovered that my entire premise was hilariously wrong.

First of all, 27.321661 is the average length of the _siderial_ month. I didn't know exactly what that meant when I used the number, but it sounded like it was related to astronomy! It turns out the word sidereal comes from the Latin word _sidera_, which means "star".

Knowing that, it will now make sense to hear that a sidereal month is the time it takes for the moon to return to the same position among the stars in the sky. Unfortunately, the moon's illumination is determined by position relative to the sun and earth, so the length of a siderial month is totally useless for calculating moon phases.

A full cycle of lunar phases that we see on earth is called a _synodic_ month, the amount of time it takes for the moon to return to the same position relative to the earth and sun. Synodic and siderial months are different lengths because 1) the earth moves around the sun while the moon moves around the earth, and 2) the earth and moon's orbits are both ellipses!

(You can learn more about how the positions of the sun and earth determine the moon's illumination at the website made by [@sailorhg](https://twitter.com/sailorhg) for her talk at HawaiiJS: [witchy.co/trig](https://witchy.co/trig).)

So now that we’re using the average length of a synodic month, 29.530587981 days, can we calculate accurate moon phases? Still no. We know the average length of a synodic month, but it's an average. Almost no individual synodic months actually last 29.530587981 days.

At this point, I had painfully rediscovered that [averages don’t actually exist](https://99percentinvisible.org/episode/on-average/). In another talk I've given, [Lies, Damn Lies, and Metrics](https://speakerdeck.com/indirect/lies-damn-lies-and-metrics-1), I call this out by saying "averages are lie-candy for your brain". Even though I already knew that, I still fell for the idea that the average would resemble reality!

If we could wait decades (or centuries!) individual differences in lunar cycle lengths will eventually average out... but that doesn’t help Wiccans in the year 2018. At the moment that message arrived, the full moon in the real world arrived three days after the app’s perfectly average spherical moon in a vacuum.

Fortunately, Swift matured pretty significantly while my app was getting more and more wrong. A few seconds of searching provided several open source astronomical libraries implemented entirely in Swift.

Within a few hours, I had a working function call that told me the exact phase of the moon with 64-bit precision. `0.0` for a full moon, `0.5` for a new moon, up to `0.9999` right before the next full moon, and then wrapping back around to `0.0`.

That’s when I discovered my other fatal flaw. When putting together the visuals for the calendar view, I used the (beautiful!) [Weather Icons](https://erikflowers.github.io/weather-icons/). As you might expect, there are exactly 28 icons. Everyone knows a lunar month is 28 days long, right?

Since I knew that lunar months were actually 27.321661 days long, I converted lunar months into icons with a relatively straightforward formula: `percent_of_lunar_month * 27.321661 / 28`. Then I took that number, and used it to index into an array of the 28 icons.

As you might have guessed by now, this was a total disaster. For one thing, I had now learned that individual lunar months might be as short as 25 days, or as long as 30. Which day should you show the new moon on when two (or even three!) entire days round to an integer icon index of `0`?

As a calendar to help you plan your life around significant lunar events, Luna was still an absolute failure. You might see a new moon on two or even three consecutive days, but you also might hit a month where you never see a full moon at all!

I spent _days_ trying to handle the edge cases in my approach. It turns out, when every month has differently-sized days, there is no single list of numbers you can use to catch all the lunar events.

Eventually, I gave up, and started preparing to ship the app, figuring that only one or two errors per month was a lot better than everything being wrong by three days.

Right before shipping a still-broken app, I realized that I could completely solve the problem by inverting my calculations. Instead of calculating the percentage phase of the moon at noon local time, I needed to calculate the phase of the moon at the midnight that started the day and the midnight that ended the day.

Armed with the starting and ending points of each day, I could check to see if the points I cared about would happen on that day... and only on that day. For example, knowing that the day started at moon phase `0.46` and ended at `0.51` meant that I could be _sure_ that day was the new moon. Even better, no other day would be counted as the new moon, no matter how long the lunar month was.

Considering how little code went into this application overall, I feel like I learned an unusually high amount about programming, astronomy, and bad assumptions that seem reasonable at the time.

Today, Luna’s astronomical calculations are accurate to within a few minutes, each quarter of the moon falls on the same day as other moon calendars, and it even stays accurate when the date is manually jumped years into the past or future. It only took three years. 😅

<small>
_Thanks to Chris Dary for the subtitle, Kyle Kingsbury for inadvertently reminding me that this happened, and to all of Kyle, Chris, Coda Hale, Marc Hedlund, Nelson Minar, Sunah Suh, and Daniel Espeset for enjoying this story so much that I was motivated to publish it._
</small>

<small>
_Updated 2019-02-25 to add an explanation of siderial versus synodic months, link to [witchy.co/trig](https://witchy.co/trig), and link to the slides from !!ConWest._
</small>
