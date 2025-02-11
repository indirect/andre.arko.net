---
layout: post
title: "Self-hosted Mastodon SMTP configuration"
microblog: false
guid: http://indirect-test.micro.blog/2022/11/14/selfhosted-mastodon-smtp-configuration/
post_id: 4971988
date: 2022-11-13T16:00:00-0800
lastmod: 2022-11-13T16:00:00-0800
type: post
url: /2022/11/13/selfhosted-mastodon-smtp-configuration/
---

Since [masto.host](https://masto.host) has signups disabled at the moment, I tried deploying Mastodon to Fly.io using tmm1's [flyapp-mastodon](https://github.com/tmm1/flyapp-mastodon/) instructions. It worked surprisingly well, by which I mean about half of the documented commands were using removed option flags, I had to debug sidekiq restarting in a different random region constantly, and email sending didn't work at all.

I eventually got email sending working via [Postmark](https://postmarkapp.com), but the Mastodon documentation is _extremely_ unhelpful about how to configure sending emails: it just lists all possible ENV vars and then moves on.

Here's the env var configuration that worked for sending emails from Mastodon through Postmark, for me:

```
SMTP_SERVER="smtp.postmarkapp.com"
SMTP_PORT="587"
SMTP_ENABLE_STARTTLS="always"
SMTP_LOGIN="<Postmark SMTP Token Access Key>"
SMTP_PASSWORD="<Postmark SMTP Token Secret Key>"
SMTP_FROM_ADDRESS="<Postmark Sender Signature verified email address>"
```

Hopefully that helps someone (or at very least future me) set up outgoing emails on a self-hosted Mastodon server in the future.
