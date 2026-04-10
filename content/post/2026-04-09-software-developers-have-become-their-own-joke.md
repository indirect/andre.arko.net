+++
title = 'Software developers have become their own joke'
slug = 'software-developers-have-become-their-own-joke'
date = 2026-04-09T22:17:52-07:00
draft = true
+++

Creating software is complicated. It's hard to figure out exactly what you need to build without a lot of trial and error. It almost always requires both exploring possible options _and_ refining something until it works really well. But those things aren’t the same! Your research prototype is _not_ a good product that people will happily pay for.

Back in the olden days, when software literally came from BigCo R&D departments, we managed to invent Unix, and the mouse, and GUIs, and Ethernet, and TCP/IP, and a ton of other stuff we all use constantly today. Those research divisions didn't ship viable consumer products, though. Doug Englebart demoed a mouse-driven GUI in 1968, but you couldn't buy a home computer with a mouse-driven GUI until 1979, and they didn't become commercially popular until the Macintosh in 1984.

Even years or decades of research wasn't enough, and years (or decades!) of development work also needed to be done before the results was ready for people to use. Early literature about creating software, written by Fred Brooks and his peers, seems to contain the internalized view that both R and D are required. That's not surprising, since R&D departments created most software back then, but we seem to have lost track of that connection.

Even though our jobs are descended from those R&D labs of yore, we somehow lost the industry job of “software researcher”, and only "software developer" remains. Instead, research happens in academia, where an argument and a pseudocode is all you need to publish a paper. In that world, development is effectively non-existent.

(I admit the division isn't perfectly clear-cut. Sometimes academics will start companies around their research that create a product or more likely get acquired to add a feature to a product. And sometimes Linus Torvalds will just build a new operating system, without doing any academic research on it, and it will get so popular everyone uses it. The point is that industry and academia have each publicly claimed one half of R&D while disowning the other.)

The broader separation of research and development into academia and industry is really unfortunate, because good software needs both research _and_ development as inputs. If you don't do any research, you can’t identify which parts will be hard (or impossible) until after it’s too late. You also won’t have a good idea of what parts are important until after you’ve put in most or all of the work to create the parts that don’t matter. If you don't do development, you won't ever have something robust enough that other people can use it successfully.

Meanwhile, on the other side, it feels like developers work hard to convince themselves there are no research aspects involved in their jobs. We call anything research-ish by a euphemism, like “design”, “user experience”, “prototyping”, “de-risking”, “a spike”, and a lot of other funny euphemisms that avoid referring to the work as research. It seems like we're trying to convince ourselves that we don’t do Research any more, because we are just Developers.

This cultural lack of clarity around research in software development spaces really hit hard for me this week, as I read yet another treatise on working with LLM-driven agents for development. The two most popular takes that I have seen are “these tools are a fundamental shift in the nature of software development” and “these tools change nothing about building software at all”. Then the two sides start screaming at each other about how the other side is delusional and time will prove them completely wrong, and I lose interest.

If we instead start from the premise that all software work requires research (where the problem space must be explored) and development (where solutions must be implemented and refined), there’s something hiding in the sometimes messy overlap between those two ideas that I'm not seeing come up in any discussions.

**No one can take the output of software research and treat it like it's the output of software development.** Not Bell Labs, not Xerox PARC, not Microsoft middle managers, and not "solo founders managing a team of AI agents" today.

Unfortunately, seeing a prototype and becoming convinced it's complete is not a new problem. It's been the bane of software development possibly since the very beginning, when (apocryphally) a manager would review a mockup and conclude the project was now complete and could be shipped to customers immediately. Today, instead of telling that story as a joke, software developers have have somehow turned themselves into the boss from the joke, shouting that it's time to ship the research prototype because it "looks finished". How did we do this to ourselves?

It seems like, back when we always had to do all the work ourselves, it was harder for software developers to be confused this way. If a developer knows they skipped every validation and edge case, it's much easier to realize it's not finished. If an LLM agent says "here's a comprehensive implementation", without mentioning all the validations and edge cases it skipped, many (and possibly most) developers will not notice the parts that are missing.

This phenomenon is bad for a lot of reasons, including one reason you have probably already thought of: we’re going to get a lot more software claiming to be "comprehensive" and "fully implemented" when it’s really a partially finished prototype that’s full of holes.

In a world full of research prototypes being pitched as completed development work, life is about to get worse for everyone who uses software. The docs are even more wildly wrong than they were before, customer support is telling you that your problem is solved by a feature that doesn't exist, and company leadership is so excited they are planning to fire as many humans as possible so they can have more of it.

I don't want worse software! The software we already have is mostly terrible. Not only much worse software, but also much more of it, is pretty much my worst case scenario. What I actually want is better software, even if that means less of it.

Unfortunately, instead of making better software, software developers have decided to become the butt of their own joke, shipping software that doesn't work, with a footnote that says they know it doesn't work but they are still shipping it. I don't see any way to stop it, but I hate it anyway.
