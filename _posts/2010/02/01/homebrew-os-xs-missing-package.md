---
layout: post
title: "Homebrew: OS X''s Missing Package Manager"
microblog: false
guid: http://indirect-test.micro.blog/2010/02/02/homebrew-os-xs-missing-package/
post_id: 4967466
date: 2010-02-02T00:00:00-0800
lastmod: 2010-02-01T16:00:00-0800
type: post
url: /2010/02/01/homebrew-os-xs-missing-package/
---


Managing software packages on unix is a giant pain. Most linux distributions are built around different ways to try to alleviate that pain. Over the years, there have been various attempts to create effective package managers for OS X. The two most popular efforts, [Fink](http://finkproject.org) and [MacPorts](http://macports.org), but they certainly have their frustrations. In both cases, creating packages or portfiles can be complex and difficult.

Fortunately for us, [Max Howell](http://www.methylblue.com/) decided that there should be a package manager that is easy to edit, and that makes creating new packages a breeze. [Homebrew](http://github.com/mxcl/homebrew) is that package manager.


## What does it do?

Homebrew alleviates the drudgery and repetition of downloading and installing unix software packages on OS X. If you're sick of `./configure && make && make install`, Homebrew can definitely help.


## Why Homebrew?

OS X already has two package managers: [Fink](http://finkproject.org) and [MacPorts](http://macports.org). If one of those is working for you, great. But if you've been frustrated by them in the past, I strongly suggest you give Homebrew a try. It's very easy to create and edit formulae, and even to edit Homebrew itself, since the core is just a few hundred lines of Ruby code.

It doesn't impose external structure on you -- the default is to install it to `/usr/local`, but you can install it anywhere. Inside your Homebrew directory, software is installed into subdirectories inside Homebrew's cellar, like `Cellar/git/1.6.5.4/`. After installation, Homebrew symlinks the software into the regular unix directories. If you want to hand-install a package or version that isn't officially part of Homebrew yet, they can happily co-exist in the same location.

That's usually not necessary, though, since formulae can install directly out of version control. If a package has a public git, svn, cvs, or mercurial repository, you can install the latest development version as often as you like with a simple `brew install`.

Installing packages is faster, too, because Homebrew also works hard to avoid package duplication. No more installing yet another version of Perl as a package dependency when you already have a working install of Perl built in to OS X.

Best of all, Homebrew has a basic philosophy that you shouldn't have to use sudo to install or manage software on your computer.


## Okay, it sounds pretty great. How do I get it?

The first (and only) dependency that Homebrew has is the OS X Developer Tools, which are on the OS X installer disc, and can be downloaded from [developer.apple.com](http://developer.apple.com).

Unless you have a reason not to, the easiest place to install Homebrew is in `/usr/local`. You can do that in just a few steps on the command line:

    # Take ownership of /usr/local so you don't have to sudo
    sudo chown -R `whoami` /usr/local
    # Fix the permissions on your mysql installation, if you have one
    sudo chown -R mysql:mysql /usr/local/mysql
    # Download and install Homebrew from github
    curl -L http://github.com/mxcl/homebrew/tarball/master | tar xz --strip 1 -C /usr/local

Once you've done that, you're good to go! Assuming `/usr/local/bin` is in your PATH, feel free to try it out:

    brew install wget
    brew info git

The Homebrew wiki also has more about [integrating with RubyGems, CPAN, and Python's EasyInstall](http://wiki.github.com/mxcl/homebrew/cpan-ruby-gems-and-python-disttools).

Keeping your copy of Homebrew up to date is easy:

    brew install git
    brew update

Once you have git installed, you can just run `brew update` anytime you want to pull down the latest formulae.


## Contributing

Creating a new formula is almost that easy. If Homebrew didn't have a formula for wget, you could create one like this:

    brew create http://ftp.gnu.org/gnu/wget/wget-1.12.tar.bz2

After you save your formula, you can test it out with `brew install -vd wget`, to enable verbose logging and debug mode. If you need help getting your formula working, there is more documentation on the [Homebrew wiki](http://wiki.github.com/mxcl/homebrew/contributing). You can also learn by example from already existing formula, like [git](http://github.com/mxcl/homebrew/tree/master/Library/Formula/git.rb) or [flac](http://github.com/mxcl/homebrew/tree/master/Library/Formula/flac.rb).

You can check out lots of example formulae, and Homebrew's internals, by running `brew edit`. The code is pretty straightforward. If you have questions, or are interested in future plans, the contributors to Homebrew tend to hang out in the #machomebrew channel on Freenode.

Once you have a working new formula, it's easy to create your own fork of Homebrew on github to push your new formula to, by using the github gem.

    git add .
    git commit -m "Added a formula for wget"
    gem install json github
    github fork
    git push <your github username> mastergitx

After pushing your change to github, go to the [Homebrew issue tracker](http://github.com/mxcl/homebrew/issues) and create a ticket with the subject "New formula: <software name>". Assuming everything checks out, your formula will be added to the main Homebrew repository and available for everyone else to use.


## Wrapping up

Homebrew is a compelling alternative to MacPorts and Fink. Both the Homebrew core and all the formulae are written in ruby, so it's easy to add new packages or even new features. If you're looking for more control over the unix software you have installed on your Mac, or you've been frustrated by other package managers in the past, check it out. I think you'll be happily surprised.

<p class="aside">This post was originally written for, and posted to, the <a href="http://www.engineyard.com/blog/2010/homebrew-os-xs-missing-package-manager/">Engine Yard Blog</a>.</p>
