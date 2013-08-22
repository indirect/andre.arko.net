---
title: Security is hard, but we can't go shopping
layout: post
---

![hard](http://files.arko.net/image/2J3k2N3n3y0N/security_is_hard.jpg)

# Security is hard, but we can’t go shopping

<small>This post was also given as a conference talk, originally at [Ruby on Ales 2013][roa] ([slides][roas], [video][roav]), as well as at [RailsConf 2013][rc] ([slides][rcs], [video][rcv]) and [RubyKaigi 2013][rk] ([slides][rks], [video][rkv]).</small>

[roa]: http://ruby.onales.com 
[roas]: https://speakerdeck.com/indirect/security-is-hard-but-we-cant-go-shopping-ruby-on-ales-2013
[roav]: http://confreaks.com/videos/2317-roa2013-security-is-hard-but-we-cant-go-shopping
[rc]: http://www.railsconf.com
[rcs]: https://speakerdeck.com/indirect/security-is-hard-but-we-cant-go-shopping-railsconf-2013
[rcv]: http://www.confreaks.com/videos/2430-railsconf2013-security-is-hard-but-we-cant-go-shopping
[rk]: http://rubykaigi.org
[rks]: https://speakerdeck.com/indirect/security-is-hard-but-we-cant-go-shopping-rubykaigi-2013
[rkv]: http://www.ustream.tv/recorded/33562443

### Uhoh, security?

Security is a hard topic. It's an especially hard topic in the Ruby community, where the security situation has historically been so great that hardly anyone has had to care about it. You may not know this, depending on how long you’ve been a rubyist, but Ruby security issues usually only come up once or maybe twice per year. They're usually relatively benign, as those things go, so everyone updates as soon as it's convenient, and life goes on.

Things changed pretty dramatically this year. In rapid succession, there was a flurry of security releases in both Ruby and Rails. Almost every release fixed a huge vulnerability, and security updates were suddenly extremely important.
There were more Rails security releases by May of 2013 than there had been in 2011 and 2012 _combined_. This year, Rails has issued 12 CVEs, and Ruby has issued 5 CVEs.

### CVE and me

The most common question that I get at this point is “what is a CVE, exactly?” General knowledge among Rubyists seems to be that they are "about security problems", but not anything more concrete than that. Fortunately, they're pretty straightforward. CVE stands for “Common Vulnerabilities and Exposures”, but each CVE is ultimately just a number issued by the Mitre corporation. Many groups, from corporations to governments, have agreed to use CVE numbers issued by Mitre as the canonical reference for security vulnerabilities.

Mitre assigns blocks of CVE numbers to a list of big software companies, like Oracle, Apple, Microsoft, RedHat, and others. Those companies then assign CVEs from their blocks to issues that arise in software they use or develop. The Ruby community has been assisted by RedHat’s Security Operations Group, mostly in the form of Karl Seifried, and they have provided CVE numbers for most Ruby security issues. Both Mitre and NIST (the government’s National Institute of Standards and Technology) host their own websites providing a list of all CVEs, including detailed information about the issues involved and links to any workarounds or patches that have been provided.

### The drone of the swarm

Unfortunately, the Ruby and Rails bugs found earlier this year acted to pique the interest of security researchers in Ruby and Rails. Historically, Ruby has been a (relatively) nice place, full of pretty nice people. MINASWAN, after all. Unfortunately, a nice mindset means that we don't spend time attacking or defending all the things that we are making.

That means we haven't really faced any concerted effort to find holes in our ecosystem before this year. As you can probably tell from the number of CVEs, that has changed. Security researchers saw the unusual size of the problems in Ruby and Rails, and realized there would probably be other similar problems that hadn't yet been found. That's what set off the huge number of security fixes all at once, as researchers found other low-hanging vulnerability fruit.

Luckily, the major security issues have come from security researchers on the white-ish side of the line, and we’ve been able to announce fixes as most problems have become public. We can’t count on that luck to hold forever, though, and that’s why I think it’s so important to start talking about this stuff now.

Rails is clearly leading the ruby community in dealing with security problems, but it's mostly because Rails used to be almost the entire attack surface! Rails 3 modularized everything, and that was great. Bundler added the ability to plug in any fork of any project with one line of code, and that was also great.

The thing we didn't realize at the time is that now there are dozens, if not hundreds, of gems that can all provide security vulnerabilities to applications that use them. For example, in just 8 weeks there were security vulnerabilities fixed in new releases of: rubygems, bundler, rdoc (rdoc?! yes, rdoc), json, rexml, rack, arel, activerecord, actionpack, and activesupport. 

### Suits don't like updates

Just keeping up with the critical security releases has been hard. How are we supposed to handle problems in other people's code? Bosses and managers can be reluctant to dedicate time to updating, and it can be hard to explain exactly what the business case is for spending that time. On the other hand, there's definitely a strong cultural consensus among developers that security updates are important. The cultural consensus is great, but it rarely includes an explanation of exactly how and why it's important.

The reasoning turns out to be fairly straightforward: time spent on security updates is insurance payments. You pay a (relatively small) amount of effort over time in order to avoid a (relatively small) chance that you'll be attacked. Without that investment, though, an attack could be catastrophic. Just cleaning up from a single security breach can have huge unanticipated costs. Hacks can take down your site for an impossible-to-estimate amount of time (just look at the recent hack against Apple's developer center), and cost months of engineering time to diagnose, analyze, and fix.

And that's just the engineering repurcussions. If you are hacked, you'll also need to spend time and effort explaining what happened to your customers and trying to reassure them that it won't happen again. Even beyond that, nearly every state in the US has a law requiring that any compromised company inform every user, directly and individually, in writing. Some states have civil and criminal penalties if that notification is delayed. You really don't want to have to deal with that. An ongoing low-level cost of security maintinance is hugely preferable to a huge incident that your business might not be able to recover from.

