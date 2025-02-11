---
layout: post
title: "Secure Passwords Without Punishing Rules"
microblog: false
guid: http://indirect-test.micro.blog/2019/01/16/secure-passwords-without-punishing-rules/
post_id: 4971632
date: 2019-01-15T16:00:00-0800
lastmod: 2019-01-15T16:00:00-0800
type: post
url: /2019/01/15/secure-passwords-without-punishing-rules/
---

Building secure web applications is really, really hard. One of the biggest attack vectors in modern webapps is passwords. Even if we set aside the dangers of phishing or other more sophisticated attacks, passwords themselves are a source of danger, between simple passwords, guessable passwords, shared passwords among family members or teammates, and reused passwords across accounts.

Security teams have traditionally responded to the dangers inherent in passwords by imposing onerous rules and requirements: perhaps your password has to be between 6 and 15 characters, must contain at least one number, at least one uppercase letter, at least one lowercase letter, and at least one symbol. (Even worse, there's usually a secret list of forbidden symbols they won't show you until you try to use one, which happens to me all the time.)

In higher security environments like workplaces or banking, it’s very common to make things even worse by expiring passwords every 90 (or even every 30!) days, as well as tracking previous passwords to ensure that previous passwords are never used again.

Unfortunately, all the research we have about password policies indicates that they don’t help with security. At all.

Punishing users with harsh requirements most commonly results in a sticky note underneath the keyboard or even stuck to the side of the monitor with the latest password written on it for anyone to see—which completely defeats the point of passwords in the first place.

Instead of brutal password requirements that defeat their own purpose, follow the evidence-based [guidelines issued by the National Institute of Standards and Technology](https://pages.nist.gov/800-63-3/sp800-63b.html#sec5). The full document isn't hard to understand, and their recommendations are clear:

- Never require special characters, including upper, lower, digit, or symbol
- Never prohibit certain characters
- Never automatically expire passwords
- Never allow passwords that have previously been exposed in a data breach

In the digital wastelands of 2018, there have been so many data breaches that it is that last requirement that truly keeps your users' accounts safe and secure. Using a password that has been leaked in a previous breach means that it will be easy to guess or brute force, because it's already out there in lists of passwords to try.

Simply blocking passwords that are known to have been leaked means that your users will have the highest possible protection a password can offer: only a keylogger or a brute force attack from scratch can break into their account.

With inspiration from [the `pwned` gem](https://github.com/philnash/pwned), [the Java library `passpol`](https://github.com/codahale/passpol), and [the Javascript library `nbp`](https://github.com/cry/nbp), we've created a library you can use to follow the NIST password guidelines (and keep your accounts safe) without punishing your users with impossible password guidelines: [`unpwn`](https://github.com/indirect/unpwn). 

The `unpwn` gem takes a hybrid approach to validating passwords. First, it checks the proposed password against the top one million most common passwords extremely quickly, and with no network requests, by using a bloom filter.

[Bloom filters](https://llimllib.github.io/bloomfilter-tutorial/) are both very cool and an extremely good fit for this particular problem. We want to know if the proposed password is included in the top one million leaked passwords, but that list is almost 100mb and checking passwords against it would take a long time. The bloom filter included with this gem is only 1.7mb, but allows us to check passwords as if we had the entire top one million list available locally.

If the proposed password passes the bloom filter check, the gem then uses the `pwned` gem to make a call to the `haveibeenpwned` API.

The `haveibeenpwned` API offers the most comprehensive public database of leaked passwords in existence, and the API is very clever. Your application doesn't send the possible password to the API. Instead, it hashes the password and sends just the first few characters of the hash. The API returns all of the known password hashes that start with those characters, and your application can then check to see if the proposed password is one that has already been hacked in the past.

[Give `unpwn` a try](https://github.com/indirect/unpwn/) today, and keep your users safe without punishing password rules. We plan to add direct integration with [Devise](https://github.com/plataformatec/devise) in the future. If you try it out, or you have ideas for how to improve `unpwn`, we'd love to [hear from you](https://github.com/indirect/unpwn/issues/new)!

<small>
This was cross-posted from [the Cloud City blog](https://www.cloudcity.io/blog/2019/01/08/secure-passwords-without-punishing-users/), where we offer this kind of advice and expertise as software consultants. [Contact us](https://www.cloudcity.io/ruby-development/) to learn more about what we can do for your team.
</small>
