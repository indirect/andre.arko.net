---
date: "2011-06-30T00:00:00Z"
title: Rails page caching, Nginx, and RESTful routes
---
### Or, Why Am I Getting These 405 Not Allowed Errors

There are some situations where Rails' page caching is really great. Usually big pages that take a while to generate and are publicly available to everyone. If you're using Rails page caching, chances are good that you're also using Nginx, because everyone seems to be doing that nowadays. Suddenly, a <s>challenger</s> problem appears! If you are also using [RESTful routes](http://guides.rubyonrails.org/routing.html) as per the Rails defaults, Nginx suddenly starts throwing inexplicable `405 Not Allowed` errors.

Let's assume you have cached a page for a certain URL, like `/posts`. Once the cached file is generated, Nginx will serve that file instead of passing the request to the Rails backend. Creating a new post involves a POST request to the very same url `/posts`. Unfortunately, Nginx notices the cached file and helpfully informs you that it's not possible to issue a POST request against a static file (that 405 that is probably driving you crazy). Fortunately, there is a solution!

The solution has two steps:

  1. Set your page_cache directory to `public/cache` by editing `production.rb` to have a line like this:

        config.action_controller.page_cache_directory = Rails.root.join("public/cache").to_s

  2. Edit your nginx config file, adding these two conditionals to your server block:

        server {
            # ... your other nginx and rails configuration stuff ...

            # Don't try to serve the cache for POST, PUT, or DELETE
            # if you do try, nginx returns a 405 Not Allowed error
            if ($request_method != GET) {
                break;
            }

            # If it is a GET after all, try to serve the cache before
            # passing the request off to passenger
            if (-f $document_root/cache$uri) {
                rewrite (.*) /cache$1 break;
            }
        }

It's not that simple, and required lots of trial and error to get working, but you can just copy and paste my solution and be done. Go internet.