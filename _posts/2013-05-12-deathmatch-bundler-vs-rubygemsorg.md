---
title: "Deathmatch: Bundler vs. Rubygems.org"
layout: post
---

<p class="aside">This talk was given at <a href="http://2013.scottishrubyconference.com">Scottish Ruby Conference 2013</a>, and the slides are <a href="https://speakerdeck.com/indirect/deathmatch-bundler-vs-rubygems-dot-org">available on SpeakerDeck</a>, as well as <a href="{% postfile Deathmatch-Bundler-vs-Rubygems.pdf %}">available for download as a PDF</a>. This post doesn't correlate exactly to the slides, but it has the same content.</p>

<script async class="speakerdeck-embed" data-id="57fa6d609d4901309d516e9dd498db92" data-ratio="1.77777777777778" src="//speakerdeck.com/assets/embed.js"></script>

This talk is a story of hubris, disaster, overcoming adversity, and accidentally launching a distributed denial of service attack against rubygems.org. Sorry about that, everybody. But now, the story of how that came to pass, and things came back better than ever:

### The setup

It all begins with the release Bundler 1.0, on August 30 2010. The great thing about Bundler was that you could run one command to install all the gems your application needed! The terrible thing about that one command was that it took… a really long time, unfortunately.

In just a few short weeks, developers were already tweeting copies of the XKCD “compiling” comic, but with “compiling” replaced by “bundling”. Rubyists seem to have really high expectations as far as responsiveness goes (except when starting up Rails applications, I guess).

Anyway, it was unacceptable that Bundler was slow. Slowness makes us sad. We can do better! We will do better! The estimable Nick Quaranto, creator and maintainer of the Rubygems.org Rails app, proposed an idea: instead of downloading the entire index of every gem that has ever been pushed, why not just ask for only the gems that are in the Gemfile? Just a few weeks of cooperative work later, the Bundler API was born. Rubygems.org provided an API that returned a much smaller set of dependency information, and `bundle install` could run in as little as a few seconds.

### The disaster

What we didn’t realize at the time, though, was that all the dynamic processing required significantly more CPU cycles than the rubygems.org server was accustomed to providing. Aside from the Bundler API, rubygems.org really only does two things: accept gem pushes, and update the database accordingly, and send 302 redirects to S3 for requests that are trying to download the actual .gem files. Neither one of those activities is particularly server-intensive, since redirects are cheap and pushes are infrequent. 

The Bundler API had to do a fair amount of work: looking up every requested gem in Postgres, then marshalling the arrays of output, and then caching the response into Redis before sending it. As the months wore on, more and more people upgraded to Bundler 1.1, and more and more people used the Bundler API every day. Back in 2012, there was just a single Rackspace VPS, running Postgres, Unicorn, and Redis. By October, we had reached the breaking point for that server, and it went down hard.

It was impossible to install gems for almost an entire day while the server was down, and getting it back up proved to be a challenge, since Bundler requests were still overwhelming everything. In the end, the only way to get rubygems.org back was to disable the Bundler API.

Fortunately, disabling the Bundler API didn’t actually stop anything from working — without the API, Bundler falls back on the old behaviour of fetching the entire source index. Unfortunately, this meant that all bundle installs were back to as slow as they had been on Bundler 1.0.

### The Replacement

Since hosting the Bundler API on the limited rubygems.org box was very impractical, the Bundler team decided to reimplement the Bundler API and host it by itself as a standalone app. Heroku offered to provide hosting, and we started to build a simple Sinatra app that spoke the same Bundler API that Rubygems.org had previously provided.

After some trial and error, we had a working API, but now we were worried about how it would perform. Could it support every rubyist in the whole world?  How did it compare to the old API? Did we need more servers to handle all the requests? Had we overdone it, and we were wastefully running servers that we didn’t really need?

To answer all of those questions we needed data — the only way to know if it was slow would be to measure it, and the only way to k ow if it was working would be to monitor it. So, we set up logging and instrumentation services. Librato and Papertrail have both gracefully donated accounts to the Bundler team, and we’ve been using them extensively to get a better idea of how the service is running.

When combined with Paprtrail alerts and the Metriks gem, Librato provides some fancy and beautiful graphs that allows us to see what’s going on. We used Librato to track a lot of things: response times, database queries, request complexity, traffic, and server load. We use Papertrail to send errors from the Heroku infrastructure to Librato, since we don’t have a way to track those from inside our Ruby app.

### Discoveries

As we started to track all of these things, which we hadn’t known anything about before, we discovered a few interesting trends. We knew, from the Rubygems.org team, that Bundler API requests typically took 2 seconds, and could take up to 20 seconds. As we instrumented everything on our new API, and tried to make it faster, we discovered some things that surprised us.

*Upgrading our Postgres server massively sped up response times*

In retrospect, that seems super obvious, right? We totally weren’t expecting this to be the case, becuase the dataset is so small. The entire rubygems.org database is only about 40MB after it’s been gzipped, and it’s around 250MB decompressed. Our initial setup used a small instance of Heroku Postgres, and seemed to be pretty fast. Queries returned in 5-15ms, and the median response time was around 80ms. 95th percentile response times were around 600ms.

While the median was good, the 95th percentile was slow enough that we wanted to see if we could do better. One of the things we tried, thinking that it surely wouldn’t make any difference, was to switch to a much bigger Postgres than our dataset actually needed. Shockingly, it made a huge difference. Queries started coming back in 3-5ms. Median response time dropped to around 20ms, a 4x improvement. The 95th percentile responses dropped to about 225ms.

