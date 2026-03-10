+++
title = 'Four months of Ruby Central moving Ruby backward'
slug = 'four-months-of-ruby-central-moving-ruby-backward'
date = 2026-03-03T01:50:25-08:00
+++

From the moment RubyGems was first created in 2004, **Ruby Central provided _governance_ without claiming _ownership_**, to support the Ruby community. Providing governance meant creating processes to provide stability and predictability. Avoiding ownership meant allowing the community to contribute, to the point where unpaid volunteers created and controlled the entirety of RubyGems.org for many years.

**Last year, Ruby Central flipped that successful formula on its head**. They now claim _ownership_ of both Bundler and RubyGems, but refuse to provide _governance_. Ruby Central now claims sole control over all code and decisions, despite paying for only a few percent of the work required to create and sustain the projects across 22 years. Instead of providing stable and predictable processes, Ruby Central [suddenly hijacked the Bundler and RubyGems codebases](https://joel.drapper.me/p/rubygems-takeover/) away from the existing maintainers, shut out the community, and started issuing the threats to sue.

When confronted by the former maintainers after the hijacking, Marty Haught of Ruby Central stated (in [a recorded video call](https://youtu.be/FjQKOIf8_Wg)) on September 17 that "yeah, we shouldn’t have changed that". On September 18, Marty went on to write:

> In the past, we've made the mistake of conflating ownership of the code with ownership of the infra, and vice versa, and we'd like to straighten this out so that we aren't put in a legal bind that requires us to take control of the entire codebase when, we all agree, that is not proper or correct given the existing model.

In the words of Ruby Central itself, **"we all agree, [taking control of the entire codebase] is not proper or correct."** Since the beginning of this conflict, Ruby Central has privately admitted it was wrong to hijack the GitHub organization and steal the repos, but has refused to acknowledge this in public. Unfortunately, despite privately admitting their actions were wrong, Ruby Central has publicly continued to dig their hole deeper. Instead of owning up to their mistake, they secretly negotiated a deal with Matz for ruby-core to [take over the stolen RubyGems and Bundler repository](https://rubycentral.org/news/ruby-central-statement-on-rubygems-bundler/), further violating the project governance policies.

If this situation were just about me personally, I could believe it sprang from from individual disagreements. Ruby Central [claims they had good reasons](https://rubycentral.org/news/rubygems-org-aws-root-access-event-september-2025/ "Incident Response Timeline") to unilaterally kick me out of the project, even though [I don't think their claims hold water](https://andre.arko.net/2025/10/09/the-rubygems-security-incident/). With that said, regardless of what you think about me personally, the other **five long-term maintainers have never gotten any explanation** of why they were suddenly kicked out or bypassed entirely, all in violation of existing project governance.

In [her only public interview](https://www.youtube.com/watch?v=nKpo68g9dE) about the situation, Ruby Central Executive Director Shan Cureton defended stealing Bundler from its team of fifteen years by saying the removed team "didn't need to have the story, and it wasn't their story to have". Ruby Central has made their position clear: **if they steal your project, you are not entitled to know their reasons**, and neither is anyone else. There is nothing "community-oriented" about stealing the most-used gem in Ruby and refusing to share your reasons with the community.

Despite Ruby Central’s unacceptable treatment of both projects and maintainers, the former RubyGems and Bundler team said [we want to move Ruby forward](https://andre.arko.net/2025/10/26/we-want-to-move-ruby-forward/). **We offered Ruby Central a path** to move past their illegitimate GitHub takeover, past their vicious personal attacks, and past their threats to sue us.

It has been four months since we made that offer, and **Ruby Central has not accepted**.

While declining to accept our offer, Ruby Central has nonetheless found the time to [propose new governance documents for RubyGems](https://github.com/ruby/rubygems/pull/9187). In those documents, they explicitly require existing maintainers approve adding or removing team members. That rule was already present in the previous governance, and is **the exact rule that Ruby Central violated to execute their takeover**. When asked why they violated the previous governance, and why the new governance would be any more trustworthy, Ruby Central refused to respond substantively, and then the question itself was hidden by [marking it "off topic"](https://github.com/ruby/rubygems/pull/9187#issuecomment-3703919204).

Instead of working to resolve the situation, Ruby Central has spent 4 months rejecting requests for an explanation, while repeatedly threatening to sue me personally. After Ruby Central suddenly took over the Bundler repo, [I sent them a standard trademark notice](https://andre.arko.net/2025/09/25/bundler-belongs-to-the-ruby-community/). They replied with a threat to sue me. When I later informed Ruby Central I had learned they violated state employment law, they simply replied with the same threat to sue me again. They are threatening to sue me for "hacking" them, despite their own analysis publicly concluding ["no evidence that user data or production operations were harmed"](https://rubycentral.org/news/rubygems-org-aws-root-access-event-september-2025/).

Without seeking common ground, or even looking for some sort of resolution we can just live with and move on from, **Ruby Central has offered all of us — nothing**. Ruby Central has made no offer in reply to outreach from the other five maintainers. To me, after four grueling months of private "negotiation", their entire offer is nothing more than to refrain from suing. But only if I agree to everything that they want.

They say I must agree that I have no claim on the name Bundler, despite helping create it and leading the Bundler team for the last 15 years. They say I must agree I was paid legally and fairly, when California law clearly states I was not. **They say I must agree that Ruby Central can take over open source projects** they host, any time they feel like it, with no explanation, and no consequences.

I don't agree.

Letting this situation stay unaddressed sets a dangerous precedent for all open source projects written in Ruby. **Ruby Central has resolved nothing. Don't let their delaying tactics convince you otherwise.** The Ruby community cannot trust Ruby Central with control over our gems until there is accountability for destroying [the very governance they were supposed to be providing](https://nesbitt.io/2025/12/22/package-registries-are-governance-as-a-service.html).

**Until accountability arrives, take action**. Tell Ruby Central they owe everyone an explanation for violating the project governance around six long-term maintainers, not just me. Don't sponsor, attend, or speak at RubyConf. Contribute to projects that aren't controlled by Ruby Central.

The exiled maintainers are working on new projects, with a focus on clear governance, long-term financial sustainability, and community input: Join the [gem.coop](https://gem.coop/updates/5/) beta, and stop using RubyGems.org. Use [jwl](https://github.com/duckinator/jwl) instead of RubyGems. Use [`rv`](https://rv.dev) or [Ruby Butler](https://github.com/RubyElders/ruby-butler/) instead of Bundler.

A better world is possible! Ruby Central might want to keep Ruby in the past, but **we can work together to build Ruby a future**.
