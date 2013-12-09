---
title: "Extreme Makeover: Rubygems Edition"
layout: post
---

<small>This was also a talk given at RubyConf 2013 in Miami Beach, FL. If you prefer, you can [watch the video] from the talk. This post contains the slide deck from the talk, and a written version of the content.</small>

<script async class="speakerdeck-embed" data-id="5951b48031690131904d529dfbcfdd99" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>

Bundler, Rubygems, and rubygems.org are vital infrastructure that every Rubyist uses just about every day. Over the last year, that infrastructure has seen a huge amount of change. This is an overview of the changes, an update on where things are now, and an explanation of where we’re going soon.

## So, what happened last year?

Playing it a little bit fast and loose with the definition of year, last October rubygems.org went down, in a big way. Bringing the site back up only lasted a few seconds before everything went down again. We eventually discovered the problem was the dependency API used by Bundler to speed up installs. The dependency API is database and CPU intensive, and there were so many users that the rubygems.org server couldn’t handle the load anymore. I gave a talk at Gotham Ruby with a lot of detail about what the problems were and how we fixed them. Essentially, the Bundler API was rebuilt as a separate Sinatra app, and we now throw a lot more CPU and database resources at it than we used to.

The next major event was at the end of January, when someone exploited a YAML security vulnerability to get unauthorized access to the server hosting rubygems.org. That meant that, potentially, any gem could have been replaced with a trojan horse that compromised machines as it was installed. Every gem had to be verified to match another copy of that gem from mirrors that were not compromised. So, the single server hosting all of rubygems.org was decomissioned. New infrastructure was built on Amazon’s EC2, with redundant servers for failover, managed by Chef recipes that are open source in the rubygems/rubygems-aws repo. One significant upside to this change is the community can now contribute fixes and improvements to the servers that rubygems.org runs on, which was never possible before.

The other significant issues this year have been more diffuse and inconsistent. Is everybody familiar with Travis, the hosted continuous integration service? Travis runs the tests for many open source projects, and they experienced seriously degraded network connections to rubygems.org. This caused a huge number of builds to fail just because of dropped or failed connections. After a thorough investigation, it turned out that the Travis network issues were a DNS configuration problem. The Travis VMs were hard-coded to use DNS servers that were on the opposite side of the country. As you may already know, gems are hosted on Amazon’s S3 storage service, and served via Amazon’s CloudFront content delivery network. CloudFront uses the location of your DNS servers to know which server it should tell you to download from. That meant Travis jobs were told to download every single gem from across the country, instead of from servers in a nearby datacenter. After the DNS issue was resolved, Travis build reliability shot up and has been steady since.

The final major issues this year were all related to SSL, the system used to provide secure HTTP connections. In order to make a HTTPS connection, the client machine must have a certificate that it can use to verify the corresponding certificate used by the server. While recent Macs had most of those certificates built-in, many Linux and Windows machines did not. Compounding the problem, some S3 endpoints recently started using new certificates that couldn’t be verified by every Mac, either. Making everything more confusing, right around the time that the certificate issue happened, there was another issue that caused connections to fail right as they were started. That issue looked similar, but had a completely different cause. We solved the certificate issue by including the needed certificates in Rubygems and Bundler directly. The connection failure issue was a connection timeout set to only a few seconds, which was not enough time to allow connections to set up over lagging internet connections. We resolved that issue by Increasing the timeout.

### How does rubygems.org work now?

Today, Bundler and Rubygems both get information about the gems available from rubygems.org. Right now, there are two ways to do that: either download the entire list of every gem that exists, or ask for just some specific gems by name using the Bundler API. When you run gem install, your computer downloads the entire list of all the gems that exist. That takes a long time and needs a lot of memory. The list is pretty big already, and only getting bigger over time. When you run bundle install, Bundler tries ask just for the gems that you need to install. Using the Bundler API, it asks for just the gems it knows about, and then just the gems those gems need, etc. If you have a fast connection to rubygems.org, that takes less time than downloading the full index.

