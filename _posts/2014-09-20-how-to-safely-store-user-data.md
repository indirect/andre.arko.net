---
title: "How to Safely Store User Data"
layout: post
---

So, you have a web application, and you want to store some data "securely". Right now, you're you probably thinking "I know this already, we should encrypt it!". No.

Encryption is a last ditch option, and the least secure of the legitimate options for handling sensitive data. Only do encryption if you absolutely have to and there is no other option. Let's look at all the options for secure storage, and which one you should use. We'll start with the better options.

### Don't store it

First option: don't. Don't store it, don't look at it, don't let employees see it, don't let yourself see it. The only way for the data to be absolutely secure is if you absolutely don't have it. There's a pretty good FAQ about the problems with storing data at [plaintextoffenders.com](http://plaintextoffenders.com/faq/devs), but the short version is: do everything you can to not store things. It is not possible to lose data that you don't have.

### Use bcrypt

If you need to authenticate someone or something, _don't store passwords_. [Use bcrypt](http://codahale.com/how-to-safely-store-a-password/). Never store your users' passwords in plaintext. Never store your users' passwords encrypted. Never store your users' passwords, period. Use bcrypt to hash the password, and store the hash. If you're writing a Rails app, use [bcrypt-ruby](https://github.com/codahale/bcrypt-ruby) or [devise](https://github.com/plataformatec/devise). If you're not using Rails, use the bcrypt library for your language.

