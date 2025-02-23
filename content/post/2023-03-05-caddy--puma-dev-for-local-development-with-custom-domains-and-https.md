---
date: "2023-03-05T00:00:00Z"
title: Caddy + puma-dev for local development with custom domains and HTTPS
---

I develop a lot of webapps locally, often at the same time. For Ruby-only applications, [puma-dev][] is by far the most convenient way to handle the situation. A single setup command gets you a lot out of the box:

1. DNS resolution for all `.test` domains to resolve to localhost
1. A locally-generated SSL certificate root, so HTTPS works
1. Automatic starting and stopping of Ruby processes on demand
1. Adding apps easily: run `puma-dev link` then visit `https://appname.test`.

The one downside of puma-dev is that there's no way to set a breakpoint and interact directly with the web server in a terminal. In those tricky cases, I would typically start a dev server myself just for that breakpoint and then go back to using the puma-dev server after.

If I only ever used Ruby processes, I would have stopped there and been happy. But modern web development includes a lot of additional servers, like webpack, or esbuild, or tailwind, or other external services that have to run for local development to work. In those cases, I often use a Procfile and [overmind][] to manage the set of processes needed for local development. The problem with using a Procfile is that it removes all of the benefits of puma-dev: no more custom domain, no more automatic process management, no more SSL certs.

On top of that, even with a Procfile I would run into problems like a production app routing certain URLs to certain services. For example, I can never remember that `/admin` only exists on port 3001, while the rest of the app only exists on port 3000.

At this point, I took to [complaining online about it][1], hoping someone else would have already solved the problem for me. Alas, none of the replies indicated there was anything already written that could do this out of the box.

So how, I thought to myself, can I keep the custom domains and SSL certificates, but write my own config file that maps certain URLs to certain ports? Well, I have a program I use for that already, and it's [Caddy][]. Caddy is amazing and wonderful and a breath of extremely great fresh air in the HTTP server space, and you should use it if you aren't already.

But both Caddy and puma-dev expect to take over port 80 and 443 on localhost, so they can do their magic, and Caddy doesn't offer the local TLD that puma-dev does, nor does it manage processes automatically. How can I get the best of both?

After a frankly embarassing amount of time searching the internet and reading Caddy forum posts, I eventually concluded that there was no single thing that did everything I wanted. That's when I had a mildly deranged idea: what if I run puma-dev on a different port, and tell Caddy to reverse-proxy all `.test` domains to the puma-dev port? The puma-dev resolver will make sure that the domains point to Caddy running on localhost, and Caddy will make sure that the requests eventually reach puma-dev and from there reach my applications.

It took an hour or two of fiddling around, but I actually got it working! The puma-dev change was to install it to the default userland ports by running `puma-dev -install -install-port 9280 -install-https-port 9283`. The Caddy change was to add this block to my `Caddyfile`:

```Caddyfile
*.test {
  tls internal
  reverse_proxy 127.0.0.1:9280
}
```

Shockingly, that was all I needed to do, and everything worked at that point. Better yet, I can add specific support individual mappings, too:

```Caddyfile
app-one.test {
  reverse_proxy /admin 127.0.0.1:3001
  reverse_proxy 127.0.0.1:3000
}
```

It doesn't handle automatic process management, but it can at least offer production-like routing to multiple processes running from a Procfile.

This doesn't quite do everything that I want, since there are still hardcoded ports for the apps with custom routing, but it's closer than I've ever had before. Maybe next time I can figure out how to wrap non-Ruby processes in a Rack wrapper and make puma-dev manage them for me.

[1]: https://fiasco.social/@indirect/109927615725945076
[puma-dev]: https://github.com/puma/puma-dev
[overmind]: https://github.com/DarthSim/overmind
[Caddy]: https://caddyserver.com/
