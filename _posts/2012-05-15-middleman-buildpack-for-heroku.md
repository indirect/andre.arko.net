---
title: Middleman Buildpack for Heroku
layout: post
---

*Update*: Custom buildpacks aren't needed to host Middleman sites on Heroku anymore, making this blog post partially obsolete. I've updated my [example of a Middleman site hosted on Heroku](https://github.com/indirect/middleman-heroku-static-app) using the standard Ruby buildpack.

When I make a static site, [Middleman][mm] is my default tool. Middleman makes building static sites as easy as Rails makes building dynamic sites. It's [activately maintained][mmgithub] by [Thomas Reynolds][tdreyno], and keeps up with the latest changes coming out of Rails and elsewhere.

[mm]: http://middlemanapp.com/
[mmgithub]: https://github.com/middleman/middleman/
[tdreyno]: http://twitter.com/tdreyno

While it's an absolute pleasure to use, deploying it can be somewhat more annoying. Hosting a static site directly on S3 is an option, but it both a) costs money, and b) has extremely cumbersome permissions management. [Heroku][http://heroku.com], in contrast, is free for small sites and has fantastic permissions control. The catch is, Heroku only runs Rack-based applications.

Although Middleman ships with a Rack-compatible server, it seemed kind of silly to create a static site that gets generated over and over again with every page view. I wanted to generate my static pages once, and then just serve them directly. While it's possible to check the entire static site into git and use [Rack::Static][rackstatic] to serve each page, I wasn't really into the idea of committing build products, either.

[rackstatic]: http://rack.rubyforge.org/doc/classes/Rack/Static.html

The final solution that I settled leverages a lesser-known feature of Heroku's [cedar stack][cedar], called [buildpacks][buildpacks]. Buildpacks are sort of like Heroku's deploy scripts, since they let you run arbitrary code at deploy time. My [middleman buildpack][mmbp] automatically runs Middleman to build your static site into the `./build` directory as part of the deploy process. You can create an app on Heroku using my custom buildpack by running this command:

    $ heroku create --stack cedar --buildpack http://github.com/indirect/heroku-buildpack-middleman.git

[cedar]: https://devcenter.heroku.com/articles/cedar
[buildpacks]: https://devcenter.heroku.com/articles/buildpacks
[mmbp]: https://github.com/indirect/heroku-buildpack-middleman

Once you have the buildpack set up, you can just `git push heroku master`, and watch the output to see your site get built. Serving up the static pages is easy using Rack. I like to use Rack::TryStatic, since it allows nicer 404 pages. To make things as easy as possible, I've created a [minimal app][mmapp] that is pre-configured to work with the Middleman buildpack. You can just fork that app, run `heroku create`, and start deploying your fully-static site to Heroku. Check out the [example site][ex], deployed to Heroku, or the [app source and readme][mmapp] to learn more.

[mmapp]: https://github.com/indirect/middleman-heroku-static-app
[ex]: http://middleman-heroku-static-app.herokuapp.com/
