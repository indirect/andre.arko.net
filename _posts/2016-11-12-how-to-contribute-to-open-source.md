---
title: "How to Contribute to Open Source"
layout: post
---
### or: from no experience to the core team of any project in 15 minutes a day

At conferences and on the internet, the most common question I get isn’t about one of my open source projects. The most common question I get is “how can I start contributing to open source?”. After years of trying to answer that question, I have a list of suggestions that I think are pretty good. Before I get to that, though, we need to talk about what contributing to open source really means.

The most common misconception about working on open source is that you need to have a lot of experience to be able to do it. I totally understand where that idea comes from, but it’s wrong. You don’t need to understand something before you can work on it. In fact, working on an open source project is a powerful way to learn more about the project, the language, and the open source ecosystem of developers who help one another write code.

### you are experienced enough \<3

It’s not said often enough, but there are no “real” programmers. Everyone can tell a computer what to do. The most senior of programmers spend a huge amount of their time confused about why things are happening—in fact, I would argue that the core skill of programming is investigating unknown things until the computer does what you want.

### what do you want to get from this?

Despise some lazy companies’ claims, [Github is not your resumé](https://blog.jcoglan.com/2013/11/15/why-github-is-not-your-cv/). Making free software does not prove that you are a good programmer, and some of the best programmers produce no open source. Before doing any work, sit down and think about what your goals are.

Do you want to hone your skills? Gain acclaim from your peers? Shoulder a pile of crushing guilt? Open source can be a good way to accomplish those goals, but it’s not the only one. You could write software for yourself to hone your skills. You could volunteer as a teacher or mentor at [RailsBridge](railsbridge.org), [Code 2040](code2040.org), or a host of other programs. You could find an extended family full of entitled relatives who all demand that you fix their computers. You have lots of options!

Your time is your own, and you don’t owe it to anyone else. Keep that in mind as we talk about all of the things that are available to you—think about your goals, and choose to spend your time on accomplishing those goals.

If you want to write software for yourself that solves a problem that you have, you can do that! If you want to work on a project that you already use to make it better, you can do that too. If you want to work on a project that is hugely popular, with enough persistence you can even do that. But if you want to work on your career by writing software inside your company instead, that’s a legitimate option.

### what even is contributing

When I ask people what they think of as “contributing to open source”, they always paint the same picture: genius programmer fixing bugs, implementing huge features, and sending PRs that don’t even need code review before being merged. This is almost the exact opposite of reality.

Contributing to open source, more than anything else, means trying to understand other people’s problems and then help them. Sometimes that will mean changing code, but more often that will mean explaining something. Or adding to the documentation, or improving an error message, or providing design, a website, or styling. You can absolutely contribute to open source without being ready to code. Writing code is a tiny fraction of the work needed to solve people’s problems. 

### the benefits are real

Now let’s talk about the benefits available to open source contributors. You can practice building projects from scratch, by yourself. On other projects, you can practice working with a team of developers, learn about allocating tasks, estimating work, blowing through deadlines, and disagreeing about how things should be done.

Working on an open source project provides a lot of the benefits of an internship. Unlike an internship, you won’t get paid. But the upside to not getting paid is that you don’t have to get permission or approval from anyone! You can practice and learn in your own time, at your own pace, on literally whatever seems interesting to you. Open source projects mean no obligation to work on a particular task, for a particular time, or even by a particular deadline.

### should _you_ work on open source?

Now that you know about some of the benefits, though, I have to give you a pretty big caveat: Only work for free if you can and if you want to. This is maybe my most important point, so I’m going to say it again: only work for free if you _can_ and if you _want to_.

First, let’s talk about if you _can_ work for free. Open source work is almost never paid work. Open source developers do a lot of work that companies use to make money. Open source designers do a lot of work that companies use to make money. Those developers and designers almost never see any of that money, in any form. Companies taking advantage of individuals to produce bigger profits for themselves is a very real problem with the open source community as a whole. I strongly encourage you to read Ashe Dryden’s [The Ethics of Unpaid Labor and the OSS Community](https://www.ashedryden.com/blog/the-ethics-of-unpaid-labor-and-the-oss-community) for a more detailed discussion of that particular problem.

Creating open source tools and expanding your reputation is cool, but a side-project that earns you money is cool, too. Paying your bills and being able to afford things you want are important life goals. Even well-known open source developers get caught up in demands from their users and forget to take care of themselves. Every time you’re tempted to work on open source, think about the paid work (or free time!) that you’re giving up to do that. If you’re still interested, I have one more warning, and then I’ll give you the master plan.

### open source is out of your control

My last warning about doing open source work is this: choosing to release your work as open source means that you have agreed to give up control over it.

In a recent real-life scenario, the author of many open source node packages was so upset by NPM, Inc. that he deleted all of his work from the npm servers. His work happened to include a very commonly used package called `left-pad`, and the removal of left-pad broke tests and deploys for many if not post software projects written in Node.js.

Because `left-pad` was open source, though, someone was able to take their own copy of the package and upload it to npm’s servers under the same name. Even though the author wanted to remove his packages from NPM forever, his open source license meant that anyone else could (legally!) put them back, and everyone else could continue to use them.

### some licenses let you keep some control

As you think about these issues, keep in mind that putting code on GitHub does not mean it is open source. Research the options for a license, and choose a license that you are comfortable with. GitHub created the website [http://choosealicense.com](http://choosealicense.com) to help developers pick a software license for open source code. The [Creative Commons license chooser](https://creativecommons.org/choose/) offers another option, allowing you to choose a pre-made license for your work based on what you want to allow or disallow.

Research your license options, and pick one you’re comfortable with! Once you’ve made your work as open source, anyone can use it for anything your license allows. In one of the most dramatic and horrifying scenarios possible, that means you can’t stop someone from using your code to build a drone system that drops bombs and kills civilians. Be very sure that you are okay with the idea of your (unpaid!) work being used for something that you would never, ever do yourself.

### still here? time for the plan

If you’ve still here after all of the warnings and lowering of expectations, congratulations! Now we’re ready to dive into the master plan for going from no experience to joining the core team of any project you care to target.

Plan to spend at least 15 minutes every day on this. Depending on your personality, you may end up sucked in and spending an hour or two every day. There is no end date on this commitment—popular open source projects never run out of people that need help. You’ll be able to do this until you decide that the work isn’t worth it for you anymore.

To start with, you’ll want to pick out one to three projects that you’re interested in. The more projects you pick, the more time you’ll need every day. Spend some time thinking about projects you use, projects you’ve heard of, and projects that you’re interested in. Once you have a project or two or three picked out, get ready to dig in.

### stage one: wtf is happening here

Read the project readme. Read the project manual. Read every single page of the project website. Read the developer documentation. Read the contributing guide. Read the changelog. Feeling warmed up? Now comes the fun stuff. Open the project on GitHub and read _every single open issue_. Read every single open pull request. Read every comment on every issue and every pull request. Follow the repo, so that you get notified about every new issue and every new comment. Read every single new issue and every single new comment.

Keep in mind that you should only be doing this for 15 minutes a day! It will take a while. For big projects, like Rails, it might take you weeks to get through all of the issues. That’s okay, you’re in this for the long haul. Now that you’ve read all the issues and pull requests, start to watch for questions that you can answer. It won’t take too long before you notice that someone is asking a question that’s been answered before, or that’s answered in the docs that you just read. Answer the questions you know how to answer.

Now you’re a contributor! Answering questions is just the beginning. Once you’re able to start answering questions, you can help with new tickets. A lot of new tickets are repeats of old tickets in some way. Once you’re familiar with the scenarios that repeat, you can not only handle those tickets, you now know material that should be added to the docs!

Start improving the documentation based on what you’ve learned. Add warnings about common problems. Improve anything that’s confusing or misleading. Start thinking about how to improve error messages. Keep reading new issues for at least 15 minutes a day.

### stage two: you’re helping!

At this point, you’re probably starting to get a feeling for how this project works. You’re familiar with the documentation, and you’ve seen a lot of the ways that things can go wrong by reading issues. Now is the ideal time to re-read all of the documentation and fix anything that you can find that could be improved. Rewrite for clarity, correct statements that are wrong, add guides for anything people keep asking how to do.

This is also a great time to start helping with issue reports. When someone reports a bug, but can’t provide steps to reproduce the bug, figure out the reproduction steps and add them to the ticket. If you can’t figure out reproduction steps, explain what you tried on the ticket so the reporter can add detail about their problem.

A bug that can’t be reproduced is a bug that can’t be fixed. I truly cannot overstate the value and importance of contributors who are willing to figure out what exactly does and does not work. That is what makes it possible to write a test, and that is what makes it possible to write a fix for the problem.

The next level of helping after a reproduction case is writing a test. Even if you don’t know how to fix a bug, opening a PR with a failing test for a known bug is SO HELPFUL. I cannot even tell you how helpful it is. It is maybe the best present you can give to any maintainer.

### stage three: pretty much on the team now

Once you’ve started writing failing tests, it’s not much farther to start fixing those failing tests. There’s no pressure to start doing this, but at some point you’ll probably find yourself reading a ticket and thinking something like “oh, that variable was somehow `nil`. I can probably fix that.” You can! Read the code, find the bug, and send a PR with the fix.

Writing code that fixes bugs or adds features requires some level of understanding—understanding the code, understanding your users, and understanding the goals of the project. It can be hard! It’s hard for the person who wrote that code in the first place. Even if they wrote that code, probably years ago, it’s unlikely they remember the details.

This is also a good time to start using the project yourself while looking for anything that could be improved. Could that info message be clearer? Can you use the project in a way that causes an error? Is there a set of options that are confusing? Open issues or PRs for everything that you find.

After you’ve been helping with issues, sending PRs, and generally contributing for a while, starting talking to the maintainers about their plans. Many projects have successfully identified work that would be super helpful to be done, as soon as “someone” has time to do it. You can be someone! Talk with the other people working on the project, work out a consensus on priorities, and then start doing the work.

### stage four: you are the brute squad

Guess what? You’re an open source contributor. Keep it up! Repeat this process for a few months, or maybe years. If you stick with it, you are more or less guaranteed to end up on the core team.

Speaking from personal experience, this is also the point where it’s entirely possible that you will suddenly discover that you are the only person who is still working on the project. Now you’re in charge of your own open source project. Congratulations! 🎉 Also, my condolences. 😅

### what have we learned from this

Open source can be rewarding, but it isn’t worthwhile for everyone. Consider what you’re giving up, and be sure that you are happy with the tradeoff.

It is possible to figure out what is happening, and why, and fix it. As hard as computers seem to be, they are ultimately understandable.

Finally, understanding and helping the humans who are using software is the core skill of open source work. Building tools that improve the lives of their users can be immensely satisfying, and that is what keeps me doing it.

<small>Thanks to [@ashedryden](https://twitter.com/ashedryden) and [@mountain\_ghosts](https://twitter.com/mountain_ghosts) for writing about these topics previously, and [@sailorhg](https://twitter.com/sailorhg) for many of the ideas in this post.</small>
