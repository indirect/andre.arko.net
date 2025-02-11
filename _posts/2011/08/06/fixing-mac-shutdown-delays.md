---
layout: post
title: "Fixing Mac Shutdown Delays"
microblog: false
guid: http://indirect-test.micro.blog/2011/08/07/fixing-mac-shutdown-delays/
post_id: 4971368
date: 2011-08-06T16:00:00-0800
lastmod: 2011-08-06T16:00:00-0800
type: post
url: /2011/08/06/fixing-mac-shutdown-delays/
---
### or, How MySQL is broken on OS X

Ever since I saw James Edward Grey II [point out][1] the delay at shutdown caused by having MySQL installed on OS X, it has bugged me. A lot. I even spent a few hours trying to figure out what was going on back then, but to no avail. The only thing I was able to figure out at the time was that running `launchctl unload com.mysql.mysqld.plist` always took 20 seconds.

This last week, however, I installed MySQL 5.5 on a new MacBook Air. The first thing I discovered is that it is [deeply broken][2]. Not only is the path to the shared library incomplete, the provided OS X StartupItem doesn't work.

[1]: http://twitter.com/#!/JEG2/status/49261212801839104
[2]: http://lightyearsoftware.com/2011/02/mysql-5-5-on-mac-os-x/

Since the startup item was broken, I resolved to create a plist that would allow [launchd][3] to control MySQL. While I was creating and testing that plist, I discovered that `mysqld` completely ignores interrupts, and will happily run forever while you press ⌃C to no avail. The only way to tell the server process to stop is to send it a `SIGTERM`, via `kill` or what have you. As I made that discovery, I suddenly developed a hunch that the shutdown delay was caused by the `mysqld` process refusing to shut down when interrupted.

[3]: http://developer.apple.com/library/mac/#documentation/Darwin/Reference/ManPages/man8/launchd.8.html

After a bit of digging through the search results for `launchd 20 seconds`, I discovered the [launchd.plist][4] man page. On that page, I learned about a completely new (to me) option: `ExitTimeOut`.

    ExitTimeOut <integer>
    The amount of time launchd waits before sending a SIGKILL signal. The default value is 20 seconds. The value zero is interpreted as infinity.

[4]: http://developer.apple.com/library/mac/#documentation/Darwin/Reference/ManPages/man5/launchd.plist.5.html

The mention of a 20 second default stood out like a red flag to me, so I tried adding an entry to the MySQL plist that changed `ExitTimeOut` to one second. As soon as I did that, `launchctl unload com.mysql.mysqld.plist` took only one second to run. With great excitement, I tested out restarting my computer, and discovered that that single change completely resolved the long delays that had been irritating me.

Here is the complete code for the plist, located at `/Library/LaunchDaemons/com.mysql.mysqld.plist`.

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
    	<key>KeepAlive</key>
    	<true/>
    	<key>Label</key>
    	<string>com.mysql.mysqld</string>
    	<key>Program</key>
    	<string>/usr/local/mysql/bin/mysqld_safe</string>
    	<key>RunAtLoad</key>
    	<true/>
        <key>UserName</key>
        <string>_mysql</string>
    	<key>WorkingDirectory</key>
        <string>/usr/local/mysql</string>
    	<key>ExitTimeOut</key>
    	<integer>1</integer>
    </dict>
    </plist>

If you want to load it without restarting your machine, use the command `sudo launchctl load /Library/LaunchDaemons/com.mysql.mysqld.plist`.

Enjoy!
