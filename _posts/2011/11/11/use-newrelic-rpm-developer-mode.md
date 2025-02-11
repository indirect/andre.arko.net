---
layout: post
title: "Use NewRelic RPM developer mode with Pow"
microblog: false
guid: http://indirect-test.micro.blog/2011/11/12/use-newrelic-rpm-developer-mode/
post_id: 4971377
date: 2011-11-12T00:00:00-0800
lastmod: 2011-11-11T16:00:00-0800
type: post
url: /2011/11/11/use-newrelic-rpm-developer-mode/
---
### tl;dr

```
echo 'export NEWRELIC_DISPATCHER=pow' >> ~/.powconfig
echo 'export POW_WORKERS=1' >> ~/.powconfig
```

### What now?

I have used the excellent [Passenger Pane][pp] for years without complaint. But then I upgraded to Lion, and that disabled all of my apps' `.dev` domains. Since the new local hotness seems to be [Pow](pow.cx), I tried it. Lo and behold, my `.dev` domains worked again!

[pp]: http://www.fngtps.com/passenger-preference-pane

However, trouble was lurking in my newly-functional paradise. NewRelic developer mode was disabled in all my Pow-run processes! It turns out that the NewRelic RPM gem doesn't include Pow on its list of known dispatchers. Googling around for a solution, I discovered that this was [not a new problem][tf], and it supposedly [already had a solution][sd].

[tf]: https://twitter.com/#!/thomasfuchs/status/76920868302897152
[sd]: http://stevendaniels.net/2011/04/pow-and-new-relic-rpm/

With hope in my heart, I tried the suggested solution of forcing developer mode to always be on. While that seemed to uselessly enable developer mode in the rails console, it still wasn't working when I tried to load `/newrelic`. Stymied, I gave up and moved on to other problems.

A week later, I was browsing the NewRelic docs for something else, and discovered the [holy grail][hg]. The solution is incredibly simple: just tell NewRelic what your dispatcher is named in an environment variable. Since Pow has built-in support for setting environment variables, you can do this by adding just one line to the file `~/.powconfig`:

```
export NEWRELIC_DISPATCHER=pow
```

[hg]: http://newrelic.com/docs/ruby/how-do-i-make-sure-the-ruby-agent-starts

There is one other consideration. By default, Pow runs two workers per Rack app, balancing connections between them. That is not optimal for NewRelic development mode, where request statistics are simply kept in memory for each process. To work around this, you can simply instruct Pow to run only one worker for each app, and all your requests will go to the same process:

```
export POW_WORKERS=1
```

With that, and a quick `killall pow`, NewRelic development mode was MINE YET AGAIN. And now I can get back to profiling my slow actions and sequel statements without the bother of running `rails server`. Hurrah.
