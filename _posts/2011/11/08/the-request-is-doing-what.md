---
layout: post
title: "The request is doing WHAT?"
microblog: false
guid: http://indirect-test.micro.blog/2011/11/09/the-request-is-doing-what/
post_id: 4971376
date: 2011-11-08T16:00:00-0800
lastmod: 2011-11-08T16:00:00-0800
type: post
url: /2011/11/08/the-request-is-doing-what/
---
### tl;dr

Don't use the `with_deleted` method added by [rails3_acts_as_paranoid][aap]. Seriously. Don't.

[aap]: https://github.com/goncalossilva/rails3_acts_as_paranoid

### launch time!

A little over a week ago, Plex launched the site I've been working on, [myPlex][myplex]. At the same time, we [launched][ann] updated Mac, iOS, and Android apps as well as new Windows and GoogleTV apps. It's pretty damn cool, if I do say so myself, and a lot of people signed up and started using it.

[myplex]: https://my.plexapp.com
[ann]: http://elan.plexapp.com/2011/10/29/plex-v0-9-5-brave-new-world/

### uhoh

I noticed a problem, though -- one of the most common requests to the app was using tons of CPU and DB time. In order to keep up with demand, we had to keep adding additional hardware. It was very strange how disproportionately bad the slow action was, though. According to NewRelic, the average response time for other requests was 400ms, and this slow request was averaging 9,600ms. Totally crazy, right?

### rails, how does it work

After employing some benchmarking, NewRelic in development mode, and a profiler, I eventually found several ways performance could be improved. The real killer, though, was a specific type of query: `SELECT * FROM table_name`. Every row in an entire table was getting queried, more than once per request! "How is this possible", I thought. "Doesn't Rails have a query cache?"

### the thrilling conclusion

Well, as it turns out, the query cache can be overridden by the `#reload` method. And when I checked the scary query backtraces, I ran into a method provided by the rails3_acts_as_paranoid gem:

```ruby
def with_deleted
  self.unscoped.reload
end
```

So every time that I tried to include items that were marked deleted in a query using scopes, `with_deleted` would fire off a full-table select before running my query! ZOMG.

### aftermath

Happily, between that fix and several other tweaks and indexes, I was able to speed up the slow request! How much, you ask? Well, the average response time on that slow API action went from 12,792ms to 1,137ms. Oh, and I was able to cut the amount of hardware serving the site by 90%. That's always nice.
