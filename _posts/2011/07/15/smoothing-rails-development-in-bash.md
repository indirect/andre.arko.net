---
layout: post
title: "Smoothing Rails development in Bash"
microblog: false
guid: http://indirect-test.micro.blog/2011/07/16/smoothing-rails-development-in-bash/
post_id: 4971366
date: 2011-07-16T00:00:00-0800
lastmod: 2011-07-15T16:00:00-0800
type: post
url: /2011/07/15/smoothing-rails-development-in-bash/
---
This post covers a few ways that I've automated the repetitive tasks that are required while building and deploying Rails apps.

### Rails console

In Rails 2 apps, you get a console by running `./script/console`, but in Rails 3, you get a console by running `./script/rails console`. Because I want to open a console without having to remember which version of Rails I'm using, I wrote an alias to figure it out and do the right thing for me.

    # Rails 2 and Rails 3 console
    # usage: rc [ENVIRONMENT]
    function rc {
      if [ -e "./script/console" ]; then
        ./script/console $@
      else
        rails console $@
      fi
    }

### SSH Host Keys

Deploying apps to EC2 or something similar means that you will inevitably run into SSH telling you that the host key has changed and you could be experiencing a man-in-the-middle attack. Making the error go away requires opening your `known_hosts` file, finding the right line, deleting it, saving the file, and then trying again. It's a giant pain in the ass.

The most common "fix" that I have seen is to disable host key checking entirely, but that removes the security provided by host keys. My fix is to be able to remove stale host keys quickly and then get back to what I was doing.

    # Remove known host entries
    # usage: ssh-rm-host -n LINENUM
    #        ssh-rm-host HOSTNAME
    function ssh-rm-host () {
      if [ "$1" == "-n" ]; then
        sed -i old $2d ~/.ssh/known_hosts
      else
        ssh-keygen -R $1
      fi
    }

### Running specs

Similar to the console, running specs in Rails 3 apps requires RSpec 2 and the `rspec` binary. Specs in Rails 2 require RSpec 1 and the `spec` binary. Fortunately, the `spec_helper.rb` helps us distinguish between versions of RSpec, so we can just run the tests without stressing about versions.

    # easy spec running
    # usage: s [RSPEC_OPTS]
    function s {
      if grep -q -i "RSpec.configure do" spec/spec_helper.rb; then
        # echo "rspec2!"
        if [ -z "$*" ]; then
          rspec -fs -c spec
        else
          rspec -fs -c $*
        fi
      else
        # echo "rspec1!"
        if [ -z "$*" ]; then
          spec _1.3.2_ -fs -c spec
        else
          spec _1.3.2_ -fs -c $*
        fi
      fi
    }

### Rails logs

Tailing logs isn't actually that hard, but I type it so frequently that I got tired of doing it. While I'm at it, I'll throw in my less-related configuration that comes in handy.

    export PAGER='less' # less is more (than more)
    export LESSEDIT='mate -l %lm %f' # open in textmate from less
    export LESS='-XFRf' # don't clear screen on exit, show colors
    alias rl='less log/development.log'

### Other handy stuff

It's not directly related to Rails development, but I highly endorse [autojump](https://github.com/joelthelion/autojump/) for getting around quickly and my [tm](https://github.com/indirect/tm) tool for opening TextMate projects from the command line.

That's all I've got at the moment, but if you have any suggestions or additions I'd be interested to hear about them.
