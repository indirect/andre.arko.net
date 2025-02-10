---
date: "2017-11-16T00:00:00Z"
title: 'A History of Bundles: 2010 to 2017'
---
<h3 class="subtitle">a one-person oral history of Ruby’s dependency manager</h3>

<small>This post was originally given as a presentation at [RubyConf 2017](http://rubyconf.org). The [slides](https://speakerdeck.com/indirect/a-history-of-bundles-2010-to-2017) and [video](https://www.youtube.com/watch?v=BXFYjO8qDxk) are also available.</small>

<script async class="speakerdeck-embed" data-id="18db05d85be142e0a3c125547eeb3098" data-ratio="1.77777777777778" src="//speakerdeck.com/assets/embed.js"></script>

When Bundler 1.0 came out in 2010, it did something really great: installed all of your gems and let you use them in your app. Today, Bundler does something really great: it installs all your gems and lets you use them. So, given that, why has Bundler needed thousands upon thousands of hours of development work? What exactly has changed since then? Prepare to find out.

This post combines a historical retrospective with a guide through Bundler’s advanced features, which were almost all added in releases after 1.0. Since Bundler has been actively developed for almost the entirety of the seven years that it’s been around, there are a lot of things to learn about.

By the time you’ve finished reading this, you’ll have a better understanding of why Bundler has needed ongoing development, what that ongoing development has accomplished, and how to use Bundler’s advanced features to help you with their own work and projects. So! Let’s get started.

### The Road to 1.0 (2008-2010)
When Ruby was first released, sharing code with other developers meant copying files by hand and then using  `require` and the `$LOAD_PATH`. It was a lot of work, and "versions" meant comments inside the files you had downloaded from the author's personal website.

Later, Jim Weirich, Chad Fowler, and Rich Hickey worked together, combining their forces for the power of good, and created RubyGems. With RubyGems, any library could be installed with a single command, and required and used immediately. It was immensely easier than manually downloading tarballs full of Ruby files and requiring them. It was so much better that we were happy with it for a long time.

After a few years, we noticed that while installing gems was easy, using them in an application was unpleasantly hard. When gems released new versions, the next developer or server to install that gem would get the new version—even if that broke the app. This caused a lot of pain, and for a while the most popular approach was to commit all of your gems into your git repo, since at least then you knew they would be the same on another machine.

That world gave birth to Bundler, the application dependency manager. Today, managing app dependencies with Bundler is taken for granted, and everyone does it. However! In the long ago times (like 2008) there was no such thing as dependency management. There was simply installing some gems, running your development server, and crossing your fingers. To hear more details about how sharing Ruby code evolved over time, check out my talk from last year, titled [How Does Bundler Work, Anyway?](https://andre.arko.net/).
  
Despite being used in nearly every Ruby application and script today, Bundler was developed in response to a specific developer need: web applications with many complicated gem dependencies, especially frameworks composed of many gems. When Bundler was first prototyped, that framework was Merb. 

As time went on, the Merb and Rails teams agreed to merge, and the framework Bundler was being designed for switched to Rails 3. At the time Bundler launched, a default Rails app needed something like 18 gems. Today that number is closer to 30—which that is only possible because of Bundler.

There were a couple of specific insights driving the development of Bundler as a tool: first, that an _install-time dependency resolver_ was needed. Second, the resolution process had to produce a _lockfile_ that could then be used to repeatably install the exact same gems on another machine at a later time. 

So what is a _dependency resolver_? Put simply, it takes the list of gems that you have asked for, asks those gems what gems they need, asks _those_ gems which gems they need, and so on. Eventually, it has a complete list of every gem that could possibly be needed. At that point, it checks every _version requirement_ to make sure that they are all compatible. For example, one gem might depend on `rack > 1.0`. Another gem might depend on `rack <= 2.2`. Those requirements are compatible, since versions like `1.1.1` or `2.0.4` will meet both of them.

What about _install-time_? If you do your dependency resolution while you are installing gems, before you are running your application, it is possible to flag problems in advance. If you are resolving dependencies after the application is already running, it might be too late. For example, if you run a certain version of the Thin web server, and then try to load ActiveSupport, your app will always crash. It crashes because Thin can only use one version of Rack, and ActiveSupport can only use a different, incompatible version. As you can imagine, finding out about these sorts of problems before you deploy your application to your production servers can be extremely useful.

Finally, when we talk about the _lockfile_, we mean that the resolved dependencies need to be written down somewhere, so that those exact gems and versions can be installed again later. Those written down gem names and versions make up the “bundle” that gives its name to the Bundler gem. Installing and running Ruby software in a deterministic and repeatable way is the goal behind the entire Bundler project.

The tooling built on top of those concepts is almost entirely recognizable today, almost ten years later: devs put gems into a `Gemfile`, they run `bundle install`, and then they use `bundle exec foo` to run the `foo` command inside their bundle.

One especially nice feature, for the time it came out, was the ability to use gems directly from git repos. Before Bundler, using a gem before it was released was a huge hassle. Once you had the changes in git, you still had to build a .gem file from those changes and then run your own gem server just for that version, or release a new gem with a different name and switch to depending on that new gem instead.

GitHub tried to help with this problem by automatically creating .gems from any repo that contained a gem. The new problem became GitHub’s explosion of gems: every time someone forked a gem, GutHub had to add a new gem named `username-gemname` to their server. Even worse, public gems that depended on these per-user forks needed both RubyGems and GitHub to be up at the same time to install their gems. Thanks partly to Bundler’s support for git gems, GitHub decided to shut down their gem server, and removed it entirely a few years ago.

To encourage developers to create their own gems, and feel comfortable forking and editing other gems, Bundler 1.0 included tools for creating, building, and releasing gems. The `bundle gem` command generates a new empty gem, and the Bundler gem helpers provide `rake build` and `rake release` tasks. Today, not only are most gems installed with Bundler, but most gems are created with Bundler as well.

While using Bundler to create and manage gems might feel obvious and natural nowadays, using early versions of Bundler felt unnatural or unnecessary to many Ruby devs. The entire concept of Bundler was met with a lot of resistance, andt he Bundler team spent a lot of time discussing, arguing, debating, and cajoling developers on the internet. It was so non-obvious, in fact, that I gave [an entire talk at RubyConf 2010 arguing that Bundler was actually worth using](http://andre.arko.net/2010/06/09/railsconf-2010-bundler-talk-slides/).

### Now It’s Too Slow (2010-2012)

Fortunately, within a couple of years the community resistance had largely died down. Bundler had proven itself to be a hugely useful tool in the day-to-day workflow of many developers and companies. Once Bundler started to see widespread adoption, there was a new problem to address: many users means many edge-cases. For several months, the entire Bundler team focused on fixing bugs, handling tricky edge cases, and trying to keep things working as more and more users appeared. Finally, once things had settled into a relatively steady state, the Bundler team started hearing about a new problem: installing gems is really, really slow.

Part of that was because while making and shipping Bundler 1.0, we had focused almost exclusively on making it work. We did complete ground-up rewrites of how Bundler worked internally moving from 0.7 to 0.8, and then again from 0.8 to 0.9, and finally another time moving from 0.9 to 1.0. By the time we were trying to ship 1.0, it was almost entirely about being excited that we had something that actually worked to resolve, install, and isolate gems for an application.

On top of not focusing on performance, when Bundler was still new it wasn’t yet being used by huge, old applications. After we shipped 1.0 and promised stability and backwards compatibility, many more applications started using Bundler. The size of a “typical” Gemfile went up very quickly during the first few months and years of Bundler’s existence. Today, it’s not uncommon to see businesses built around Ruby webapps that have not just 200 or 300 gems, but sometimes 500 or 600 gems! We could never have imagined a single application with that many dependencies while we were trying to ship Bundler 1.0.

Since Bundler was slow while installing big applications, you might think that would mean it was at least fast installing small applications. Unfortunately, that wasn’t true either. Even if your Gemfile only had one gem in it, and that gem had no dependencies, we still had to download the list of every gem in existence from RubyGems.org. So we were in a place where small installs were slow because of downloading more data than we needed, and big installs were slow because we had never optimized for installing hundreds of gems.

At this point, while the Bundler team was mostly sitting around discussing possible ways to try and solve the problem, someone else decided to simply do it. Nick Quaranto (the original creator of the RubyGems.org app) pragmatically wrote a new API for RubyGems.org, shipped it, and let us know that we could use it. Instead of returning information about every gem in existence, it only returned information about the gems it was asked about. If you’re interested in the details of the new API, I gave a talk at Ruby on Ales 2012 with Terence Lee about [the process of reworking Bundler to use the new API](http://confreaks.tv/videos/roa2012-bundle-install-y-u-so-slow).

If you had a fast connection, or a small Gemfile, this was _way_ faster. The catch to this speed-up was that Bundler now needs to make many individual requests to the server. If your Gemfile said Rails, Bundler would ask the server about Rails, but then it would learn it needed to ask about ActionPack, and then need to ask about Rack, etc. As long as you could reach the RubyGems servers quickly, making more requests was much faster than downloading lots of unneeded data.

If the RubyGems servers were far away, however, which they were for anyone outside the US, it was either the same speed or slower. For apps with huge numbers of dependencies, it was _much_ slower. If you lived in Europe, it was generally no faster, and if you lived in Japan, Australia, or had a wireless connection in the US, it was usually a little slower. If you lived in Africa, you could forget about it. I heard from more than one South African dev that they could run `bundle install`, go make a cup of coffee, and drink most of it before Bundler could finish.

That slowness was a problem, since we wanted installing gems to be faster for everyone. In response to these issues, the Bundler team started working on a new index format—some way to install gems without needing to either make many requests or download metadata about every gem that exists. It took almost three years to finish that new format, so we’ll come back to it later.

During this period, we also continued to develop Bundler, fixing bugs, adding features, and trying to make it better for everyone who writes Ruby. Some especially notable features from this era include:

The `clean` command, which removes installed but unused gems after the Gemfile changes. Before `clean` was available, CI systems and platforms like Heroku had a problem: installing all gems for every new commit is slow, but installing new gems on top of old ones meant unused old gems would stick around, even if the app didn’t need them anymore. Adding `bundle clean` meant reusing installed gems without unused gems piling up over time.

The `outdated`command allowed users to see which gems in their Bundle has new versions, without having to update to those versions. It also surfaced updates that were not allowed by the version requirements in the Gemfile, alerting devs even when an `update` would have ignored the new version.

We expanded the `cache` (aka `package`) command to include git gems when asked, allowing users to create a single directory containing everything they need to install their app on another machine even without access to RubyGems or GitHub.

As part of improving support for Git gems, we also added support for developing dependencies locally. By running `bundle config local.rack ~/src/rack/rack`, you can tell your application to use your local git checkout of rack instead of installing the rack gem. Even better, Bundler will update your lockfile with the latest commit in that repository, ensuring that when you deploy later, you’ll get the exact same code. And if you forgot to push to the dependency repo, like I usually do, Bundler will let you know it is missing, which is awesome.

Finally, we added support for Ruby versions inside the Gemfile. If you want to make sure that all of your devs and your production servers are all running the exact same version of Ruby, you can do that as simply as adding `ruby` to your Gemfile. This feature wound up causing some problems, but we’ll get to that later. For now, let’s move on to the next era in Bundler history, where we’ll discover many ways that fixes from this era caused their own, new problems.

### Victims of Our Own Success (2012-2014)

The biggest thing that happened during this era is that Bundler adoption really took off. Bundler 1.0 came out in August of 2010, and averaged 8,700 downloads per day. Bundler 1.1 was finally released in March 2012, and it averaged 20,000 downloads per day. By the time Bundler 1.2 came out in August 2012, it was averaging 30,000 downloads per day.

The growing number of Bundler users slowly built up until October 2012, when we discovered that Bundler was effectively running a DDoS attack against RubyGems.org when the servers went down, hard. There was no way for the existing architecture to handle the huge number of requests coming in at all times. We had to completely disable the dependency API, and Bundler went back to being slow.

At this point, a team including myself, Terence Lee, Larry Marburger, and others, took the time to design, implement, deploy, and scale a separate Bundler API web application to serve the dependency API for Bundler users. With the cooperation of the RubyGems.org team, including Evan Phoenix and David Radcliffe, we were even able to make the original API urls continue to work.

> Some people, when confronted with a problem, think “I know, I'll write a webapp and throw it up on Heroku.”  Now they have two problems.

(Apologies to Jamie Zawinski for mangling his aphorism about regular expressions.)

As you may have guessed, this did provide an API for Bundler users, but it came with a completely new set of problems! One of the problems was that our separate web application had a completely separate database from RubyGems.org itself. We tried subscribing to RubyGems.org webhooks to be notified every time there was a new gem, but sometimes the webhooks failed. We tried scraping the API for every gem every night, and we hit the API rate limits. We tried to import a database dump, and wound up with data that didn’t quite match up with the live data in RubyGems.org.

 In addition to the challenges of syncing to a continuously-updating data set, no matter what we did there was always a propagation delay between pushing a gem and being able to install that gem using Bundler. You might not think that is something that people do too frequently, but anytime replication fell behind we would see many new tickets complaining about not being able to install newly pushed gems within a few seconds. And then there was the CDN propagation delay. Some days, if you lived in Canada, it took 3 hours to see new gems after they were pushed, and there was nothing we could do about it.

On top of that, the standalone API was written on top of Sinatra and Sequel. The API application was extremely small, and I think it was a completely reasonable decision to make it a tiny app in a tiny framework. The downside that we weren’t expecting was existing contributors to RubyGems.org (or even developers who wrote Rails apps for their dayjob) weren’t easily able to contribute.

The story of creating the Bundler API, deploying it, and then scaling it up to handle the traffic from every Bundler user in the world is a lot longer than I have time to fit into this talk. If you’re interested, you can find out a lot from my talk [Deathmatch: Bundler vs RubyGems](http://andre.arko.net/2013/05/12/deathmatch-bundler-vs-rubygemsorg/) or Terence Lee’s talk [Bundler Y U So Slow: Server Edition](http://rubykaigi.org/2013/talk/S54).

While we had a lot of additional work to do, the growing popularity of Bundler meant that it had many more users, and some of those new users turned into new contributors. With the help of new core team members, we were able to ship several significant improvements to Bundler in addition to the new API service.

The biggest new feature was the addition of threaded downloading and installation of gems. Using every core of a multi-core CPU meant dramatically faster installs. Bundler was finally IO-bound, by the network and disks, rather than downloading, decompressing, and installing just one gem at a time.

We also rewrote the dependency resolver at this point, refactoring it to stop using recursion thanks to a contribution from Smit Shah. On Ruby 1.8 and 1.9, the recursion was usually not a problem, but on JRuby, where stack frames take up more memory, the thousands of recursive calls could easily overflow all available memory and cause Bundler to crash.

This time period is also when Git and GitHub added support for using git over HTTP instead of only over SSH. Hoping to take advantage of the ways that HTTP git operations can be faster than the same operations over SSH, Bundler added support for HTTP authentication during git operations.

Last, and possibly saddest, Bundler had its very first CVE. If you’re interested, I’ve given another talk [on security and the background behind CVEs](http://andre.arko.net/2013/08/22/security-is-hard-but-we-cant-go-shopping/). The short version is that a CVE means that your software has a critical security issue. 😰 In our case, the critical security issue was that we allowed multiple `source` declarations inside a Gemfile, and simply looked inside every source for every gem that we needed. Unfortunately, since anyone can claim a gem on RubyGems.org, the possible name conflicts create a security risk.

If you run a private gemserver at your company, and use a private gem that you have named `my-cool-thing`, someone else could push a gem named `my-cool-thing` to RubyGems.org, and you might (suddenly, and without warning) start downloading and installing and running the code from that gem, which might be malicious. We [blogged about the problem, and tried to fix it](http://bundler.io/blog/2014/08/14/bundler-may-install-gems-from-a-different-source-than-expected-cve-2013-0334.html), but in the end the only way to be sure that the problem can’t ever happen is to stop allowing more than one `source` for any gems inside your Gemfile.

You can still use other sources, but you have to tie any additional sources to a particular gem. Then, Bundler will only get that gem from that source, and not use that source for any other gems. Well, that’s actually something of a simplification because of the complications added by gems in one source that depend on gems in another source, but I think it’s close enough for this discussion.

### A New Hope (2015-2017)

While we had finally accomplished our goal of a separate web service to make installing fast for Bundler users, having a separate API sucked. The API was an optimization, and so gems could still be installed if it was down, but any downtime meant a lot of upset and complaining users. Trying to keep the API up meant that the Bundler team was suddenly on call _all the time_. It was exciting to learn about devops, but keeping everything running was a huge source of stress for years.

No one wants to deal with a lot of stress for years at a time, especially not , and so this period also saw several RubyGems.org and Bundler contributors slowly burn out and drift away. Fortunately, as that was happening, the Ruby community came together and started paying developers to work on the gem infrastructure that everyone uses.

First, Ruby Central provided grants for work on RubyGems.org, Bundler, and RubyGems. Thanks to time paid for by Ruby Central, myself and others were able to finish new releases, continue development work on the compact index format, and much more.

In addition to grants from Ruby Central, Stripe also started an open source grants program. One of their grants went to a college student named Samuel Giddins. As an iOS developer, he had started contributing to CocoaPods, the application dependency manager for Objective-C. Since CocoaPods was written in Ruby, his Stripe grant was able to fund development work on a completely new dependency resolver, written from the ground up to be more easily maintained. It was also written to be used by multiple projects. Today, Sam’s resolver library Molinillo is used not just by CocoaPods, but also by Bundler, by RubyGems itself, and by Berkshelf, the Chef dependency manager.

Around the same time, Stripe and Engine Yard started funding the Bundler project, allowing us to [incorporate the first Ruby trade association, Ruby Together](https://rubytogether.org/news/2015-03-17-announcing-ruby-together). Ruby Together is a non-profit dedicated to funding open source Ruby development using funds raised from developers and companies in the community. It has slowly grown over the years, and today Ruby Together pays for regular developer time spent on Bundler, RubyGems, the RubyGems.org Rails app, the Gemstash gem server and mirror, ops work on the RubyGems.org servers, and even the new Ruby Toolbox 2.0 open source project.

While Ruby Central has given grants for specific projects, and continues to pay the server bills for RubyGems.org, they do not fund developers to do ongoing maintenance on the tools we use every day. As Ruby Together grows, it will be able to fund even more developer time, so please [join as a developer](https://rubytogether.org/developers) or [join as a company](https://rubytogether.org/companies) today. We want to be able to start supporting even more of the Ruby projects that the entire community depends on.

With support from Ruby Central, Stripe, and Ruby devs and companies around the world via Ruby Together, the Bundler and RubyGems projects started to see work done by paid devs. Probably not too surprisingly, this resulted in much more regular, consistent development work. That, in turn, meant we were able to ship projects that had been in progress for years.

The first project that we were able to finish thanks to paid dev work was migrating the entirety of RubyGems.org to run behind the Fastly CDN. This means that whenever you or your computer makes a request to https://rubygems.org, you are actually talking to the closest Fastly server. Since Fastly runs servers in hundreds of data centers around the world, users all around the world see dramatically faster responses. Installing gems is not longer bottlenecked by reaching around the world to the servers in AWS on the West Coast of the US.

Before moving everything to be served by Fastly, the situation was pretty crappy: your computer would have to make a request all the way to the West Coast, and then that server would send back a redirect request that sent you to the closest CDN server, and then that CDN server might have the file cached, or it might have to go and get the file from our servers on the West Coast itself, and then give that file to you. As you can probably tell just listening to that description, that system was slow, and complicated, and hard to understand, and often had problems.

Once that was done, we started to move the Bundler API back into the RubyGems.org Rails app. In the years since we had moved it out, the RubyGems ops team had done a great job of building a new and scalable architecture on AWS that could easily handle all of the traffic from every Bundler user. Amazingly, by the time we moved it back into the Rails app, there was already 10x more traffic than there had been when it took RubyGems.org down the first time. This time, with a paid devops team behind it, RubyGems.org was able to handle the API traffic without any issues. Today, the separate Bundler API has been shut down, and everything is served from the RubyGems.org servers.

Parallel to getting RubyGems completely moved over to Fastly, the RubyGems and Bundler teams were working to complete the long-awaited compact index format. In short, it is a plain-text format, with one file listing every gem name and version number, and one file per gem listing the full dependency information for each version of that gem. The text files are append-only, so that they can be cached on each machine and updated by requesting only the part of the file that comes after the part that is already cached.

Even though the new format had been proved to work by a prototype I wrote, it took more than a year for myself, Sam Giddins, our Google Summer of Code student Felipe Tanus, and the rest of the Bundler and RubyGems.org teams to work together to finalize the format, write server and client libraries, and release. For more information about the compact index and related changes, check out the talk [Extreme Makeover: RubyGems Edition](http://andre.arko.net/2013/12/09/extreme-makeover-rubygems-edition/) from RubyConf 2013.

By combining the power of Fastly’s CDN and the caching strategy of the compact index, installing gems became faster again, no matter where you lived in the world. Today, most of the time in a `bundle install` run is actually installing gems, rather than resolving complicated gemfiles or downloading information about gems.

Combining all sources of community funding, we have been able to average something like 10 or 15 hours per week of paid development time consistently spent on Bundler, RubyGems, and RubyGems.org. We’re still pretty far away from being able to employ developers to work full time on Ruby infrastructure, but even those few hours have enabled us to get a lot more done.

In addition to the Fastly migration, the completely new dependency resolver, and the completely new compact index format, we shipped a lot of features in Bundler itself. Here are some of the highlights:

After many years of discussion around [Filefiles](http://blog.hasmanythrough.com/2011/12/1/i-heard-you-liked-files) and [the misleading name of Gemfile.lock](https://github.com/bundler/bundler/issues/694), we added support for different filenames: `gems.rb` and `gems.locked`. With those filenames, it’s unambiguous that those files list gems, that one is written in Ruby, and that one contains the locked gems. No more confusing new developers about what the `.lock` extension means! The new filenames are supported today, if you want to change your existing projects. In Bundler 2.0, we will switch the default file created by `bundle init` to be `gems.rb`, but both filenames will continue to be support through at least the entire Bundler 2.0 lifecycle.

As I alluded to earlier, we discovered some problems with the `ruby` directive in Gemfiles. Namely, it was too specific, and didn’t allow setting a range of allowed ruby versions. We extended the `ruby` directive to support version requirements just like gems, and now the exact ruby version is recorded in the lockfile. This makes it possible to manage ruby version upgrades just like you manage gem versions, which is pretty nice.

Now that we record the expected Ruby version in the lockfile, it’s also possible to support the Ruby versions required by individual gems while resolving gemfiles. If you’ve ever seen an error while installing a gem that your version of Ruby is not supported, that is completely fixed in the latest versions of Bundler.

We also added new commands, including `lock` to resolve your gem versions and write a lockfile without installing those gems. We also extended the lock to support individual platforms, making it possible to lock a single application on both Unix systems and Windows systems at the same time.

Another new command, `doctor`, created by Misty DeMeo, tries to help users figure out what could have gone wrong, including gems not installed, gems with native extensions that haven’t been built, and other possible problems.

The new `bundle pristine` command works just like `gem pristine` but for the gems in your application bundle, including git gems. If you’ve ever edited an installed gem as part of debugging an issue, the `pristine` command is extremely handy for undoing those changes and going back to the factory-fresh gem files.

The `add` command works like `npm install --save`, putting a new line in your Gemfile, doing a full resolution run, and then installing any new gems. It dramatically speeds up the early stages of a project when you’re adding many gems quickly in a short period of time.

The `update` command, while not new, got a significant overhaul.  It now supports options that let you limit what kind of version upgrades you want to see. You can pass `--major`, `--minor`, or `--patch` in order to get only upgrades at that level.

For users who run gem mirrors or proxies, like Squid, Varnish or the Bundler team’s Gemstash server, it is now possible to configure Bundler to use mirrors automatically, without editing your Gemfile. After configuring a mirror, Bundler will automatically try to use the configured mirror instead of the URL listed in your Gemfile. This makes it possible to run a Gemstash or other mirror locally in an office or datacenter, greatly speeding up install operations.

We shipped a beta version of the plugin system, allowing other developers to provide new Bundler commands, hooks that run when gems are installed or updated, and even new gem sources. If you’ve always wanted to be able to install gems from mercurial repositories, you can write a plugin to make that happen.

Finally, in a nice quality of life and security improvement, Bundler now has checksums for each .gem file as part of the compact index. At install time, Bundler uses those checksums to make sure that it is installing the correct gem, and the file wasn’t corrupted in transit.

### The Future (2017-????)

Today, we’ve just shipped Bundler 1.16 with all of the features I mentioned above. We’re actively working on Bundler 2.0, with a target release date (which admittedly might slip) of Christmas 2017. I don’t have room in this talk to include details about 2.0, but I can say that we value compatibility extremely highly. 

While we plan to make breaking changes in 2.0, we want to make it easy to continue to use applications that use both 1.x and 2.x on the same machine. You’ll be able to upgrade each application individually, and at your own pace. For more information about planned changes in Bundler 2, check out Colby Swandale’s talk [Bundler 2](http://rubykaigi.org/2017/presentations/0xColby.html), from Ruby Kaigi 2017.

In the meantime, here are some Bundler best practices that you can use to get the benefits of Bundler 2.0 today! First, you probably want to set the config option `only_update_to_newer_versions` to true. That setting changes the `update` command to ensure that you will never run `update` and end up with an older version of a gem than you already have. That option will be turned on by default in Bundler 2.0.

You also probably want to turn on the `disable_multisource` setting. As I mentioned earlier in this talk, it’s fundamentally unsafe to have multiple sources in a single gemfile. We can’t raise an error by default because of existing users, but you can opt in to that option for yourself, and the option will be turned on by default when we release 2.0.

If you develop or deploy on more than one platform, especially if some of your developers or servers run Windows, you also likely want to enable the `specific_platform` option. That turns on our next-generation platform support, allowing Bundler to resolve each platform separately and install precompiled gems for the platform it is installing onto, if precompiled gems exist.

We’ve also implemented much more extensive shared caches. It’s now possible to share .gem files and compiled extensions between applications that have the same gems, by turning on `global_gem_cache`. That change pairs extremely will with another change that will be on by default in 2.0: `default_install_uses_path`. When you turn that on, Bundler will install gems separately for each application, ensuring that RubyGems never has to deal with loading unused gems only to ignore them. Combining this with the global gem cache gives every app its own set of gems without having to download or compile gems multiple times on a single machine. It’s pretty great.

Finally, while we can’t force existing users to connect to github via HTTPS, because that would break backwards compatibility, you can make that change yourself today. Include this snippet at the top of your Gemfile, and all of your `github` gems will use HTTPS to connect to GitHub:

	git_source(:github) {|repo_name| "https://github.com/#{repo_name}" }

### Fancy workflows and tools

Phew! Now that we’ve caught up completely on the history of Bundler and everything that we’ve done to it over the last decade or so, let me give you a chaser of a few more handy tips and workflows that you can use to improve your Bundler experience.

While you can always run a gem command using `bundle exec`, that depends on you being in the right directory or manually setting the location of the Gemfile. Instead, you can use `bundle binstubs GEM` to create an executable in `bin/gem`. You can run that file directly to load Bundler, find your application Gemfile, and load the correct version of that gem, no matter where you are on your system. That can be especially helpful for cronjobs, but is honestly just nicer and easier than using `bundle exec` all the time.

If you’re interested in seeing a visual layout of your application’s gem dependencies, you can install Graphviz and then run the `bundle viz` command. If your application is small enough and simple enough, you’ll end up with a graph that looks something like this:

<a class="image" href="https://andre.arko.net/2017/11/16/a-history-of-bundles/gem_graph.png">
  ![Default Rails app dependency visualization](https://andre.arko.net/2017/11/16/a-history-of-bundles/gem_graph.png)
</a>

If you want to start running your application on a new platform, like JRuby, or Windows, you can now add that platform in advance, on any machine, by running `bundle lock --add PLATFORM`. Once you’ve done that, running your application on that platform won’t cause changes to your lockfile. While Bundler can’t guarantee identical code runs on different platforms, it can guarantee that every machine on a particular platform will run exactly the same code as every other machine on that platform.

I mentioned the local git gems feature during the history section, but it’s so useful that I think it’s worth reiterating here. If you want to be able to make changes to a gem and immediately try out those changes in your application that depends on that gem, you can! Change the gem in your Gemfile to a git gem, and then run `bundle config local.GEM ~/path/to/checkout`. On that machine, Bundler will use that checkout instead of downloading and installing that gem when your application runs. As you make changes to the local checkout, Bundler will update your application lockfile to include the SHA of your latest commit to that gem, ensuring that other developers and production servers will get your changes immediately.

Ever wanted to write a simple one-file script, but the script depends on some gems? You can use `bundler/inline` to write scripts that have bundled gems. Here’s what the code looks like.

```
$ cat http.rb
require 'bundler/inline'
gemfile do
  source 'https://rubygems.org'
  gem 'http'
end
puts HTTP.get('http://example.com')
```

Here’s what running that code looks like, including installing the `http` gem as part of running the script.

```
$ gem uninstall http
Successfully uninstalled http-3.0.0

$ ruby http.rb
<!doctype html>
<html>[…]
<body>
<div>
    <h1>Example Domain</h1>
    <p>This domain is established to be used for illustrative examples in documents. You may use this
    domain in examples without prior coordination or asking for permission.</p>
    <p><a href="http://www.iana.org/domains/example">More information...</a></p>
</div>
</body>
</html>
```

In a pair of related hints, you can easily search through the code of all of the gems in your bundle by using `bundle show --paths`. For example, if your searching tool of choice is `ripgrep`, you can run `rg STRING $(bundle show --paths)` to find `STRING` anywhere in your bundled gems. Once you’ve found the gem you care about, you can open it directly in your editor by running `bundle open GEM`. Bundler will respect the `$EDITOR` environment variable, if you have set it. After you’ve edited the installed gem as much as needed for debugging, you can remove the changes you’ve made by running `bundle pristine GEM`.

Finally, in my personal favorite quality of life improvement, it is now possible to disable gem post-install messages by running `bundle config --system ignore_messages true`. Now, you can never be told to HTTParty hard, ever again.

### The End

And with that, we’ve finished our journey through a decade of Bundler history and features! If there’s anything you’re confused about, or if I left out your favorite Bundler feature or trick, let me know on Twitter, where I am [@indirect](https://twitter.com/indirect). If you have questions about Bundler, I encourage you to [join the Bundler Slack](http://slack.bundler.io), where the Bundler, RubyGems, and RubyGems.org teams, contributors, and users all hang out. We’d love to hear from you!
