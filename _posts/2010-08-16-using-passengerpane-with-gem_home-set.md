---
date: "2010-08-16T00:00:00Z"
title: Using PassengerPane with GEM_HOME set
---
I use the excellent [homebrew](http://mxcl.github.com/homebrew) to manage my unix software on OS X, and as a result my bash profile includes `export GEM_HOME /usr/local/Cellar/Gems/1.8`. Unfortunately, that makes Passenger unable to find any of my gems, which is a bummer.

However, it turns out the fix is just a one-line change to the .vhost files that PassengerPane creates in `/etc/apache2/passenger_pane_vhosts`. Just add the line starting with `SetEnv` below, and restart Apache.

    <VirtualHost *:80>
      ServerName app.dev
      DocumentRoot "/Users/andre/Sites/app/public"
      RackEnv development
      SetEnv GEM_HOME /usr/local/Cellar/Gems/1.8
      <Directory "/Users/andre/Sites/app/public">
        Order allow,deny
        Allow from all
      </Directory>
    </VirtualHost>

(I use .dev as my development TLD so that my applications don't conflict with Bonjour domains on .local.)

There. Now (hopefully) I will remember this post next time, and not print-debug Passenger's environment _again_.