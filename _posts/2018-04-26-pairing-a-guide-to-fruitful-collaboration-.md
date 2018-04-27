---
title: "Pairing: A Guide to Fruitful Collaboration 🍓🍑🍐"
layout: post
---
When interacting with Ruby devs, I’ve heard a lot of feedback along the lines of “I‘ve heard that pairing is supposed to be good, but every time I try to do it I get more and more discouraged”. Other devs I’ve talked to have lots of great experience pairing with their peers, but aren’t sure how to work with someone more or less experienced than they are. The goal of this talk is to prepare you so that pairing is not only something that you _can_ do with any other dev, but something that you _want_ to do with any other dev. By the end of this talk, I want you to be ready have awesome pairing sessions where you are energized and excited by working together with other devs to conquer your shared problems. Pairing is a fantastic tool for your professional toolbox: let’s learn how to design, discuss, refine, and refactor… together.

So, before we dive in, why would you want to listen to me talk about this anyway? I’ve collaborated with other Ruby developers for 14 years, and for the last 5 years my day job has been almost entirely pairing. All day long, every day. In that time, I’ve paired with devs ranging from twice my age and experience all the way down to brand new devs writing code for the very first time. This talk is an attempt to gather everything that I’ve learned into one place, so that you (and, honestly, also me) can easily refer to it later.

### What is pairing? We just don’t know.

Even if you’ve already been convinced that pairing is good, the desire to pair doesn’t come with instructions. What is pairing? It’s not incredibly clear, especially since  asking 10 developers will usually get you 10 different answers. For this talk, we’re going to define pairing as working with another developer on the same machine.

If you haven’t had a good pairing experience yet, this is probably the point where you’re thinking “why would you have two developers use one machine? only one keyboard and mouse work at a time, so one of those developers is just going to be sitting around doing nothing!”. In a good pairing session, nothing could be further from the truth.

Programming isn’t pushing buttons, programming is solving problems. It’s normal for more than one person to work together on a solution to a problem! Just think about anytime you’ve had a productive conversation, exchanging ideas, learning, and finding new insights you couldn’t have alone. Pairing is about bringing that experience to the work of solving problems with code.

Rather than one developer sitting around, both developers can be engaged with their work, communicating, planning, theorizing, end experimenting. Pairing provides many of the benefits of code review, with the fastest possible turnaround time and the easiest communication between author and reviewer. Another person can notice that you’ve fallen down a rabbit hole and you’re far, far away from the problem you set out to solve. Rotating control back and forth can reduce fatigue from repeated actions, since it gives each of you a chance to sit back, read, think, and discuss. 

Communicating your ideas to your pair means you are continuously “rubber ducking”, explaining your understanding of the situation to someone else and having more ideas about what to do as a result. When your have a positive relationship with your pair, pairing also provides motivation to be the best version of yourself—with someone else watching, it’s harder to justify bad habits to yourself. Since future you is often the person who pays the price for your own bad habits programming, that’s a win for everyone.

### Pairing pitfalls

It’s not all roses, though. Pair programming brings with it a new set of problems, and can magnify existing problematic habits. It’s extremely common for a pair with uneven experience levels to degrade into one person working and one person watching—most likely without understanding what they’re seeing, and without learning anything. Pairing with someone who is ideologically rigid can mean you end up in an argument about every single decision, and compromise is impossible.

When pairing with someone more experienced, it’s not uncommon to feel like you’re trapped in the interview or performance review from hell—it lasts all day long, every day. That pressure creates knock-on problems, like panic and blanking in the face of uncertainty, or shaky nerves leading to more mistakes. Pairing with condescending developers acting in bad faith can be a nightmare, and in those kinds of situations pairing provides social pressure towards bad habits instead of good ones.

The rest of this talk is to help you get to a point where you can maximize those benefits while minimizing those pitfalls. It will take thought, and effort. You won’t get it right overnight, and you’ll need to keep thinking about it and working at it even after years of practice. All that work is worth it, though, because pairing can be one of the most positive and satisfying ways to experience programming.

### Two people, working together

This is a great time to talk about the first and most basic requirement of pairing: you need two people who trust each other enough to cooperate and work together in good faith. You can only be one of those people! If your pair is condescending, discouraging, insulting, or casting doubt on your skills or abilities... that’s not okay.   If you’ve ever been made to feel stupid, or like a burden, or like a lesser partner while you were pairing, that wasn’t your fault—that was the other person failing to be a good pair.