Bcrypt is deliberately designed to be adjustably hard: as computers get faster, the password hashes stored in the database can be replaced by hashes that are harder to calculate. This keeps the time needed to brute force the password impossibly long, even as computers get faster. Whenever you use bcrypt, increase the bcrypt difficulty factor as high as you can without inconveniencing your users when they log in. Whatever difficulty takes your servers a few hundred milliseconds is probably about right. Every year or two, benchmark your password hash calculations, and [increase the difficulty](http://security.stackexchange.com/questions/15847/is-it-possible-to-increase-the-cost-of-bcrypt-or-pbkdf2-when-its-already-calcula) if necessary.

### Replace foreign keys with hashes

If you store data in your database that isn't an actual secret, but can be dangerous when connected to a specific user, don't store the foreign key. This is especially relevant for things like a search history, or a history of browsed items, or anything that could be abused by staff or hackers with access to the data. If you really need to to connect two pieces of sensitive data, don't store the foreign key directly. 

When I worked at [Wesabe][wesabe], we stored financial transactions, but we didn't save the foreign key that connected a user profile to their accounts and transaction records. Instead, we used a hash of user information, including their password, as the foreign key. Since we didn't store the password, [even employees couldn't connect purchases to a name or email address][blog.wesabe.com].

[wesabe]: http://en.wikipedia.org/wiki/Wesabe
[blog.wesabe.com]: http://web.archive.org/web/20100731183631/http://blog.wesabe.com/2007/02/23/safeguarding-your-data-the-privacy-wall/

If you must store sensitive data, don't allow that data to be connected to any names or email addresses. Instead, store a hash that can be reconstructed when the user logs in with their password. Only keep that hash in memory, and expired it after a few minutes of inactivity or as soon as the user logs out, whichever comes first.

### Keyless encryption

We ran into another, harder problem at Wesabe as well: storing usernames and passwords for bank accounts. Wesabe used those credentials to simply download a list of transactions, but they could also be used to send payments or transfer money out of accounts. We did encrypt those usernames and passwords, but we deliberately did it using a key generated from the user's password.

Similar to the foreign key hashes I mentioned above, this approach meant that even Wesabe employees couldn't decrypt a user's credentials. When a user logged in, their Wesabe password would be used to regenerate the key that could decrypt their bank usernames and passwords. Then, the bank usernames and passwords would be used, once, to update their transaction data stored in Wesabe. The credentials were only stored in memory, and never saved, logged, or accessible in any other way.

This was a great first-pass approach to the problem of keeping secrets, but we came up with an even better one later. I'll talk about that option next.

### Pubkey encryption

In short, we realized that features we wanted (primarily sharing data between family members' accounts and background transaction updates) required better access controls for secret data. Wesabe didn't last long enough to use it, but we (and by we, I mean almost entirely [Coda Hale](https://twitter.com/coda) and [Sam Quigley](https://twitter.com/emerose)) managed to release a [proof of concept implementation](https://github.com/wesabe/grendel) that we called Grendel.

Grendel uses a public key encryption scheme where secret keys can only be accessed by a user who knows their password. Using this setup, it is possible for Alice to explicitly grant permissions for Bob to see her data. By decrypting the data using her secret key, and then encrypting it with Bob's public key, Alice can allow Bob to see it too.

In real life, the cryptography was a little bit more complicated than that: the real secret keys were encrypted using keys derived from passwords, and the data shared between accounts was actually the encryption key needed to decrypt the data, instead of the data itself. But the principle was the same, and it worked out pretty well.

In addition, it meant that anyone who wanted to could also choose to share their secret with our automatic updating system. For those people, a sufficiently determined employee likely could have eventually figured out how to decrypt a copy of someone's credentials. The tradeoff was that it allowed our system to update account and transaction data anytime, even when that person wasn't visiting our site. It wasn't perfect, but we made sure it was an opt-in decision for those who valued convenience over the strictest possible security.

A system like Grendel is complex, and might not be a gem that you can just drop in to your Rails project in five minutes. That said, it's seriously important to have something like that in a situation where how secure your shit is really matters. Systems like these get used by big websites in the real world. If your goal is to be a grown-up website one day, start thinking about this stuff now.

### Plain old encryption

Finally, if you absolutely need access to secret data while a user is not logged in, that is the only time that it is acceptable to actually encrypt the data. Again, avoid this if you possibly can. It provides a juicer target for hacking, and makes it possible for a breach to disclose _all_ of the data you have stored without any additional per-user work by if you are hacked. If there just isn't any way to avoid encrypting some of the data, make sure that you're doing it as safely as you can. Always generate your key using a tool that is known to produce good randomness (in Ruby, use the `ActiveSupport::SecureRandom` class). Generate a different key for every environment. Never share any your keys between development, test, staging, qa, and production environments.

Also, very importantly, split your key up. Store part of it in the database as part of the user profile, different for every user in your system. This means brute forcing a single key will not allow you to decrypt every other user's data. Store part of the key in your codebase (but use a different value in each environment). This means that a copy of the database (without a copy of the application source code) will not allow all the data to be decrypted. Finally, store another part of the key in an environment variable that is only available to the application servers while they are running. Generate that part of the key separately for each environment (test, staging, qa, production), and don't store it anywhere your database or source code is stored.

Splitting the key up this way means that even attacks that reveal the source code of your running application (which are sadly somewhat common), combined with a complete copy of the database (likewise sadly common) still does not reveal the entire key. Every one of these partitions is important: database breaches, code breaches, and code execution breaches often require different security holes. If all three are required to get the entire encryption key, it is significantly less likely that a single breach will result in all of your users' "secure" data being leaked.

You really don't want your users' data to be leaked. California and many other states require notification of data breaches to every user in a timely manner or companies face stiff fines. If your company is sued over the breach and found liable, the resulting judgement could be huge.

### Secure your admin keys, too

One last note: treat all of your own internal credentials as carefully as your users' credentials! Careless handling of your own usernames, passwords, and keys can allow a relatively minor hack to escalate into something that destroys your company. Just ask Code Spaces, whose entire company was [destroyed by a leak of a minor key](http://arstechnica.com/security/2014/06/aws-console-breach-leads-to-demise-of-service-with-proven-backup-plan/). They just used the key to upload files to AWS S3, but that key was also able to delete every server, file, database, and database backup that the company had. A single hack of a "minor" key destroyed the entire company. Don't let that happen to you!

This stuff is company making or breaking, so think about what you're doing and why you're doing it. Ask for advice from people who know their stuff. Fix small security issues before they combine with other small security issues to become a huge security issue. And definitely follow (at a minimum!) the steps outlined above.

<small>2014-09-22: updated with separate sections for the safer hash and encryption options, thanks [@bgreenlee](http://twitter.com/bgreenlee)!</small>