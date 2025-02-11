---
layout: post
title: "Fix newrelic.yml symlink errors on Engine Yard"
microblog: false
guid: http://indirect-test.micro.blog/2012/01/24/fix-newrelicyml-symlink-errors-on/
post_id: 4971381
date: 2012-01-24T00:00:00-0800
lastmod: 2012-01-23T16:00:00-0800
type: post
url: /2012/01/23/fix-newrelicyml-symlink-errors-on/
---
Perhaps you, like me, occasionally deploy Ruby applications to [Engine Yard Cloud][ey]. And perhaps you, also like me, use the lovely [NewRelic][nr] analytics package provided to all Engine Yard customers. If you do, you have probably noticed that the [`newrelic_rpm` gem][rpm] complains in development if you do not have a `config/newrelic.yml` file.

Naively, I created this file and added it to git, thinking that that would make the warnings go away and make everything wonderful. For a short time, I even thought it had. But then I noticed that every time I deployed my application, the deploy output contained a new error message. This error message repeated several times, possibly even once per server that I was deploying onto, and made me very sad. The error looks like this in the deploy output:

```
~> Symlink other shared config files
ln: creating symbolic link/data/appname/releases/3000102030405/config/newrelic.yml': File exists
~> Symlink mongrel_cluster.yml
```

Today, I finally figured out how to stop that error from appearing. Logically enough, the abstract idea is to just remove the `newrelic.yml` file before the engineyard gem attempts to create a symlink with the same name. In practice, that is tougher than it sounds. It turns out that the "Symlink other shared config files" step takes place very early in the deploy process.

I first tried the `before_symlink.rb` hook, but that refers to when the release directory is symlinked to `current`. That is much too late in the deploy process to fix this. Next, I tried the `before_migrate.rb` hook, which is suggested in the [deploy hook documentation][doc] for people who are confused by the symlink hook. That wasn't early enough either. I finally discovered the `after_bundle.rb` hook while perusing the docs again, and that worked! So here is the code you should add to `deploy/after_bundle.rb` in your application:

```ruby
# remove the NewRelic config to avoid a warning when it is symlinked
run "rm -f #{release_path}/config/newrelic.yml"
```

That's it. Once the `after_bundle.rb` file is checked in to your repo, your deploys should be warning free.
