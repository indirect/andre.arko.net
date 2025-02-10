---
date: "2023-01-01T00:00:00Z"
title: Mastodon missing posts, with empty URL search results
---

**tl;dr** if you boot Mastodon without `LOCAL_DOMAIN` once, you might be unable to fetch posts from some other instances. If searching for a post URL returns nothing, try running `bin/rails r 'Account.representative.update!(username: ENV["LOCAL_DOMAIN"])'`. That fixed things for me.

So. Four hours of debugging missing posts later, here we are. The symptoms I noticed were:

- some posts were mysteriously missing on my server, even though they clearly existed on other servers
- posts that did appear were sometimes direct replies to posts that didn't appear
- searching for a missing post by full URL would return no results, even if that very post was visible in the federated feed

Confused, I started reading logs, searching the internet fruitlessly, reading GitHub issues that contained the right keywords but were different problems, checking the Sidekiq admin page, and slowly reading every single page in the Mastodon admin section. I eventually found a typo in my sidekiq config, running the _schedule_ queue instead of the _scheduler_ queue. I concluded that must have been the problem, added the missing "r", and went to bed.

The next day, I realized that I needed to verify that my fix had actually resolved the problem, and went to search for a post by full URL. It still didn't work.

Completely out of ideas about why a search by full post URL worked on any Mastodon instance except mine, I gave up and started treating Mastodon like I would any Rails app with confusing behavior: open a production console and slowly run all the code involved while looking for clues.

I had already collected a line from the Rails log, telling me what controller handled my search request:

```
method=GET path=/api/v2/search format=html controller=Api::V2::SearchController action=index status=200 duration=1368.97 view=159.18 db=462.83
```

Armed with that information, I browsed to [search_controller.rb](https://github.com/mastodon/mastodon/blob/ef4d29c8791086b11f6e36aa121ff5c9b5fa0103/app/controllers/api/v2/search_controller.rb) and discovered that search results are collected by invoking [SearchService](https://github.com/mastodon/mastodon/blob/ef4d29c8791086b11f6e36aa121ff5c9b5fa0103/app/services/search_service.rb). At that point, I was ready to start running the code myself to find out what was going on.

Step one: ssh to the VM running the Rails process.  
Step two: edit the `Gemfile` to move `pry-rails` out of the development group.  
Step three: run `bundle install`.  
Step four: run `bin/rails c` to open a Rails console with Pry.  
Step five: run `cd SearchService.new` to get into the right context.

Once I was inside an instance of `SearchService`, I could run the code I was reading in the `call` method by hand.

```
> @query = "https://aus.social/@liam/109599234831423305"
> url_query? 
=> false
```

Hmm. That's odd. Why would `url_query?` be false when the query is just a URL? Oh, looking at [the `url_query?` method](https://github.com/mastodon/mastodon/blob/ef4d29c8791086b11f6e36aa121ff5c9b5fa0103/app/services/search_service.rb#L75), it seems like `@resolve` has to be `true`. We can do that.

```
> @resolve = true
> url_query?
=> true
> url_resource
=> nil
```

Wait, why is [`url_resource`](https://github.com/mastodon/mastodon/blob/ef4d29c8791086b11f6e36aa121ff5c9b5fa0103/app/services/search_service.rb#L82) returning `nil`? That doesn't make sense either, public requests to this URL return reasonable responses. I guess that means we need to look inside [`ResolveURLService`](https://github.com/mastodon/mastodon/blob/ef4d29c8791086b11f6e36aa121ff5c9b5fa0103/app/services/resolve_url_service.rb). 

```
> cd ResolveURLService.new
> @url = "https://aus.social/@liam/109599234831423305"
> local_url?
=> false
> fetched_url
=> nil
```

It's fetching from the URL, and getting `nil`? That's downright bizzare. Okay, I guess that means we need to look into what happens inside [`FetchResourceService`](https://github.com/mastodon/mastodon/blob/ef4d29c8791086b11f6e36aa121ff5c9b5fa0103/app/services/fetch_resource_service.rb).

```
> cd FetchResourceService.new
> @url = "https://aus.social/@liam/109599234831423305"
> perform_request
=> nil
```

Okay, that's just... what. Why is `perform_request` returning `nil`? What is this `Account.representative` thing that's getting added to this request?

```
> Account.representative
=> #<Account:0x00007ffa66d5cb50
 id: -99,
 username: "localhost:3000",
 [...]>
```

Wait. The `username` attribute is set to `localhost:3000`? That's not the name of my instance, and that's not even the value set in the `LOCAL_DOMAIN` env var. I guess I should fix that, and then try again.

```
> Account.representative.update!(username: ENV["LOCAL_DOMAIN"])
> perform_request
=> nil
```

Damn. I guess that didn't fix it.

Wait. That method takes a block.

```
> perform_request{|r| r }
=> #<HTTP::Response/1.1 200 OK {"Date"=>"Sun, 01 Jan 2023 16:16:43 GMT", "Content-Type"=>"application/activity+json; charset=utf-8", [...]}>
```

Wait. That fixed it??? It works now???

One quick detour to the web UI and a single search later... yes, that did in fact fix it.

Some instances seem to refuse requests made on behalf of `localhost:3000`. Maybe it's even in an instance blocklist, which would be pretty reasonable--it doesn't make sense to try to exchange updates with a server running on localhost.

Sure would be nice if there were some way to know this had happened, though. It turns out that any call to [`Account.representative`](https://github.com/mastodon/mastodon/blob/ef4d29c8791086b11f6e36aa121ff5c9b5fa0103/app/models/concerns/account_finder_concern.rb#L18) creates a new database record if there isn't one, and saves the currently set local domain into the database forever.

Where does the local domain come from, you ask? It is set by [the `hosts` initializer](https://github.com/mastodon/mastodon/blob/ef4d29c8791086b11f6e36aa121ff5c9b5fa0103/config/initializers/1_hosts.rb#L4), which reads from the env var `LOCAL_DOMAIN`, with a fallback to `localhost:3000` if the env var is unset.

I booted the Rails server one time before setting `LOCAL_DOMAIN`, and didn't even create an account. Everything seemed like it worked perfectly until I stumbled across an instance that refuses requests on behalf of `localhost:3000`. And then it took four hours to debug.

It sure would be nice if Mastodon had some way to let you know that your `Account.representative` and your `LOCAL_DOMAIN` didn't match up, to save that four hours of debugging.

Well, hopefully it won't take _you_ four hours to debug, since you found this post. Good luck!
