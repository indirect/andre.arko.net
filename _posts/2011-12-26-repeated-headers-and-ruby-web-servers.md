---
title: Repeated headers and Ruby web servers
layout: post
---
A few weeks ago, I ran into an interesting problem with my Rails app. For some reason, the `request.remote_ip` value inside my app didn't contain the correct value. Instead, it simply contained the internal address of the EC2 instance I was using as a load balancer. I started noticing the problem when I set up a stack consisting of stunnel, HAProxy, Nginx, and Passenger.

After a huge amount of testing (and checking a lot of headers), I discovered that the raw request being delivered to Passenger contained two separate X-Forwarded-For headers. At first, I thought the problem must be in Rack, overriding the value in the headers hash with a new value when it saw the same header a second time. I dove into the Rack code thinking I had just found a giant bug... but the Rack code seemed to be doing the right thing, so I had to keep looking.

I was especially confused by the way that my local development environment (using the Pow server) didn't seem to have the problem. Eventually, I figured out that the problem isn't Rack. According to the relevant HTTP spec (namely RFC 2616), two headers can simply be interpreted as a single header with two comma-separated values. Many Rack servers do this, and so Rack gets a single header with two values. Some Rack servers don't do this, and apps running in those servers merely see the value of the last header in the request.

In order to narrow things down, I tested all of the current production-use Rack servers I could think of off the top of my head. Here's what I found:

    # Pow 
    $ curl -s -H"X-Header: 1" -H"X-Header: 2" app.dev/headers | grep X_HEADER
    HTTP_X_HEADER: 1, 2

    # Unicorn
    $ curl -s -H"X-Header: 1" -H"X-Header: 2" localhost:8080/headers | grep X_HEADER
    HTTP_X_HEADER: 1,2

    # Thin
    $ curl -s -H"X-Header: 1" -H"X-Header: 2" localhost:3000/headers | grep X_HEADER
    HTTP_X_HEADER: 2

    # Passenger-standalone (which is nginx+passenger)
    $ curl -s -H"X-Header: 1" -H"X-Header: 2" localhost:3000/headers | grep X_HEADER
    HTTP_X_HEADER: 2

    # HAProxy+nginx+passenger
    $ curl -s -H"X-Header: 1" -H"X-Header: 2" app.prod/headers | grep X_HEADER
    HTTP_X_HEADER: 2

As you can see in the results above, Pow and Unicorn both combine repeated headers into a comma-separated list that is passed to Rack. Thin and Passenger, on the other hand, take a simple "last header wins" approach.

In the end, I wound up changing my stack to use Unicorn instead of Passenger, so that I could get the values from all of the headers instead of just the last one. Hopefully the next guy with the same problem will just find this when they search, and save them from having to repeat that testing work.