In addition, your pair has to want to work _with_ you, and not want to work _at_ you. A good pair has to be willing to share control, share ideas, and share credit. If your pair is not engaging in good faith, you have two options. First, you can call them out (if you feel safe doing that), and hope they listen and change. Beyond that, all you can do is find someone else who does want to pair collaboratively.

So! Let’s say you’ve found someone who isn’t going to condescend to you, and who wants to work with you instead of simply working while you watch. Awesome. The rest of my suggestions fall into three categories: pairing with similarly experienced devs, with devs more experienced than you, and with devs less experienced than you. The work you do is the same in all three of those situations, but behaviors that are helpful in one of them can be harmful in others.

Let’s start with the most straightforward situation: pairing with your peers, where you both have about the same amount of experience. Pairing with devs at your own level gives you the chance to swap tips, support one another in learning and growing, commiserate through the tough parts, and generally produce results that combine the best of what both of you have to offer.

Based on years of doing this kind of work, my experience is that good pairing sessions come down to consent and communication. Staying on the same page the whole time you’re working together will take some work, but it will help you produce better results.

To kick things off at the very beginning, you and your pair are going to need to communicate and consent about your programming environment. What machine, OS, editor, terminal, and shell are you going to use? Whose configuration files are going to be active?

If you’re going to pair a lot, the ideal is one dedicated pairing station per pair of developers, all running the same OS, ruby versions, editor, terminal app, and shell, all configured exactly the same way. This not only makes it easy to rotate who you’re pairing with, it makes sure everyone is able to sit down and start working at any time.

It’s not ideal, but in a pinch you can also pair on someone‘s personal machine. I strongly suggest creating a separate pairing user account, where you and your pair can work out together what to install and how to configure things. Dropping someone directly into your own personalized environment (and expecting them to just deal with it) starts things of on the wrong foot. If you want to collaborate as equals, act like it! Level the playing field to include only things you have _both_ agreed on.

### It’s not about writing code

Once you have a pairing environment ready, you’ll probably be tempted to dive right in and start writing some code. Resist! This is one of the moments pairing can be massively better than working alone. Before writing any code, establish shared understanding about the situation. Articulate the problem you want to solve with your pair, and ask them for their feedback and ideas. Keep taking turns talking until you both agree on a shared understanding of the problem. That may just take a minute, but it might also require reading documentation, researching existing code, or even seeking out designers, PMs, or other stakeholders to ask questions and clarify requirements.

Right off the bat, pairing helps you avoid assumptions you won’t notice are wrong until you’ve already built the wrong thing. Another perspective is one of the best ways to cover your blind spots. Reaching shared understanding with another person dramatically reduces the chances that you missed something without realizing it. 

Once you’ve come to an agreement about the problem you’re going to solve, work out guidelines for who will be doing the typing and who will be thinking about what you’re doing and narrating the actions and choices. Those roles are sometimes called “driver” and “navigator”, analogizing to a common division of tasks when taking a trip in a car. It’s not a perfect analogy, but it can be pretty helpful to think about dividing the labor up that way. It’s much easier to notice things, good or bad, when one person is typing and one person is observing and contemplating the broader context. 

One common approach is to combine pairing with test-driven development—in that scheme, one pair types while coding until the current red test is green and a new red test has been added. Then the driver and navigator alternate, continuing until the problem is solved or it’s time for a break.

Another approach, often called “ping pong programming”, involves one person writing a test, and the other person writing as little code as possible to get that test green, back and forth. It doesn’t work for everyone, but it can be very eye-opening to discover that the tests you thought were very thorough actually all pass when the code returns a single hardcoded value every time.

Now that you’re getting the idea, this is a good time to mention what is probably the most common problem while pairing: when you say “oh, let me just do this myself really quick”, grab the controls, and do something yourself. No! Don’t do that! Pairing is based on consent—you can’t unilaterally decide to take over the controls. As soon as you do that, pairing is over and the other person is just watching you show off.

Even if the person agrees to let you take over, though, it’s a terrible idea. The payoff of pairing is that you both understand not just _what_ is happening, but _why_ it is happening. If you can’t or don’t want to explain how and why to do something, you shouldn’t be doing it. You might be feeling frustrated that something “simple” is taking so long, but instead you should recognize the opportunity! This is a chance for the other person to gain new skills and new understanding. After this, either one of you will be able to do it.

Finally, both of your names are going to go on that code. It is the height of rudeness to ask someone else to put their name and reputation on the line for something they don’t understand or can’t do themselves.

