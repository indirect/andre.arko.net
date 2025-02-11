---
layout: post
title: "PID numbers for Rails 3 logs"
microblog: false
guid: http://indirect-test.micro.blog/2011/08/18/pid-numbers-for-rails-logs/
post_id: 4971369
date: 2011-08-18T00:00:00-0800
lastmod: 2011-08-17T16:00:00-0800
type: post
url: /2011/08/17/pid-numbers-for-rails-logs/
---
**tl;dr**: Copy [the code][1] into `lib/pid_logger.rb` and edit your `application.rb`. Now your Rails 3 app has PID numbers on each log line. Tada.

I recently signed up for [Papertrail](http://papertrailapp.com), and starting sending all of my production Rails logs to a single consolidated place for tailing and searching. Papertrail is pretty great, but having all my logs in one place revealed a pretty big problem with default Passenger configurations. All the Passenger processes log to the same `production.log` file. This means that log lines from completely unrelated requests can get intermingled, making it impossible to tell which log lines belong to which requests. This makes the production log nearly useless for reconstructing what happened while investigating something.

A typical solution to this issue, especially for Mongrel or Unicorn setups, is to have each Rails process log to a separate file. Since I'm using Passenger, though, I came up with a simpler solution: prepend the PID of the current process to each log line. This means I can use Papertrail to filter the production log by PID number, and then I can focus on a single request as needed.

There are a lot of patches floating around the internet that change how Rails logs things, and I wasn't feeling great about copying someone else's monkepatch into my app. Ultimately, I wrote a subclass of ActiveSupport::BufferedLogger that uses some of the tricks from patches floating around the web and some of my own code. Once you install it, you'll be able to see both the PID and the log level of each line written to the production logs, greatly improving things. I suggest putting this file into `lib/pid_logger.rb`.

    # You must require this file in application.rb, above the Application
    # definition, for this to work. For example:
    #
    #   # PIDs prepended to logs
    #   if Rails.env.production?
    #     require File.expand_path('../../lib/pid_logger', __FILE__)
    #   end
    #
    #   module MyApp
    #     class Application < Rails::Application

    require 'active_support/buffered_logger'

    class PidLogger < ActiveSupport::BufferedLogger

      SEVERITIES = Severity.constants.sort_by{|c| Severity.const_get(c) }

      def add(severity, message = nil, progname = nil, &block)
        return if @level > severity
        message = (message || (block && block.call) || progname).to_s
        # Prepend pid and severity to the written message
        log = "[#{$$}] #{SEVERITIES[severity]} #{message.gsub(/^\n+/, '')}"
        # If a newline is necessary then create a new message ending with a newline.
        log << "\n" unless log[-1] == ?\n
        buffer << log
        auto_flush
        message
      end

      class Railtie < ::Rails::Railtie
        initializer "swap in PidLogger" do
          Rails.logger = PidLogger.new(Rails.application.config.paths.log.first)
          ActiveSupport::Dependencies.logger = Rails.logger
          Rails.cache.logger = Rails.logger
          ActiveSupport.on_load(:active_record) do
            ActiveRecord::Base.logger = Rails.logger
          end
          ActiveSupport.on_load(:action_controller) do
            ActionController::Base.logger = Rails.logger
          end
          ActiveSupport.on_load(:action_mailer) do
            ActionMailer::Base.logger = Rails.logger
          end
        end
      end

    end

I've also posted the code on Github [in a gist][1], for forking, commentary, and improvement. Thanks!

[1]:https://gist.github.com/1091527