*Caching responses into Redis slowed down response times!*

Caching is supposed to make everything faster, right? Not so much, unfortunately. We discovered that the response caching that rubygems.org had been doing wasn’t actually helpful. The list of gems in a particular gemfile is almost never exactly the same as another gemfile, and new gems were being pushed every 2-3 minutes. As a result, the server was forced to calculate the responses for more or less every single request, and then spend extra time caching the result that it was never going to be able to use again!

### Enough or too much?

Once we had worked out those somewhat surprising performance issues, we had a new question. How many Heroku dynos do we need to run to serve all the requests that we're getting? We could have simply run dozens of dynos just to be sure, but that would have been extremely rude to Heroku after they were gracious enough to donate hosting.

We started to track the "dynos in use" header, provided by Heroku. Using that header, we were able to graph dyno usage over time, see the correlation between requests and dynos, and use enough dynos to serve our peak traffic successfully. While that worked well, there was recent public outcry over the inefficiencies of their public routing system for slow single-threaded apps. Bundler API was one of those single threaded-systems, and that caused us to make another surprising discovery that I’ll talk about in a minute.

Back to the number of dynos we need — once Heroku removed that header when they reworked their router, we were at something of a loss for a while. Eventually, though, we realized that the router will tell us every time that we’re unable to serve a request in the Heroku logs. Once we realized that, it was straightforward to set up a Papertrail search that sends every hit to Librato.

Now we can graph all the response types on a single graph, including success, not found, exception, and routing failures. If there aren’t any routing failures, we can be reasonably sure that we have a sufficient number of dynos. To make sure that things stay that way, we’ve set up Librato to send an alert to Pager Duty if there are persistent routing failures. When we see that alert, we’ll know that we’ve overrun our current crop of dynos, and need to add some more.

### What server to serve

So, I mentioned that Heroku’s router isn’t that great for app servers that can only serve one request at a time. There’s been a ton of discussion around this topic recently, including posts on RapGenius and Heroku’s own blog. In case you missed it, the tl;dr is that random routing across all dynos really sucks if those dynos could be stuck serving a single very long request. When your app works like that, you need hundreds of dynos just to be able to serve the majority of requests that would (in an optimal world) only require 10 dynos.

Bundler API had initially been deployed using Puma, the recently released server written by Evan Phoenix. It supports multithreaded app servers, and we were using that ability to great effect. Unfortunately, every day or two, one of the Puma servers would get itself into a deadlock and never respond to another request, even though it would keep accepting requests the entire time. In the end, we tried running the app on Thin, and it worked, so we moved on to other things.

That all changed when Heroku talked about the routing issues, though. We benchmarked Bundler API from the outside world, and discovered that although the _internal_ response times had a median of 20ms, external requests had a median response time of 400ms or higher, with something like 5% of requests timing out altogether. That was absolutely not acceptable, so we tried other app server concurrency options.

In the end, we went with Unicorn, running 16 child processes per dyno. That provides the same concurrency on each dyno as we had with Puma, but without the occasional deadlocks. On the new unicorn-based concurrency system, the number of timed out connections dropped dramatically, and we were able to pay attention to some strange new bug reports that had started cropping up all over the place.

### Synchronizing in the cloud (gooooood luck)

After investigating reports of new and completely unknown bugs, we realized we had a pretty big problem: staying synchronized with rubygems.org as developers pushed and yanked gems over time. As part of the original system, we’d built a background process that would fetch the full index from rubygems.org and update our database as necessary, adding and removing gems that had changed.

Unfortunately, it was a very slow process (taking upwards of 20 minutes), and tended to crash when it used more memory than Heroku was willing to give it. After many unhappy users couldn’t use Bundler to install the gems that they had pushed, we managed to settle on a solution: Rubygems.org now sends Bundler an HTTP request each time a gem is pushed, and Bundler immediately adds that gem to the Bundler API database.

HTTP requests get lost sometimes, though, and so the Bundler API also runs the full updating task, albeit less frequently. By comibining both the webhooks and the background worker, the system is eventually consistent, but fully up to date as often as it can be without causing unbearable pressure on the rubygems.org servers. It is never more than an hour out of date, and most of the time updates happen within 5 seconds. Hopefully, everyone is happy.

### We can do better

At the end of all the monitoring, optimization, and tuning, the results were fantastic: responses are handled very quickly. Median response time is about 20ms, and 95th percentile response time is about 225ms. Bringing that down from 20s is pretty amazing, and I'm extremely proud of what the team of volunteers working on Bundler API has accomplished so far. As great as what we have now is, we have plans to make things much, much better.

A new index format has been proposed for the rubygems library. It will be append-only, and very easy to keep and update on each machine that installs gems. Once Bundler can start using it, running bundle install will suddenly only take a few seconds. Bundler will already know about almost all of the gems, and only have to download information about gems that have been pushed or yanked since the last time it ran. This will be… way, way, way faster.

We've planned a way to implement all the wonderful things that I've just described. Now all we need is the manpower to accomplish it, but there simply aren't very many people actively helping with either the rubygems or Bundler infrastructure. I'm hoping to change that. If you're interested in helping with the infrastructure that every rubyist uses every day, talk to either myself or Jessica Lynn Suttles, who is also on the Bundler core team. We'd love your help.
