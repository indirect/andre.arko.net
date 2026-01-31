+++
title = 'Operating Rails: what about after you deploy?'
slug = 'operating-rails'
date = 2025-11-20T10:52:56+09:00
+++

<small>This post was originally given as a talk at <a href="https://rockymtnruby.dev">Rocky Mountain Ruby</a>. The [slides](https://speakerdeck.com/indirect/operating-rails-what-about-after-you-deploy) and [video](https://www.youtube.com/watch?v=WP2fWUBPGfI) are also available.</small>

<script defer class="speakerdeck-embed" data-id="64254bb94df74086b8ece33274a25524" data-ratio="1.7777777777777777" src="//speakerdeck.com/assets/embed.js"></script>

Welcome! This is meant to serve as an introduction to deployment and operations for newer developers, but it's also a checklist that I refer back to even after 20 years of deploying Rails apps to production. What needs to be covered when going to production the first time? What needs to be covered when going to production for the 1000th time?

Before we get into those details, let me introduce myself. I'm André Arko, better known as @indirect on the internet. My biggest Ruby claim to fame is leading the Bundler and RubyGems OSS team for the last 15 years or so. Ruby Central recently kicked out the existing team, so the former RubyGems team has set up a new community-focused gem server at https://gem.coop. I hope you'll check it out.

But I'm here to talk about deploying and operating Rails applications, so let's get going. I built my first Rails application in 2004, and trying to get that application off my laptop so other people could use it is what started me down the path to madness and devops. It's been a long journey, and I have learned many things from over 20 years of watching Rails apps break in production.

Let's set the scene: an excited Ruby developer follows a Rails tutorial, creating a blog, a todo app, or some other cool idea. They walk through the code, the tests, the features. They finish the tutorial, and have a full Rails application, something cool that they want to show off to other people! That's when they realize… this is only on their laptop, and no one else can see or use it.

The most useful tutorials will mention hosting options at this point, maybe Heroku, Fly.io, Render, Railway, or DigitalOcean. If they're unhelpful tutorials, they might mention AWS, GCP, or Azure. But no matter what service they suggest, coding tutorials need to stay focused, and refer developers out to a hosting service when they want to deploy.

This is a problem, because the tutorials about how to deploy on those hosting sites all say things like "of course this introduction does not include how to secure your secrets in production". In fact, hosting tutorials usually just wave their hands and skip over most aspects of deploying and operating a true production application. I'm not sure how they expect a new dev to learn these skills, exactly, but that's what I'm going to try to cover in this talk today.

So our hypothetical Rails developer has followed a hosting tutorial, and has a shiny new application and database deployed to Heroku, or Fly.io, or Render, or whatever. Now is when they actually start to run up against the real problems of running in production: are the secrets secure? is the database backed up? what happens if there's an exception? how do you debug something that only happens on the server?

Let's break down each of the new kinds of preparation needed by category, and walk through what you need to do, and why you need to do it. Ultimately, everything that we are going to talk about today is about _confidence_. Everything happening in deployment and operations, in devops, in SRE, is all being done to increase confidence in the application—your own, your coworkers, or your customers.

The areas we're going to look at today are Errors, Data, Speed, Security, and what usually gets called Lead Time. Lead Time is the amount of time it takes for a change to go from a commit to live in production. Investing in a shorter Lead Time can return absolutely outsized benefits in every other area, because it means you can try a change, learn from it, and make another change in reaction, faster and faster. We'll talk a bit more about it at the end.

### Errors

To start with, let's focus on Errors. Conceptually, an error is any time that your user isn't able to use your site. More specifically, an error could mean your Ruby code threw an exception, it could mean some configuration is preventing your app from working correctly, or it could mean that your servers have completely blown up and there is no app available for your users to talk to. With that in mind… how will you know? That's the first and most important rule of running applications in production. You need to know in advance how you're going to find out if something is broken.

It's not popular deployment advice, but the most important way to build confidence and in your application is to test it. Test it manually, test it automatically, have other people try it and report back. Each of those things will save you more time debugging than you can even imagine right now.

Next, one of the most popular ways to increase confidence before a deploy is a second environment where you can deploy your code to test it before it is live on the main site. The test area is usually called "staging", and the main area is usually called "production". Rails has built-in support for both of those, as well as "development", which runs by default on your local development machine.

Use the staging environment as a place where you can put code that you aren't sure about, and try the new version there. After you have confidence (there it is again) in your new changes, you can "promote" them to production. Some platforms even let you bump staging to production without having to wait for a full new production deploy.

After you're releasing code with manual and automatic tests to staging and then production, the next most common mitigation strategies are exception reporting and uptime monitoring. Exception reporting does exactly what it sounds like, and sends a report to you when there is an exception in your application.

Personally, I tend to use honeybadger.io to set up exception tracking and uptime monitoring. It's free for a single user, which is great for my personal project, and I am apple to connect it to Slack so I get notifications if there are Ruby or Javascript errors, or if the site stops being reachable from the internet. Other popular options for tracking exceptions include Sentry, Airbrake, Bugsnag, and more that you can easily find with a search.

For anything that's less significant than an exception, or to help you investigate when an exception does occur, you'll also want to think about what usually gets called "instrumentation" or "observability". The most basic level here is just seeing the logs from your application, and most hosting will provide a way for you to do that.

The more advanced levels of observability include setting up additional tracking in your application, both inside the Rails framework and inside your own code. This tracking can take the form of metrics, which are numbers counting when and how many times some particular thing has happened. Monitoring that focuses primarily on metrics includes using the Prometheus open source tool, or DataDog, AppSignal, NewRelic, and others like them.

Monitoring can also take the form of traces, where your application keeps track of how long each part of a response takes, letting you see each controller, parameter, database query, http request, and anything else that happened. If you've ever heard of OpenTelemetry, this is what that is about. Honeycomb.io is the pioneer of this style of monitoring, but others like Sentry and DataDog have also added the ability to collect and review traces.

I don't always find Honeycomb's "only events and traces" style easier to use than simply reading logs, but it regularly helps me solve debugging mysteries that I would not have been able to figure out from solely reading logs, so I'm very glad to have it as an option.

Lastly on the topic of errors in production, the open-ended question to ask yourself is "how will people tell me about problems?". Do you have a contact form? A support email? A social media profile? Make sure there's some way to hear from your users, because there will always be something that doesn't set off your monitoring but still needs to be fixed… if you can hear about it.

### Data

Next up is Data. Data includes not just the stuff that users have uploaded and put directly into your database, it also includes uploaded files, and anything else that you might want while recovering from a catastrophic server failure. Server failures range from the very mundane server part died to the very surprising truck rammed into the data center's power transformer, but they all have the same end state: your server is gone.

Now that your server is gone, you need to set up something again. This is the touchiest part of any production service. Do you have a copy of the latest code? A recent database backup? Uploaded files saved somewhere you can still get to them?

Start with the code. Make sure that you deploy to production by pushing to a code host and deploying from there. Most often that means GitHub and a deploy from GitHub Actions, but the important part is that any code that goes live needs to be easy to find even if your laptop vanishes.

Next, handle the database. Use a system that automatically takes daily snapshots of your database, or build something yourself that creates daily copies. For my side projects, I have set up a daily GitHub Action that connects to my database, pulls out a copy, and uploads it as an artifact. Actions artifacts have no size limit, and just time out after 90 days, which is perfect for daily backups.

Test your backups. More than one startup has completely failed and shut down when they discovered that their backups weren't actually running, or the results were corrupted, only after it was too late. Have more than one backup, preferably one per day, and test your backups system regularly. That's the second, and most important, rule of running applications in production.

Once you have your database(s) taken care of, it's time to look at your user uploaded or created files. Using a file service like S3, B2, R2, Google Cloud Storage, or Tigris can be a huge advantage here. Those services all provide a basic promise that your files will be copied to at least 3 places at all times. While it's possible to run your own copy of Minio and treat it like S3, if the filesystem backing your Minio server crashes, those files are gone. I don't recommend doing that unless you're sure those files don't really matter.

Lastly for data, you now need to think about how you are going to deal with all of the existing production data, now constantly growing, that you can't just erase. In local development, if your schema gets into a weird state, it's easy to just create a new database and import the schema again. Now that you have a live, production database, you can't do that.

Adding, removing, and renaming database columns are all now potentially actions that could break your application. To avoid full site downtime, you need to deploy code that can handle both the old schema and the new schema, then run the schema migration, then remove the handler code and deploy again. I recommend adding the [`strong_migrations`](https://github.com/ankane/strong_migrations) gem as soon as you have a live production site, to add some guardrails that will make it harder to accidentally break either the site or your users' data.

### Speed

Now let's talk about speed. Speed from a Rails app? It's possible! In my experience, the biggest reasons that Rails apps get slow are external API calls, responses with no pagination, and accidental N+1 database queries. Rails may not be the most performant framework in the world, but it can be perfectly usable as long as you avoid those traps.

Why does the speed of your application matter? As mentioned at the start, it comes down to confidence. If users can see what is happening quickly, they trust your app to be working correctly. If your application matter takes so long that users lose interest or get distracted, that confidence is gone. Whatever did happen with that thing… hmm, I dunno.

Use the monitoring and observability tools we talked about before to keep an eye on how long your application is taking to do things. Don't use the average, because averages don't reflect any actual user experience. Instead, track a percentile that reflects how many users you can tolerate having a bad experience.

If you have 10 users per day, maybe the 90th percentile performance is what to watch because only 1 person will have a worse experience. If you have 10 million users per day, you might want to track the 99.99th percentile, because that's still 1000 people every day having a worse experience than that number.

When you find something that's slow, your main tools to fight against it are monitoring and profiling. Monitoring can tell you which users experienced the slowness, and what they were trying to do. It might even be able to tell you which SQL queries or HTTP calls made things so slow. Meanwhile, profiling can tell you what code is being run inside a given action, and help you optimize it. The `rack-prof` gem is the most well-known profiler, but there are multiple options available.

### Security

Now that you know how and why to keep your app fast, let's talk about security. There are two resources your production application has that you now need to defend: user data, and servers on the internet. One class of attacks will try to break in to your application to steal user data, like emails, phone numbers, whatever you have stored. The other type of attack is about hijacking your server to do something for the attacker, like send spam or show ads or mine cryptocurrency.

The best defense for user data is to not store it at all. If you don't absolutely need it, don't collect it, and then no one can steal it. If you need to collect user information, make sure you are only collecting what you need. If your users are supplying personal information, especially sensitive financial or identity information, make sure the data is encrypted inside the database so a simple database leak won't reveal it. It's not hard to encrypt a single model column anymore, so be sure to do it!

The best defense against attackers who want to hijack your servers is to update your libraries. Use a tool like Dependabot or Renovate to apply security fixes, so your application isn't vulnerable to known hacks. Set up a monitoring alert on your CPU and disk usage. Set up a billing alert for if your usage goes above your usual amount, so you can investigate.

Ultimately, it's always worth it to have a security policy, even if it's very simple. Provide contact information so problems can be brought to your attention. You don't need to have a security team and a HackerOne program, but you do need to have a basic awareness of what could go wrong and how you can approach handling it. Knowing you have backups that can't be deleted by someone hacking into your server is a huge advantage here.

### Lead Time

Finally, lead time. Lead time is one of the for metrics tracked by the DORA program's research into software development teams. The book _Accelerate_, written by the founders of the DORA research program, goes into much more depth than I can fit here, so I'm going to briefly summarize just this one aspect.

Lead time is the amount of time it takes to go from code being committed to that same code being live in production. If you can make a change and get it deployed into production in just a few minutes, you will have a completely different experience developing your application than if it takes hours or days. The DORA research found that small lead times is one of the biggest predictors of software projects being successful.

The overall, main finding of the DORA research project is that conventional wisdom of going slowly and carefully is exactly backwards—the teams and projects with the least errors and rollbacks are the teams that deploy the fastest and the most frequently. If you're already operating a larger or slower application in production, the biggest advice that I have is to reduce the size of each change, and make rolling out each change as fast as you possibly can.

The beginning of a project is by far the easiest time to set up the standard automations that you plan to use going forward. I strongly recommend setting up completely automatic testing and deployment. With GitHub Actions and modern hosting platforms, you can expect new commits to be tested and fully deployed to production within 5 minutes. That's a fantastic starting point to use as a base for future expansion, as your application and team grows.

### Strategy

Now that I've filled your heads with more ideas than you can probably remember, let's quickly review and then briefly discuss an overall strategy that you can use whenever you are trying to operate a production application. The big concerns after you deploy your app are: Errors, Data, Speed, Security, and Lead Time. Use those categories to review proposed changes, and look for issues you might have missed. Will the proposed change impact your ability to monitor errors? Back up user data? Respond to requests quickly? Keep your application secure? Ship changes quickly?

By keeping those categories of concern in mind, you are already better prepared to operate a production deployment than the vast majority of Rails developers. If the thought of working with those concerns is interesting or exciting to you, you probably have a bright future in DevOps or SRE. If the thought of working with those concerns fills you with unspeakable dread, you probably want to stick to bigger teams where someone else is available to handle operations and deployment.

### Self-promotion

If your team could use a boost while handling everything we've talked about today, you can get that support. I work for [Spinel Cooperative](https://spinel.coop), with developers from the core teams of Rails, Hotwire, RubyGems, and more. We would love to give your team all the advantages of 20 years spent building, deploying, and operating Ruby and Rails. Come say hi after the talk, or drop us an email at hello@spinel.coop.

### Conclusion

In the end, will listening to all the advice in this talk mean your app never goes down? Unfortunately, probably not. Downtime is something that comes for us all, and usually includes some aspect that is completely unexpected or outside of our control. Instead, this advice will make you prepared. You'll be prepared to recover from downtime, and prepared to add more protections in the future as you learn the particular issues your application needs to defend against.

Ultimately, that's the best any of us can do, and I wish you all good luck with your future deployments.
