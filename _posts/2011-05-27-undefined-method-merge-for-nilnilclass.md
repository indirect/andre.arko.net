---
title: undefined method `merge' for nil:NilClass
layout: post
---

### tl;dr

If you are using Nginx and Passenger to serve a Rails app, your filesystem is full. Delete some stuff.

### The story

In what is definitely the craziest error that I have run into recently, my staging site suddenly started returning 500 errors to some requests. It even took me a while to figure that the app was erroring because I wasn't getting any exceptions reported by Hoptoad.

When I finally looked in the Rails log myself, this is all that was there:

    Started POST "/users/sign_in" for 70.36.143.76 at Fri May 27 17:03:22 -0500 2011

    NoMethodError (undefined method `merge' for nil:NilClass):

That's… not exactly helpful. I kept digging, and eventually figured out that the error only occurred on POST requests. Worse, everything was fine if I booted up a server using `rails server -e staging`. For that process, POST requests worked and everything was fine.

Hoping it was something transient, I restarted Nginx, only to discover this (even scarier) error:

    [alert]: Unable to start the Phusion Passenger watchdog: it seems to have crashed during startup for an unknown reason, with exit code 1 (-1: Unknown error 18446744073709551615)

While that may be the longest error number that I have ever seen, it still didn't give me any idea what was going on.

Finally, while trying to boot passenger by itself using `passenger start`, I saw this error:

    /usr/local/lib/ruby/1.8/fileutils.rb:243:in `mkdir': Too many links - /tmp/root-passenger-standalone-30121 (Errno::EMLINK)

Too many links! That's when it finally occurred to me that the filesystem might be out of handles, and suddenly that made sense out of my vague recollection that Nginx writes POST bodies to files to pass them to the app server.

Sure enough, /tmp was full of stuff:

    $ ls /tmp | wc -l
    31998

Most of those weren't used at all, so I started deleting them. With that, everything started working again. Magic. :P