If you live outside the US, however, that can sometimes take even more time than downloading the full index, because each round trip to AWS US-East in Virginia takes such a long time. Because all of these lists are sent as Ruby arrays, turned into strings via Marshal.dump, it’s not even possible to cache the list and update it with only the changes that have happened since the last download. So both Rubygems and Bundler download all this information again, from scratch, every time you install something.

As you can probably guess from that description (and I’m sure you know if you have ever installed gems before), this is not the fastest situation ever. Earlier this year, after setting up the new Bundler API, I spent a lot of time discussing this problem with members of the Bundler, Rubygems, and Rubygems.org teams. After incorporating all of their feedback, I devised a plan for the next generation of Rubygems infrastructure. The single goal of that plan is to make installing gems as fast as possible, using every technique that we have been able to come up with.

### The plan, Stan

The plan I came up with was relatively straightforward, but a big departure from how we have been doing things until now. Instead of using marshalled arrays, gems will be listed in plaintext files. Those plaintext files can simply be added to when new gems are created. They can also easily be cached on each machine that installs gems. Using plaintext instead of marshal means that the gem index will not need to change even if Ruby updates the marshal format. It also removes the security issues around marshal and YAML, like the one that took down rubygems.org in January, at least on client machines.

If no new gems have been released the server can reply with 304 Not Modified, and no data needs to be downloaded. Since the list of gems and the detailed information about each gem are separated into different files, requests for details can be limited to the gems that have been updated since the last update. This strategy hugely reduces both the size of the data that needs to be transferred, but also reduces the number of requests that need to be made. Those changes improve things for all Rubyists, but especially improve things for those far away from the rubygems.org servers.

An additional improvement for everyone, but especially big for those outside the US, is using the Fastly content delivery network. Not just for gems, like we do today with CloudFront, but for all the plaintext gem index files as well. That means it will no longer be necessary to make a request all the way to US-East to install gems, which will be a huge improvement.

Finally, we are working to expand the open source application that provides the Bundler API. It will provide the new index format, and it will be able to act as a mirror for Rubygems.org, caching copies of the gems that you need in your own datacenter, next to your servers. At companies with enough servers or enough paranoia to care, gem installs can be both fast and independent of the public rubygems.org server infrastructure.

### What have we done?

This summer, after I publicly announced this plan, Ruby Central was gracious enough to give me a grant to work on it. For the last several months, I have been spending one or two days a week working on the plan I just outlined. It’s starting to come together, and I’m excited to share the progress that we’ve made.

We have implemented the plaintext index in the Bundler API server. The Bundler codebase contains a client library that can download and cache the new plaintext index files. It can use the cached index files to resolve Gemfiles, and do a bundle install. We’ve made it possible to tell the server what version of each file we have, and avoid downloading the file again if we already have it. Fastly is now the CDN serving gems and gemspecs when requests are made to rubygems.org.

### What do we still need to do?

As significant as that progress is, we still have a ways to go. We will improve the client to always use persistent HTTP connections and request pipelining to speed up requests for updating index files. We will add the new index format to rubygems.org, so that everyone around the world will be able to use it. In parallel with adding the new index format to rubygems.org, we’re going to add support for the new index format to Rubygems.

Then everyone installing gems, using Bundler or Rubygems itself, will be able to benefit from the improvements that I’ve just outlined. Finally, we’re going to get all gems, gemspecs, and index files hosted by Fastly, so that requests for the gem index and requests for gems themselves can be returned by servers physically close to the person requesting them.

### The bright future

I’m extremely excited about these changes and very grateful to the Rubygems team, the Rubygems.org team, the Bundler team, and of course Ruby Central for funding this work. Installing gems will be hugely improved as a result of this system and the work that we’ve done together.

There is a Bundler release candidate, available right now, that can install gems much more quickly by using multple cores. Please test it, marvel at its speed, and let us know if it works (or doesn’t work) for you. As soon as that version is out into the wild, the next prelease version will include the index format improvements that I’ve outlined.

The work isn’t done yet, though. If you’re willing to help, we can absolutely use that help to get done more quickly. [Email](mailto:andre@arko.net) or [tweet at me](http://twitter.com/indirect) if you’d like to get involved. We can make Rubygems better for everyone, together.
