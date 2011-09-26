---
title: "'From' address keyboard shortcuts in Lion"
layout: post
---

Mac OS X contains a truly helpful feature in the Keyboard system preference pane that allows you to set a keyboard shortcut for any menu item in any application by name. In Snow Leopard, I used this feature to add keyboard shortcuts for selecting the "From" address while I was composing an email in Mail.app. I had configured it so that ⌃1, ⌃2, etc. would switch between my personal, work, and other email accounts. The menu items in Mail.app are titled things like "Andre Arko <andre@arko.net>", so it was easy to assign a keyboard shortcut to that item by name. Unfortunately, Lion's Keyboard preference pane adds a bug with menu item titles that contain angle brackets. The bug escapes angle brackets incorrectly when inserting them into the application's preferences plist file. As a result, the keyboard shortcuts are never activated.

After some manual investigation, I figured out that Mail's plist file was getting entries that looked like "\eAndre Arko <andre@arko.net\e" instead. I [filed a bug with Apple](http://openradar.appspot.com/radar?id=1288404), but I haven't gotten a response, so I figure I'm stuck with it for a while. With some experimentation, I discovered that it's possible to manually edit the plist to fix the shortcuts, but the bug is re-triggered whenever you open the Keyboard prefpane. To automate fixing the Mail shortcuts after changing other settings, I wrote a ruby script:

```
#!/usr/bin/env ruby
require 'rubygems'
require 'plist'

path = File.expand_path("~/Library/Preferences/com.apple.mail.plist")
# Convert to XML plist so the plist gem can read it
system("plutil -convert xml1 '#{path}'")

# Parse the plist into a hash
prefs = Plist.parse_xml(path)

# Gsub away the buggy values from the Lion Keyboard.prefpane
user_keys = prefs["NSUserKeyEquivalents"]
user_keys.keys.each do |key|
  shortcut = user_keys.delete(key)
  fixed_key = key.gsub(/\e(.*?)\e/, '\1>')
  user_keys[fixed_key] = shortcut
end

# Write out the fixed plist as XML
File.open(path, "w"){|f| f.write(prefs.to_plist) }

# Convert the XML plist back to binary for Mail.app
system("plutil -convert binary1 '#{path}'")
```

I also posted [the code as a gist](https://gist.github.com/1131361) if you'd like to fork it or comment on it. So far, there is [a fork that adds support for Sparrow](https://gist.github.com/1225867), the standalone Gmail client, as well.