### Don't shoot the messenger

So now that I’ve (hopefully) convinced you that keeping up with the tide of security releases is important, what about our actions as developers? How should security issues be reported? Happily, there is already a best process that the security community has developed after years of trying different options. It's called responsible disclosure. (You can tell it’s the best option because it makes everyone involved feel upset, but protects them from each other.) Responsible disclosure fundamentally has just two parts:

Disclosure just means publically announcing the problem and anything bad that happened because of the problem. It is the part that generally pisses off the software companies. It means they can’t keep things quiet and pretend that nothing happened. Responsible disclosure, on the other hand, means that the security researchers who find the problem will contact the developers and let them know about the problem privately, so that they have a chance to fix it before it becomes public. This part pisses off most security researchers. Not only did they do some very clever work, but they’re unlikely to get paid for it, and they can’t tell anyone about it until the fix is ready and the embargo ends.

Some companies are trying to improve that unhappiness by providing monetary rewards for responsible disclosures. Different companies occupy the entire spectrum on the issue of rewards. Engine Yard provides responsible disclosure guidelines, but explicitly states that monetary rewards are out of the question. Github has no stated policy for or against rewards. Facebook provides a minimum of $500 (with no maximum!) for each security vulnerability that is reported according to their documented process. Google recently paid a record $31,000 at once for three bugs in Chrome.

### A bug walks into a bar…

So. Practical application time: what if you find a bug? First, congratulations! You figured out there’s a bug. Reporting that bug is a great way to make the software that you're using better for everyone. Once you have the bug, and you’re ready to report it, stop and think for a second. The fact that it's a bug obviously means something isn't working as intended. But beyond that, there are two important questions to ask yourself: does this bug allow you to get information or privileges you shouldn't have? Alternatively, does it allow you to disable the system for anyone other than yourself?

If the answer to either one of those questions is yes, then you should report the bug, in private, to the security team. Maybe it'll be a false alarm, and that would be great. If it's not a false alarm, though, you probably just saved both developers and users a ton of time and hassle. Even if bugs aren't actually exploited by anyone, once they are public they need to be patched for all the reasons I talked about earlier. Reporting to the security team means that patches can be written, tested, and ready to go along with the announcement.

### I'm on the security team

Now comes the slightly tricky part—what do you do if there is no security team? I've seen gem security issues range from "can't find the author" up to "I committed a fix to github but can't push to rubygems, and the person who can is out of the country". Definitely try to contact the author of you possibly can. If you can't, or they don't reply to you for a while (at least 48 hours, and please be patient on weekends), then you are faced with a decision.

Should you drop it entirely? (This mostly only works for very small problems.) Should you file a public bug and hope the author fixes it before someone else exploits it? Or should you fix it yourself, and make the fixed version available? If you fix it yourself, reporting the bug and the fix publicly can also work. Only do that in a worst-case situation where the author has vanished, though.

Now that we've covered the worst case, let's talk about a better one. If you hear back from an author, try to work with them. If you can, offer to work on the fix together (but be prepared to be turned down). Most authors, most of the time, will be happy to work with you, fix the bug, and release the fix and announce the issue at the same time.

You should avoid publicizing the issue until a fix is completed and available. Above all, have empathy with the developer! They're a person, too, who hopefully has a life. Treat them the way you would want to be treated if the problem was with your code.

### You are the security team

Before I wrap things up, I’d also like to talk about how to be responsible about security when you are the author of the code in question. How many of you have ever released a public gem? A lot of you. And if other people use that code, you might be on the receiving end of a vulnerability disclosure. Let me run through the scenarios when your own code has a vulnerability, and the communal wisdom that has emerged as the best way to deal with those situations.

Easiest to handle is a responsible disclosure from a sympathetic researcher or developer. Make sure to reply to them and address their concerns. Keep them updated on your progress as you work on a fix. Check your eventual fix with them to make sure that it fully addresses the issue that they found.

The other straightforward case is a vulnerability that you only discover because it’s already being exploited by malicious attackers. If that happens, good form is to fix it as quickly as possible. If fixing it will take time, and especially if there is a possible workaround, publically announce the issue even before the fix is ready. If additional publicity will cause more damage, don’t announce until you also have a fix.

Now the complicated case: pushy, impatient security researchers who want publicity to show how awesome they are, but follow the letter of the responsible disclosure law so that they stay legally in the clear. Keeping those kinds of people happy is the truly hard work of being responsible about security as an author. While that does sound kind of scary, it’s completely possible to manage your project so that they help you instead of hurting you.

### Help them help you

As a project author or manager, make sure that the contact information in your gemspec is accurate. Add your email address to your github profile. If the project is big enough to have a team, set up a security address and put trusted team members on it. If you have a security address, create a PGP key and a disclosure policy. Put them in a static page, even if it’s just a file in your git repo. It’s only a few minutes of work, and can save you hours or days of stress later on! Respond to security reports within 24-48 hours, even if it’s just to acknowledge the email. Follow up with status reports, every 24-48 hours, even if the status report just says “nothing to report yet, but I’m working on it”. Finally, plan on crediting the reporter when you announce the issue and your fix (although you should of course check with them before doing so).

All those steps combined are not a huge amount of work. Honestly, they’re only a few minutes for most projects, even relatively big ones. It may not seem like a big deal if you’ve never had a security issue before, but just ask the Rails team about how things were before! Implementing those simple steps can save you all kinds of unpleasantness.

<small>This is a cross-post from the [Cloud City Development Blog](http://blog.cloudcity.io/2013/08/22/security-is-hard-but-we-cant-go-shopping/), where you can [hire us](http://cloudcity.io/#contact) to help you build web applications.
