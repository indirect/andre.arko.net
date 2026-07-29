+++
title = "Ruby Central's Destructive Legacy"
slug = 'ruby-centrals-destructive-legacy'
date = 2026-07-30
+++

At conferences and meetups, and in conversations online, many Ruby developers have asked me about Ruby Central and my disagreement with them. This post is my attempt to answer the questions I've been getting over and over, covering: 1) what is Ruby Central doing now? 2) has the dispute over Bundler and RubyGems been resolved? 3) what has Ruby Central said about the dispute? and 4) what can Ruby developers do now?

### What is Ruby Central doing now?

To talk about what Ruby Central is doing now, we need to start with a bit of historical context. What was Ruby Central doing before this saga began? About 18 months ago, Ruby Central:

- ran 2 conferences every year, RubyConf and RailsConf
- had an [Open Source Committee](https://rubycentral.org/news/a-new-chapter-for-rubygems-how-ruby-central-is-building-a-sustainable-future/#the-ruby-central-oss-committee-is-formed) with 3 members (Ufuk, Gabi, Mike)
- funded 7 [part-time community OSS contributors](https://web.archive.org/web/20250602004248/https://rubycentral.org/open-source/#team-heading) (André, Arun, Ellen, Gift, Irene, Josef, Martin)
- funded 3 [full-time OSS developers](https://web.archive.org/web/20250602004248/https://rubycentral.org/open-source/#team-heading) (Colby, Samuel, David)
- coordinated those 10 OSS contributors across 3 major OSS projects:
	- RubyGems
	- Bundler
	- RubyGems.org  

Then, about 10 months ago, Ruby Central began what core team member Ellen Dash called [a "hostile takeover" of the RubyGems, Bundler, and RubyGems.org open source projects](https://mjtsai.com/blog/2025/09/23/ruby-central-takes-over-rubygems/), seizing control of the projects and locking out the team that had nurtured and maintained them for over a decade.

Today, 10 months after their takeover, Ruby Central has:

- lost 2 of 2 conferences, after [ending RailsConf](https://rubycentral.org/news/announcing-railsconf-2025-and-a-new-chapter-for-ruby-central-events/), [cancelling a significant portion of the last RubyConf](https://rubycentral.org/news/rubyconf-updates/), and providing no future conference locations or dates for the first time in decades
- lost 2 of 3 major OSS projects, by [transferring Bundler & RubyGems away to Matz](https://www.ruby-lang.org/en/news/2025/10/17/rubygems-repository-transition/)
- lost 9 of 10 [contributors to open source work](https://web.archive.org/web/20250602004248/https://rubycentral.org/open-source/#team-heading), including:
	- 6 of 7 operators of RubyGems.org (André, Samuel, Arun, Josef, Ellen, Martin)
	- 2 of 3 full-time contributors to OSS (Samuel, David)
	- 2 of 2 OSS writers (Gift, Irene)
- lost 3 of 3 members of the [Open Source Committee](https://rubycentral.org/about/) (Gabi, Mike, Ufuk)
- lost 5 of 7 [board members](https://web.archive.org/web/20250902024234/https://rubycentral.org/about/) (Kinsey, Valerie, Naijeria, Ben, Ufuk)
- lost 3 of 3 Executive Directors (Adarsh, Chelsea, Shan)
- lost 2 of 2 major financial sponsors (Sidekiq and Shopify, although [Shopify seemingly just returned](https://rubycentral.org/news/shopify-joins-the-ruby-alliance/) after a 9 month break)

Unlike many community non-profits (including the [Python Software Foundation](https://www.python.org/psf/bylaws/)), Ruby Central [does not hold elections](https://rubycentral.org/news/jointheboard/) for their board of directors. Despite [rewriting their bylaws entirely this year](https://rubycentral.org/news/modernizing-ruby-centrals-bylaws-and-officer-updates/), new directors are still selected exclusively by existing directors, with no public process for input or feedback. The current board consists of just 2 of the 7 members who initially approved the hostile takeover, plus 3 new members chosen by the previous board (Brandon, Jey, and Ran).

Based on Ruby Central's [public announcements](https://rubycentral.org/news/), they have added exactly one new program after ending both conferences and transferring away half of their open source software: [a new security project](https://web.archive.org/web/20260616121600/https://rubycentral.org/news/strengthening-security-for-the-ruby-ecosystem/), funded by a grant from [Alpha-Omega](https://alpha-omega.dev/). The security project's goal is to use Anthropic's Project Glasswing to search for security issues in gems that have already been published. In their [first monthly report for June](https://github.com/ossf/alpha-omega/blob/main/alpha/engagements/2026/Ruby%20Central/2026-06.md), they reported finding a total of 5 vulnerabilities, with 1 issue at medium severity, and 4 at low or unclassified severities.

Ruby Central's current sponsorship drive, the Ruby Alliance, has found three members willing to join: Gusto, Thoughtbot, and (very recently) Shopify. What none of the [sponsorship](https://rubycentral.org/news/gusto-joins-the-ruby-alliance/) [announcement](https://rubycentral.org/news/thoughtbot-joins-the-ruby-alliance/) [posts](https://thoughtbot.com/blog/why-thoughtbot-is-joining-the-ruby-alliance) have mentioned is that Gusto and Thoughtbot employ two of the five [Ruby Central board members](https://rubycentral.org/about/). [David Corson-Knowles](https://www.linkedin.com/in/davidcorsonknowles/) is both a board member and a Senior Staff Engineer at Gusto. [Ran Craycraft](https://www.linkedin.com/in/craycraft/) is not just President of the Ruby Central board, he is also Managing Director, Americas at Thoughtbot. That means the board members who allocate the sponsorship money are also providing that sponsorship money, a conflict of interest which neither the companies nor Ruby Central have disclosed. The final sponsor is Shopify, [coming back 9 months after](https://rubycentral.org/news/shopify-joins-the-ruby-alliance/) [it was reported they demanded Ruby Central start this disaster in the first place](https://joel.drapper.me/p/rubygems-takeover/).

### Has our dispute been resolved?

No, our dispute has not been resolved. Since last October, Ruby Central has been threatening to sue me. They have not withdrawn that threat as of today.

The core of our dispute is that last September, Ruby Central [hijacked the Bundler and RubyGems GitHub projects from their maintainers of over ten years](https://joel.drapper.me/p/rubygems-takeover/). When I informed Ruby Central that [I own the name Bundler](https://andre.arko.net/2025/09/25/bundler-belongs-to-the-ruby-community/), they retaliated with a threat to sue me for [supposed "hacking"](https://rubycentral.org/news/rubygems-org-aws-root-access-event-september-2025/), a position [I have always disputed](https://andre.arko.net/2025/10/09/the-rubygems-security-incident/).

Ruby Central has stated they will only withdraw their threat if I drop my claim they infringed the name Bundler. After I also questioned if my work as a contractor had been allowed by state labor law, they additionally started demanding that I drop any claims regarding employment as well. So far, Ruby Central has consistently said they will only withdraw their lawsuit threat if I give up my infringement claim for Bundler and any possible back pay I believe they owe me.

When the lawsuit threat did not make me drop my claims, [Ruby Central then chose to give away the Bundler gem and `rubygems` GitHub repo to Matz](https://www.ruby-lang.org/en/news/2025/10/17/rubygems-repository-transition/). After that, all of the former maintainers made [a new offer to settle](https://andre.arko.net/2025/10/26/we-want-to-move-ruby-forward/). Ruby Central never replied to our offer. Instead, they restated their original offer, and only to me: they would withdraw their threat to sue only if I dropped all of my claims. I did not accept, and after four months with no further progress, I wrote [a public update](https://andre.arko.net/2026/03/03/four-months-of-ruby-central-moving-ruby-backward/).

In response to my post, Ruby Central did two things at once:

First, Ruby Central told me they were actively seeking outside funding to pay a settlement to me that would end our dispute. They asked me for an amount that would fully compensate me for my attorney's fees, the amount they might owe in back pay, plus compensation for an additional six months after I was fired. With help from an expert, I calculated an amount around $450,000, and provided that number as requested.

Despite providing that number, I have never asked for that amount of money. I provided that number at Ruby Central's request, so they could seek funding. What I have instead asked for, consistently, is an apology for the attacks on my reputation without evidence, and the far smaller amount of reimbursement for my attorneys' fees.

Second, at the same time as they sought funding for a settlement, Ruby Central also reported me to the FBI through their lawyer, requesting that I be criminally investigated. On March 9, 2026, Ruby Central's lawyer informed my lawyer that he had made the report, and suggested I would need to hire a criminal defense attorney. As far as I have been able to learn, Ruby Central's lawyer was not able to provide any evidence to the FBI with his report, since Ruby Central has not been able to find evidence that I caused any harm during their three audits of the RubyGems AWS account.

Unfortunately, it is impossible to withdraw a report to the FBI. Despite Ruby Central's later statement to me that they don't intend to pursue the FBI report, they gave up the ability to make that decision when they filed the report — it's up to the FBI now, not up to them.

A few weeks after saddling me with a permanent possibility of criminal prosecution by the FBI, Ruby Central [ran out of money](https://rubycentral.org/news/a-new-chapter-for-ruby-central/). Their post said they "want to move forward together", but did not take any action or answer any questions regarding their past actions. Nonetheless taking that post as a promising sign, I offered Ruby Central [a new option to resolve our disagreement](https://andre.arko.net/2026/04/02/towards-an-amicable-resolution-with-ruby-central/).

I did not ask them to return Bundler. I did not ask them for fair payment under employment law. I didn't even ask for an apology. Instead, I asked for 1) public confirmation that I did not cause any harm to RubyGems, and 2) reimbursement for the lawyer fees I have had to pay because of their threatened lawsuit. Ruby Central then ignored that post, and multiple attempts to reach out, for six weeks.

After six weeks, Ruby Central sent me a rerun of their settlement offer, with some specific restrictions: they would withdraw their lawsuit threat if I drop my claim they infringed the Bundler trademark, drop my claim they violated employment law, and agree to non-disparagement that binds me but does not bind Ruby Central, instead only specific individuals currently associated with them.

This offer did contain one new twist. Ruby Central wrote that if I accepted they would limit their cooperation with the FBI, offering to "discourage the filing of criminal charges, and if an investigation is opened or charges filed, cooperate only to the extent required by law". There's just one small problem with that offer: many state and federal laws make it a crime to agree to any limits on cooperation with a criminal investigation. Needless to say, I could not accept such a settlement.

Since Ruby Central can't withdraw their FBI report (because it's out of their hands now), and they can't give back the repos they took ([because they don't have them anymore](https://www.ruby-lang.org/en/news/2025/10/17/rubygems-repository-transition)), and they can't pay any kind of compensation (because they don't have any money), I was at a bit of a loss. What could Ruby Central even do to try to resolve this situation that they had created?

In the end, I responded with a counter-offer of my own: I would drop my infringement claim against Ruby Central over their use of the name Bundler, and I would drop my claim Ruby Central violated employment law, if they would withdraw their threat to sue me and publish an apology. I asked them to apologize for publicly accusing me of harming RubyGems.org without evidence, apologize for claiming I tried to obtain user PII when I did not, and apologize for breaking the Bundler and RubyGems governance to execute their takeover. Surprising me, Ruby Central did not object to the apology I requested.

Unfortunately, Ruby Central has continued to insist on a non-disparagement agreement that binds me, but does not bind Ruby Central. I was forced to reply that I could not accept such an unbalanced agreement.

It has been 30 days since my counter-offer. While RubyConf did take up 3 of those days, Ruby Central has not replied for the full 30 days. Their lawyer promised to provide a timeframe for their response within one day, and has not done even that. A month with no response points to a different kind of resolution: an incredibly disappointing legacy for the shattered remains of a once-legendary organization.

## What has Ruby Central said about this?

Even after all of the consequences described here, Ruby Central has never acknowledged that [maintainers of over ten years should not have been thrown out of their own projects](https://mensfeld.pl/2025/09/ruby-central-rubygems-takeover-analysis/). Ruby Central either does not know, or is not willing to admit, that they needlessly attacked and removed the existing team when we could have given them all the help they needed to secure their systems. Ruby Central's public posts to date [carefully offer no apologies](https://rubycentral.org/news/a-new-chapter-for-ruby-central/#to-the-maintainers) to the maintainers.

The sole public justification they have ever offered for this hostile takeover is that they did this "[to improve security](https://rubycentral.org/news/strengthening-the-stewardship-of-rubygems-and-bundler/)". Unfortunately, Ruby Central removed all of the experts who could have ensured they executed their takeover securely. When I responsibly disclosed Ruby Central's failure to secure their systems, which embarrassed them, they retaliated by [publicly accusing me of "hacking"](https://rubycentral.org/news/rubygems-org-aws-root-access-event-september-2025/) and [privately preparing to sue me](https://andre.arko.net/2025/10/09/the-rubygems-security-incident/).

As of this writing, Ruby Central has conducted no less than [three](https://github.com/ossf/alpha-omega/blob/main/alpha/engagements/2025/Ruby%20Central/update-2025-10.md#unauthorized-access-and-credentials-rotation) [separate](https://github.com/ossf/alpha-omega/blob/main/alpha/engagements/2026/Ruby%20Central/2026-01.md#aws-security-audit) [audits](https://rubycentral.org/news/a-message-from-the-ruby-central-board/), seeking evidence that I caused some sort of harm. They have not found any evidence, because (beyond [revealing Ruby Central's embarrassing failure to secure the RubyGems.org service](https://joel.drapper.me/p/ruby-central-security-measures/)) I did not take, damage, or harm any part the RubyGems.org service.

During the multiple months where Ruby Central ignored my offers to settle, after baselessly reporting me to the FBI, they nevertheless published a "[Fracture Incident Report](https://rubycentral.org/news/rubygems-fracture-incident-report/)", which states it was written to "provide closure". Unfortunately for that closure, the report does not explain any of the reasons Ruby Central chose a path that destroyed their sponsorships, their volunteers, their open source projects, their staff, and their board of directors.

For example, what actions did the board actually vote to approve? What did Ruby Central expect to gain? Why did Ruby Central single me out personally, while ignoring the other maintainers? Why jump straight from being embarrassed to threatening a lawsuit? What could possibly justify involving the FBI while there is no evidence of any harm? The report answers none of these questions.

Instead, Ruby Central continues former Executive Director Shan Cureton's public policy, even beyond her departure: no one deserves to know why any of this happened, because "[they don't need to have the story, and it isn't their story to have](https://youtu.be/nKpo68g9dEk?si=317CcZWMDIJNYZQ3&t=949)". According to Ruby Central, I don't deserve to know why this happened, none of the former maintainers deserve to know why this happened, and no one else in the Ruby community deserves to know why this happened. Including you.

### What can we do about this?

There was a time when Ruby Central did more work to support the Ruby community than any other organization in the United States. In 2004, when I first started learning Ruby, I was surprised to discover that RubyConf 2005 would be in San Diego, close enough for me to attend. I rounded up my only two friends who also liked programming, and we went together.

I saw Matz give a talk proposing the `->` "stabby lambda" syntax. I tried to understand `call_cc` in a talk given by Jim Weirich using a Nintendo 64 to demonstrate continuations via _The Legend of Zelda: Ocarina of Time_. I saw the Rails core team, working toward releasing Rails 1.0 in December of that year. I joined IRC on Freenode, where I made a huge number of Ruby friends I still have today, over 20 years later. I met other students who were attending from nearby UCSD, and we are also still friends to this day.

Just over a year later, I attended the first RailsConf in 2006. I met some strangers, we became friends, and one of them invited me to apply to work at his company. That became my first full-time job, set an unrealistically high standard for managers and co-workers, and made me even more friends that I still talk to regularly today.

Ruby Central's conferences changed my life, in the best way possible. The community that grew out of the events, talks, online chats, and shared code inspired me to contribute back — to help create and ship Bundler 1.0 in 2009, to maintain Bundler for the next 15 years, to work on RubyGems and RubyGems.org for over 10 years, and to found the non-profit Ruby Together to focus on funding and maintenance for 7 years.

When Ruby Central reached out to express interest in merging with Ruby Together, and combining my open source programs with their conference programs, I was flattered. I agreed to the merger based on their spectacular track record of conferences and community-building from 2001 to 2021.

It's incredibly sad that today, just a few years later, Ruby Central has zero upcoming conferences for the first time in their 25 year existence. It's even more sad that this entire dispute, far from strengthening Ruby Central as they claimed to want, has instead attacked the very [community governance they were supposed to be providing](https://nesbitt.io/2025/12/22/package-registries-are-governance-as-a-service.html).

Even beyond getting thrown out of the project that I helped create, after fundraising for a decade to keep it alive, Ruby Central's betrayal of the community hurts. It hurts to see not just me, but a whole team of maintainers driven away from the projects they have nurtured and developed for so many years. It hurts to hear that even after all of this, it was done for no real reason anyone can explain, and produced no real benefits that anyone can point at. That's no way to rebuild trust, or to support and grow a community.

The Ruby community deserves better.

We can create open source projects [governed openly by their maintainers](https://github.com/gem-coop/governance), like [gem.coop](http://gem.coop). We can build new tools that make using Ruby better for everyone, like [rv](https://rv.dev/) or [Ruby Butler](https://github.com/RubyElders/ruby-butler/). While I have no interest in creating any more Ruby non-profits, I hope one day there will be Ruby community organizations where the directors are elected by the community, perhaps like the [Python Software Foundation board](https://www.python.org/nominations/elections/).

We can't return to the past, when Ruby Central's conferences were popular and amazing community events, and when Ruby Together supported open source projects without claiming to own them. Instead of spending our time trying to bring back the old days, let's work together to build Ruby a brighter future.
