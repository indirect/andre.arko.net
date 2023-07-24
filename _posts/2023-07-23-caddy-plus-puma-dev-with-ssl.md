---
title: "Caddy plus puma-dev with SSL"
layout: post
---

[Last time](/2023/03/05/caddy-puma-dev-for-local-development-with-custom-domains-and-https/), we talked about setting up Caddy as a reverse-proxy to puma-dev, providing automatically-managed local development Rails apps on their own dedicated `.test` domains. Either I missed this back then, or something inside puma-dev or Caddy changed in the meantime, but SSL requests stopped working inside Rails apps today, and it took me a while to figure out what was happening.

I started getting the exception `HTTP Origin header (https://example.com) didn't match request.base_url (http://example.com)`, and tracked it down to the `HTTP_X_FORWARDED_PROTO` getting sent to Rails, which was being set to `http`. Unfortunately, just setting the header `X-Forwarded-Proto: https` doesn't work, because both Caddy and puma-dev strip it out and set their own value before sending the request on to the Rails app.

After a bunch more fiddling around, I figured out how to get Caddy to generate an SSL certificate for the requesting domain, using its internal certificate authority, and make a request to puma-dev over SSL, without validating the (self-signed) certificate provided by puma-dev. With this slightly more complicated Caddy config block, SSL is again working:

```Caddyfile
*.test {
	tls internal {
		on_demand
	}
	reverse_proxy https://127.0.0.1:9283  {
		transport http {
			tls_insecure_skip_verify
		}
	}
	log
}
```
