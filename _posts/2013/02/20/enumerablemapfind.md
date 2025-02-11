---
layout: post
title: "Enumerable#map_find"
microblog: false
guid: http://indirect-test.micro.blog/2013/02/21/enumerablemapfind/
post_id: 4971400
date: 2013-02-20T16:00:00-0800
lastmod: 2013-02-20T16:00:00-0800
type: post
url: /2013/02/20/enumerablemapfind/
---
It doesn’t happen very often, but the other day I wanted a method on `Enumerable` that doesn’t exist. I had a list of regular expressions in `patterns`, and I was trying to find the expression that matched a given `string`. Rather than just return the pattern, though, I wanted to get the `MatchData` object returned by running `#match`. That’s not possible using `#find`, since it just returns the object itself, rather than the result of the code that ran inside the block passed to `#find`. The code looked like this:

```ruby
def find_match(string, patterns)
  patterns.find{|p| p.match(s) }
end
```

While reading the standard library documentation, I did manage to discover one way to get what I actually wanted. `Rexexp.last_match` is a thread-local global that returns the `MatchData` object from the last regular expression match method that was run. The global-ish access made me feel dirty, but the implementation worked:

```ruby
def find_match(string, patterns)
  patterns.find{|p| p.match(s) }
  Rexegp.last_match
end
```

I wasn’t very satisfied with that, so I asked some other Rubyists as well, but none of us could come up with anything that already existed. In the process of discussing the problem, though, I realized there was a general solution that would provide the result I wanted. It doesn’t use globals, and it works for any code, not just regular expressions matches.

```ruby
def find_match(string, patterns)
  match_data = nil
  patterns.find{|p| match_data = p.match(s) }
  match_data
end
```

It works using a lesser-known and slightly sketchy Ruby trick: if you declare a variable before you call a block, and the block assigns a value to the same variable, the value set by the block will be available after the block is done running. It’s not very intuitive, and potentially dangerous in other situations where it happens by accident, but it works great in this case.

Once I had a working solution, I realized I could easily abstract that solution into a method on `Enumerable`. I wasn’t sure what to call it for a while, but then I realized that it combines both `#map` (returning the result of the block) and `#find` (returning the first result that is not false or nil). So I decided to call it `#map_find`, and hope that’s enough for Rubyists to successfully guess what it might do. Here’s the implementation:

```ruby
module Enumerable
  def map_find
    result = nil
    find { |e| result = yield e }
    result
  end
end
```

And it works just as advertised:

```
>> [“a”, "b", "c"].map_find{|l| l.match(/b/) }
=> #<MatchData "b">
```


After adding that method to `Enumerable`, it’s extremely easy to get the result that I actually wanted. The method I had been trying to implement is back down to just one line, but this time it works exactly how I was hoping it would:

```ruby
def find_match(string, patterns)
  patterns.map_find{|p| p.match(s) }
end
```
