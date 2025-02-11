---
layout: post
title: "Sending Delayed Job Exceptions to Hoptoad"
microblog: false
guid: http://indirect-test.micro.blog/2011/07/02/sending-delayed-job-exceptions-to/
post_id: 4971365
date: 2011-07-01T16:00:00-0800
lastmod: 2011-07-01T16:00:00-0800
type: post
url: /2011/07/01/sending-delayed-job-exceptions-to/
---
I've been using [delayed_job][1] to handle background tasks recently. Unfortunately, my background jobs have sometimes had bugs (either in my code or in the code of the web service I usually talk to). While DJ records the last exception in the database between retries, the job itself is deleted completely on failure. Since I don't want my jobs table to fill up with every job I've ever had that failed, I decided to send exceptions that occur during DJ jobs to Hoptoad. The error is saved for posterity at Hoptoad, I get an email notifying me there was a problem, and anyone on the team can investigate the issue. Wins all around. How do you do this black magic, you ask? It's actually not too bad in the end. Create an initializer in your Rails app (I creatively name mine `delayed_job_hoptoad.rb`), and then add this code:

    # Monkeypatch Delayed::Job to send Hoptoad notifications when there are exceptions
    require 'hoptoad_notifier'

    module Delayed
      class Worker

        def handle_failed_job_with_hoptoad(job, error)
          HoptoadNotifier.notify_or_ignore(error, :cgi_data => job.attributes)
          handle_failed_job_without_hoptoad(job, error)
        end
        alias_method_chain :handle_failed_job, :hoptoad

      end
    end

Not too bad in the end. I originally called `handle_failed_job` instead of `handle_failed_job_without_hoptoad`, though, and that resulted in a stack overflow every time there was an error. Way to make things better, I know.

[1]: https://github.com/collectiveidea/delayed_job