Whichever option you pick, it needs to be clear to both people who is driving and who is navigating at any time. Trust and collaboration is hard to sustain when your keyboard and mouse are unexpectedly flying around underneath you and doing things you don’t expect or want. At its most rigid, that could be a timer that tells you when to switch. At its most fluid, that could mean requesting and yielding control as part of the conversation, with control going back and forth anytime it’s convenient. When you’re doing this right, another dev could walk up to your pair anytime and ask “who’s driving right now?”, and both of you will not only give the same answer, but feel confident about it.

Now that we’ve covered the mechanics of pairing and made some suggestions about how to pair with your peers, let’s talk about how things change when you’re pairing with someone more experienced than you are.

### Pairing with someone more experienced

Pairing with someone more experienced is a great opportunity to talk through ideas, hear about new options for solving problems, learn about tradeoffs built in to different options, and see how devs who have spent more time at this job have chosen to adapt to it.

There most common pitfall when pairing with someone more experienced is the assumption that you have nothing to contribute. It will take work, but you can fight that feeling. The person you’re paring with should be helping you fight that feeling, too. They’re on the hook to make sure that pairing is a cooperative exercise, and not just a chance for them to try to show off.

While pairing with someone experienced, your main job is to provide feedback. Hear a word you’re not familiar with? Ask what it is. See something go by too fast to tell what it was? Ask to see it again. Notice your pair jumping in and taking over the controls? Point out they took over, and ask if they can help you do the same thing instead.

Just because someone has more experience than you doesn’t mean they’re automatically right. In fact, having more experience in some areas doesn’t mean they have more experience than you in every area. When pairing with devs who seemed to know more than me about everything, I have and discovered  strengths and specializations I didn’t know I had. When pairing with devs just a few weeks into coding, I have regularly discovered that they have many kinds of experience and knowledge that I don’t.

The bigger the experience difference is, the more important it is for both of you to make sure that your time working together is informative and productive for _both_ of you, not just the supposed bigshot. Ask questions, give feedback, and work together to calibrate the speed and depth of your work so that it’s beneficial. You might feel like a burden, but trust me… the best part of pairing with someone less experienced is being able to introduce them to new things!

Another thing to keep in mind when pairing with someone more experienced is that they will know the answers to many of your questions. Rather than going straight to the API docs, or straight to Google, ask the questions you have. Humans are by far the best interface to information that you don’t understand yet. Google can answer your question, but you have to know how to phrase your question to find the right results. People can help you figure out how to phrase your question, usually with much less flailing around.

If you run across something you don’t understand, ask about it. Maybe you’ll find out the answer. Maybe you’ll figure out the answer together. Maybe you’ll find out that even experienced people don’t know a lot of stuff. Probably, you’ll do all three. Take advantage of the experience that you have access to, and work together to reach a shared understanding of concepts and code. That’s what pairing is all about.

### Pairing with someone less experienced

Pairing with a dev less experienced than yourself offers a chance to let them drive, helps you catch gaps in your planning, and makes you better at understanding and communicating your own ideas. Even though you’re more experienced, this is still a chance for you to learn, grow, and practice your skills. These are some tactics I’ve picked up that can make pairing with someone less experienced more positive, cooperative, and productive.

Before you start, establish cooperative, non-judgmental ground rules. You're going to be working together on two goals: one is getting the work done, but the other goal is giving the less experienced developer more experience.

Make it clear that computers are hard, you often don’t know what to do, and if they don’t know what to do while you’re pairing that is totally okay. If they pause, wait for them! If they pause for more than (say) 10 seconds, let them know that you're happy to wait for as long as they need, but you're also happy to start talking about what you could do next if they are feeling stuck.

Make it as hard as possible for yourself to jump in or take over. I have personally gotten a lot of use out of fidget toys or grabbing a giant stuffed animal to hug. In cases where my self-control is bad, I have sometimes even unplugged my keyboard and mouse. It's easy to not type when your keyboard doesn't work at all!

Finally, keep in mind that all of this work is ultimately a chance for you to level up yourself. High level independent contributor work depends on clear, persuasive communication. Pairing is a prime opportunity to practice and hone those skills. Coordinating development work across teams, gaining support for your policy proposal, encouraging developers to adopt good practices, and many other tasks—all require excellent communication skills.

### Programming as relationships

Ultimately, software is made _by_ people, _for_ people. Every line of code is the result of some relationship between human beings. Working with a team means planning, communicating, discussing, compromising, debugging, and more. Even though it can be hard to tell when your up to your eyeballs in code, all programming is a relationship, with stakeholders, customers, managers, and coworkers. Pair programming makes more of that relationship direct and explicit, including both the benefits and the hazards that come from closer relationships.
