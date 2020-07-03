---
title: "symbol '_ffi_prep_closure' not found"
layout: post
---
I got a new computer today! It was very exciting. Unfortunately, when I tried to install [homebrew](https://brew.sh), I discovered that the copy of Ruby included in macOS had a small problem that manifested in the form of this somewhat inscrutable error:

```
/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/rubygems/core_ext/kernel_require.rb:54:in `require': dlopen(/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/universal-darwin20/fiddle.bundle, 0x0009): symbol '_ffi_prep_closure' not found, expected in flat namespace by '/System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/universal-darwin20/fiddle.bundle' - /System/Library/Frameworks/Ruby.framework/Versions/2.6/usr/lib/ruby/2.6.0/universal-darwin20/fiddle.bundle (LoadError)
```

I'm not 100% sure why the `fiddle` gem that came with macOS ruby wasn't able to find the symbols it needed, but [it seems like libffi changed that function name recently](https://github.com/ffi/ffi/pull/746), so maybe that was the cause of the disconnect? Unfortunately, reinstalling the latest version of `fiddle` (1.0.0 at this writing) didn't do anything to help. Happily, installing the latest commit from the git repository worked great.

To fix your `fiddle` gem, and thereby Ruby, allowing you to use Homebrew to slowly compile the universe from scratch, you can build and install the latest `fiddle` like this:

```bash
$ git clone https://github.com/ruby/fiddle
$ cd fiddle
$ bundle install --path vendor/bundle
$ bundle exec rake build
$ sudo gem install pkg/fiddle-1.0.1.gem
```

All set! Brew your way to greatness.

P.S. There's one other error you might hit, but it also has a quick solution:

```
xcrun: error: unable to load libxcrun (dlopen(/Library/Developer/CommandLineTools/usr/lib/libxcrun.dylib, 0x0005): could not use '/Library/Developer/CommandLineTools/usr/lib/libxcrun.dylib' because it is not a compatible arch).
```

If you see this, run `sudo rm -rf /Library/Developer/CommandLineTools; sudo xcode-select --switch /Application/Xcode-beta.app`. The Homebrew installer really really wants to install those Command Line Tools, but they're the wrong architecture and won't ever run. Use the devtools built into Xcode-beta instead.

P.P.S. If you also want to build Ruby yourself, to get the latest version, check out [this follow-up post](/2020/06/30/building-ruby-on-arm64-macos/).
