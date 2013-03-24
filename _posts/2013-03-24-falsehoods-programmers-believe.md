---
title: Falsehoods programmers believe
layout: post
---

Everyone's [names will be like mine][kalzumeus].

Gender [is binary][cscyphers].  
Well, at least [gender can be enumerated][smarterware].

Time for programs is [like time for people][infiniteundo].  
Well, at least time has [always been like it is now][infiniteundo 2].

The network will [always be up (or sometimes down)][blogspot].  
Well, at least network [responses will make sense][inessential].

Users will only provide [input that makes sense][infiniteundo 3].  
Well, at least [users will only do things I expect][rinkworks].

Cryptography [makes encrypted data secure from attackers][schneier].  
Well, at least it's pretty safe if [I can't break it][tonyarcieri].

Answers to their security questions would never be [handed out by Amazon][wired].  
Well, at least security answers won't be [public on Facebook][theblaze].

People [won't use 'password' as their password, it's the 2010s!][splashdata]  
Well, at least [random passwords will be secure][archive].

You can believe the [API documentation][google].  
Well, at least you [can handle errors](#fn1)[^1].

It's [not harassment if I'm okay with it][oobleyboo].  
Well, at least [we should only attack the easy targets][braythwayt].

Now please excuse me, I'm off to find somewhere to sob quietly for a while without disturbing anyone. 😭

[^1]: [from the c2 wiki][c2]: <blockquote>When a function fails it returns an invalid result such as INVALID_HANDLE_VALUE. Then you're supposed to immediately call GetLastError to get the error code [...]. However, if [...] the intervening function does not err, then GetLastError will return ERROR_SUCCESS, which means there was no error, and FormatMessage will return "The operation completed successfully."</blockquote>



[archive]: http://web.archive.org/web/20130113055957/http://chargen.matasano.com/chargen/2007/9/7/enough-with-the-rainbow-tables-what-you-need-to-know-about-s.html
[blogspot]: http://erratasec.blogspot.com/2012/06/falsehoods-programmers-believe-about.html
[braythwayt]: http://braythwayt.com/2013/03/21/unjust.html
[c2]: http://c2.com/cgi/wiki?WeirdErrorMessages
[cscyphers]: http://www.cscyphers.com/blog/2012/06/28/falsehoods-programmers-believe-about-gender/
[google]: http://www.google.com/search?q=site:drupal.org+api+documentation+incorrect
[inessential]: http://inessential.com/2013/03/18/brians_stupid_feed_tricks
[infiniteundo]: http://infiniteundo.com/post/25326999628/falsehoods-programmers-believe-about-time
[infiniteundo 2]: http://infiniteundo.com/post/25509354022/more-falsehoods-programmers-believe-about-time-wisdom
[infiniteundo 3]: http://infiniteundo.com/post/25230828820/things-you-should-test
[kalzumeus]: http://www.kalzumeus.com/2010/06/17/falsehoods-programmers-believe-about-names/
[oobleyboo]: http://griffin.oobleyboo.com/archive/on-pycon2013-and-equality/
[rinkworks]: http://www.rinkworks.com/stupid/
[schneier]: http://www.schneier.com/book-sandl-pref.html
[smarterware]: http://smarterware.org/7388/the-case-against-drop-down-identities
[splashdata]: http://www.splashdata.com/press/PR121023.htm
[theblaze]: http://www.theblaze.com/stories/2011/11/07/your-facebook-profile-could-be-giving-away-answers-to-your-online-security-questions/
[tonyarcieri]: http://tonyarcieri.com/all-the-crypto-code-youve-ever-written-is-probably-broken
[wired]: http://www.wired.com/gadgetlab/2012/08/apple-amazon-mat-honan-hacking/all/