---
date: "2011-05-26T00:00:00Z"
title: Add true Readline to Ruby on OS X
---
I normally use OS X system Ruby. As of OS X 10.6.4, that is Ruby 1.8.7-p174. Sadly, system Ruby links against libedit instead of libreadline, which means I can't use any of my nice readline setup.

To fix that, you can install readline [with MacPorts](http://henrik.nyh.se/2008/03/irb-readline) or [by hand](http://www.jorgebernal.info/development/fixing-snow-leopard-ruby-readline) and then compile a new `readline.bundle` for Ruby to use. But I use [Homebrew](https://github.com/mxcl/homebrew) to manage my unix packages, so those instructions weren't quite enough for me.

Here's how to add true Readline compatibility to Ruby 1.8.7-p174 on OS X 10.6 using Homebrew.

    # Install readline
    brew install readline

    # Download the readline extension
    cd /tmp
    svn co http://svn.ruby-lang.org/repos/ruby/tags/v1_8_7_174/ext/readline/

    # Compile the bundle against homebrewed readline
    make readline.o CFLAGS='-I/usr/local/Cellar/readline/6.1/include -DHAVE_RL_USERNAME_COMPLETION_FUNCTION'
    cc -arch i386 -arch x86_64 -pipe -bundle -undefined dynamic_lookup -o readline.bundle readline.o -L/usr/local/Cellar/readline/6.1/lib -L/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/lib -L. -arch i386 -arch x86_64 -lruby -lreadline -lncurses -lpthread -ldl

    # Move the bundle into the right place
    cd /Library/Ruby/Site/1.8/universal-darwin10.0/
    sudo mv readline.bundle readline.bundle.libedit
    sudo mv /tmp/readline/readline.bundle ./readline.bundle

Tada! Working Readline support in Ruby, including IRB.