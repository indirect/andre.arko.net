---
layout: post
title: "Make Rails 3 stop trying to serve HTML"
microblog: false
guid: http://indirect-test.micro.blog/2011/12/10/make-rails-stop-trying-to/
post_id: 4971379
date: 2011-12-10T00:00:00-0800
lastmod: 2011-12-09T16:00:00-0800
type: post
url: /2011/12/09/make-rails-stop-trying-to/
---
Something kind of surreal happened today. I noticed that one of my Rails 3 apps was logging `ActionView::MissingTemplate` errors. When I looked into it, the error was coming from an HTML template that didn't exist. The problem was, that action wasn't supposed to serve HTML at all, ever. I had even dutifully called `clear_respond_to; respond_to :xml` in my controller, and I thought that would fix everything. Unfortunately, googling and checking Stack Overflow turned up nothing relevant to this particular version of the error, so I decided I had better just dig in.

The request was strange. It came from an IP address in China, and claimed to be asking for `http://www.google.com/index.html`, even though the request was sent to my server's IP. After some experimentation, I figured out that there was a problem with my routes: Rails 3 defaults to allowing any regular request to have its format specified with a file extension, like `.html`. So even though I was responding with XML when the format wasn't specified, my controller was trying to return HTML when it was explicitly requested.

The `resource` routes allow you to supply a `:format` parameter that sets the format for all requests to that resource. I thought that regular routes had a `:format` parameter that worked the same way. It turns out they don't. Regular routes (set by calling `match`, `get`, `root`, and the like) will take `:format => :xml` as an argument. But it turns out that argument is just a shortcut for `:defaults => {:format => :xml}`. So while the format was XML if you didn't ask for anything else, explicitly requesting HTML would still get you HTML.

The solution turned out to be adding `:constraints => {:format => :xml}` to the route as well as setting the default format. That means that the routes you still want, like `/index` and `/index.xml`, will still work. Even better, it will reject requests for `/index.html` as an invalid route, since the format no longer matches the constraint. Problem solved, but man that took more work than I was expecting to figure out.
