---
layout: post
title: "SSLError certificate verify failed on Engine Yard"
microblog: false
guid: http://indirect-test.micro.blog/2012/02/19/sslerror-certificate-verify-failed-on/
post_id: 4971382
date: 2012-02-18T16:00:00-0800
lastmod: 2012-02-18T16:00:00-0800
type: post
url: /2012/02/18/sslerror-certificate-verify-failed-on/
---
The other day, I deployed a new feature for the first time: connect your [Devise](https://github.com/plataformatec/devise) account to Facebook via [OmniAuth](https://github.com/intridea/omniauth). I tested it out on my laptop, and everything seemed swell, but then I deployed to production.

Unfortunately, the ruby installed by Engine Yard's stack doesn't seem to be able to find the CA file that it needs to verify certificates when creating HTTPS connections. As a result, connecting to Facebook in production would throw an exception: `SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed (OpenSSL::SSL::SSLError)`.

Fortunately, the solution turns out to be pretty straightforward. All you need to do is tell ruby where the CA file is location on all the Engine Yard boxes. After some digging around, I discovered that it's located at `/etc/ssl/certs/ca-certificates.crt`. Now that you know where the CA file is, all you have to do is tell ruby where it is so it can use it.

Setting up OmniAuth is pretty easy. In your `devise.rb` file, just adjust the OmniAuth configuration to look like this:

```ruby
config.omniauth :facebook, "APP_ID", "APP_SECRET", {
  :scope => 'publish_stream', :client_options => {
    :ssl => {:ca_file => '/etc/ssl/certs/ca-certificates.crt'}
  }
}
```

Once that's done, you just need to track down any other places where you're using SSL, and tell Net::HTTP (or your favourite equivalent) where the CA file is. For Net::HTTP, that just means doing this before you make any requests:

```ruby
https = Net::HTTP.new("somehost.org", 443)
https.ca_file = '/usr/share/curl/curl-ca-bundle.crt'
```

And that is how to make your HTTPS requests work in production on Engine Yard.
