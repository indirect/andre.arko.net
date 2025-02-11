---
layout: post
title: "How does Bundler work, anyway?"
microblog: false
guid: http://indirect-test.micro.blog/2015/04/28/how-does-bundler-work-anyway/
post_id: 4971554
date: 2015-04-28T00:00:00-0800
lastmod: 2015-04-27T16:00:00-0800
type: post
url: /2015/04/27/how-does-bundler-work-anyway/
---
### a history of ruby dependency management

<script async class="speakerdeck-embed" data-id="7eaa2724d0624961bc4423a100036ce5" data-ratio="1.77777777777778" src="//speakerdeck.com/assets/embed.js"></script>

<small>This post was originally given as a presentation at [RailsConf 2015](http://confreaks.tv/videos/railsconf2015-how-does-bundler-work-anyway).</small>

Using Ruby code written by other developers is easy! Just add it to your Gemfile, run `bundle install`, and start using it. But what's really happening when you do that? How can use you someone else's code just by putting it in your Gemfile? To answer that question, I'm going to take you back in time. We're going on a tour of the history of dependencies in Ruby, from the beginning to the present day. When we're done, you'll not only understand what happens when you use Bundler, you'll understand why things work the way they do.

Starting with good old-fashioned `require`, we'll discuss how Ruby allows you to load code from files and directories. Next, we'll look at `setup.rb`, the first way Ruby developers were able to share code with one another. After that, Rubygems and the revolutionary ability to install multiple versions of the same library. Finally, we'll look at Bundler and exactly how dependency management for a single project is very different from just managing libraries.

Even though the `require` method has been around since at least 1997, which is the oldest Ruby code we have in version control, it can still be broken down into even smaller concepts. Using code from another file is functionally the same as inserting that file into your code at the place you wrote `require`.  As a result, it's possible to implement a naive require function with just one line of code.

```ruby
def require(filename)
  eval File.read(filename)
end
```

If you start thinking about how this function would work in practice, though, you'll probably notice a couple of problems. First, if you call this `require` more than once, the file will be run multiple times. It's generally a bad idea to run required code multiple times, even if the file is required more than once in different places. The second require could disrupt your program by re-initializing values, and every class and method has already been created by the first require.

How can we avoid requiring the same file twice? The simplest answer is to keep track of every file that we have ever required before, and only eval files that are being required for the first time. An implementation of this better require function would still be very simple.

```ruby
$LOADED_FEATURES = []

def require(filename)
  return true if $LOADED_FEATURES.include?(filename)
  eval File.read(filename)
  $LOADED_FEATURES << filename
end
```

Although global variables are usually considered evil, in this case it's the only kind of tracking that makes sense—required files create constants in the global namespace, and so the list of required files should be global, too. In fact, Ruby does provide a global variable named `$LOADED_FEATURES`, and it holds a list of every file that has been required, just like our example!

The second problem that you might have noticed by now is that the argument to `require` has to be an absolute path on the filesystem. That's probably okay if you know exactly where every file on your machine is, but that won't work between lots and lots of different developers. The easiest way to allow requires that aren't absolute is to just treat every filename as if it's relative to the directory the program was started from. That's easy, but doesn't work well if you want to combine Ruby files from a bunch of different directories.

To allow required files to be in different directories, we could create a list of directories to look inside whenever require is called. Here's what an implementation of load paths might look like:

```ruby
$LOAD_PATH = ["/path/to/code", "/other/path/to/code"]

def require(filename)
  full_path = $LOAD_PATH.find do |path|
    File.exist?(File.join(path, filename))
  end
  eval File.read(full_path)
end
```

You may then wonder if these two things can be combined. They can! Here's a version of the function that only loads files once, and looks in all `$LOAD_PATH` directories.

```ruby
$LOAD_PATH = ["/path/to/code", "/other/path/to/code"]
$LOADED_FEATURES = []

def require(filename)
  full_path = $LOAD_PATH.find do |path|
    File.exist?(File.join(path, filename))
  end
  return true if $LOADED_FEATURES.include?(full_path)
  eval File.read(full_path)
  $LOADED_FEATURES << full_path
end
```

Anyway, adding a load path allows us to find Ruby libraries even if they are spread across multiple directories. At this point, we can add the directory that holds the Ruby standard library to that list, and it becomes very easy to require those files. Loading `net/http`? No problem, now you can just `require 'net/http'`, and Ruby wil automatically check the directory where it lives.

At this point, we've already caught up to the state of the art in Ruby libraries circa 2004. The final piece of the puzzle for developers who wanted to share Ruby code in 2004 was the combination of `setup.rb` and the RAA, or Ruby Application Archive. While the RAA is no longer around (it was shut down 2014 due to lack of use), `setup.rb` is amazingly [still around on the internet](http://i.loveruby.net/en/projects/setup/), and you can even download it if you like. Just to warn you, though, it hasn't been updated since 2005.

At its core, `setup.rb` is a Ruby implementation of the classic unix trinity of commands to install software: `./configure && make && make install`. When using `setup.rb`, the commands to run are `ruby setup.rb config && ruby setup.rb setup && ruby setup.rb install`. Installing a Ruby library was then as simple as:

  1. Browse the RAA looking for a library that did what you wanted.
  2. Find a library, click a link to download the .tar.gz file containing the library.
  3. Decompress the tarball, `cd` into the directory, and run `ruby setup.rb`.

At that point, you would have installed the library! Because `setup.rb` installed the Ruby files into a single, well-known directory that was already added to the load path, you could even require the library immediately. Libraries could be found, downloaded, installed, and used. It was pretty good.

It doesn't take too long to figure out that there are some possible problems with this plan, though. For example, if a library is updated, and you want the new version, how do you get it? Well, you had to browse back to the RAA, find the new version, download it, decompress the tarball, and then manually run `ruby setup.rb` again. Then you'd have the new version.

Does this sound tedious to you? Speaking as someone who was there, let me tell you: it was tedious. It took a lot of time, it was error prone, there was no good way to know when new versions came out. In a word, it was... not great. Even worse, what if you had one Ruby application that only worked with the old version of tha library? You just overwrote the old version with the new one, and your script that needs the old version doesn't work anymore. Oops.

In 2004, RubyGems came racing to the rescue, fixing all of these problems. Installing libraries was a single command: `gem install`. Checking to see what gems were available was also a single command: `gem list`. Just that was enough to revolutionize sharing code in Ruby, but RubyGems had yet another trick up its sleeve: multiple gem versions.

Unhappy with the way that `setup.rb` only allowed one version of each library to be installed at a time, RubyGems allow multiple versions of a gem to be installed at the same time. RubyGems adds its own patches to the `require` method, checking to see if a gem is installed that provides the file `rack.rb`. If no version of that gem has been activated, RubyGems will automatically activate the newest version that is already installed.

It's even possible to load a specific version of a gem, rather than the newest version that has been installed using the `gem` method provided by RubyGems.

Here's how to load a specific version of a gem using the `gem` method, followed by `require`:

```ruby
gem "rack", "1.0"
require "rack"
```

Calling the `gem` method adds a specific version of that gem to the load path. At that point, a regular `require` is enough to load exactly that version of that gem.

If you running a command that's provided by a gem, like `rackup`, it's also possible to run that command using a specific version of the gem. RubyGems checks to see if the first argument is a version number surrounded by underscores, and uses that version if so. So to run `rackup` using rack version 1.2.2 on port 3000, you would run:

```
$ rackup _1.2.2_ -p 3000
```

RubyGems made installing, upgrading, and using libraries easy. So easy, in fact, that there was an explosion of libraries. Today, there are almost 100,000 gems, and almost 1 million released versions of every gem.

This explosion revealed a new problem with dependencies: it's hard to coordinate them. If one developer ran `gem install foo` and started using a new gem in the application, other developers on the project would have to be told to run `gem install foo`. Then each of the production servers would also have to run `gem install foo`.

Even worse, setting up a new machine might mean that `gem install foo` installed a different version than the one that the application knew how to use. Adding new developers to a team could be a week-long process as gems were installed, checked, and fixes were made.

Around  2008, developers started to create solutions for managing lists of gems. Rails started offering the `config.gem` setting, and the `gem_installer` gem offered another option for installing many gems at once.

Unfortunately, it didn't take long to discover problems with that system, either. Because RubyGems automatically used the newest version of each gem, simply having older versions of gems installed wasn't enough to mean that they would be used. Days, and even weeks of developer time was spent trying to figure out why projects would mysteriously work on one machine only to fail on another machine.

Anyone with more than one large Rails application quickly discovered exactly how hard it is to manage gems by hand: upgrade a gem in any application, and all the other applications on your machine stop working until you upgrade them, too. Upgrading gems in those apps spread the upgrade pain to all the other developers on those applications, and so on.

Ultimately, a large chunk of any Ruby developer's time was spent managing and upgrading gems, and it sucked. Just fixing that would be a big enough reason to create Bundler right there, but there was another, even more insidious, problem as well: gem activation errors.

Gem activation errors mean that, somehow, RubyGems was asked to activate a gem, and then later on asked to activate a different version of the same gem. Since it's not possible to have two versions of the same gem loaded at the same time, this raises an exception. At this point, you're probably thinking "Surely that wasn't very common, André! That sounds like a complicated and rare situation."

If only that were true. :( Almost every Ruby application with more than a handful of gems would eventually start to experience this problem. RubyGems loads the newest installed gem by default, and so when another dependency declared that it only worked with a version slightly older than the newest one, everything would explode.

The underlying reason for activation errors is simple: RubyGems does what we usually call "runtime dependency resolution". It loads the gems you ask for, when you ask for them, and doesn't know in advance if you're going to need a different version later. To prevent runtime dependency errors, we need to do dependency resolution _before_ runtime. We need to know every gem and every version, and know that they all work together, before we start to load any of them.

This is the ultimate problem that Bundler exists to solve: how do you figure out which versions of all the gems that you want can actually work together? Each gem depends on other gems, and those gems depend on other gems, and so on. Before Bundler, this process was done entirely by hand, and simply involved trying things until the exceptions stopped.

Unsurprisingly, computers are more accurate than humans at sytematically trying a mutitude of options and reporting back which options work. They're also much, much faster at it. Thanks to Bundler, Ruby developers have been able to simply list the gems they want to use and count on Bundler to find versions for all of them that actually work together.

This problem is called "dependency graph resolution", and it is an example of a Well-Known Hard Problem™, also known as NP-Complete problems. In theory, it is possible to construct a set of existing gems and a Gemfile such that it could take until past the heat death of the universe to find versions that all work together.

Since most developers don't have that long to spare, Bundler's resolver uses a lot of tricks, shortcuts, and heuristics to prioritize which gem versions to try first. We've built up a pretty large library of tricks over the years, and most Gemfiles now resolve within a few seconds.

After finding the versions that work together, Bundler records the exact versions of every gem into another file, named `Gemfile.lock`. This lock file is what makes it possible to install the exact same versions on to every machine that runs this application, whether that machine belongs to a developer, a production server, or a CI server.

At the end of the day, the way Bundler works boils down to two separate steps, `bundle install` and `bundle exec`. The steps for `bundle install` are pretty simple to explain:

1. Read the Gemfile (and lock, if it's there)
2. Ask RubyGems.org for a list of every version of every gem we want
2. If needed, find gem versions allowed by the Gemfile that work together
3. If found, write down those versions in the lock for future installs
4. Install gems as needed until every gem in the lock is installed

The process for `bundle exec` is similar, with two important changes. First, it is just setting up Ruby to load gems that are already installed, so it doesn't ask RubyGems.org for a list of gem versions. Second, it doesn't install gems if any are missing, it just prints out an error asking you to install the gems, instead. Here are the steps:

1. Read the Gemfile (and lock, if it's there)
2. If needed, find gem versions allowed by the Gemfile that work together
3. If found, write down those versions in the lock for future installs
4. Remove any existing gems from the `$LOAD_PATH` array
5. Add each gem version listed in the lock file to the `$LOAD_PATH`

That's it! While there are a lot of other details, those are the underlying pieces Bundler uses to let you get your work done: `require`, the `$LOAD_PATH` array, and RubyGems. Each one is built on top of the ones that came before, and each one fixes problems that only became apparent after the new system was created.

Even after Bundler was created, the pattern continues. The biggest problem left for users of Bundler 1.0 was how long it took to run `bundle install`. To fix that, Bundler 1.1 created a completely new way to get information about gems from RubyGems.org and it sped things up. We continue to work on Bundler today, and we released [Bundler 1.9](http://bundler.io/blog/2015/03/21/hello-bundler-19.html) just this month. We have big improvements in the pipeline as well, so keep an eye on the [Bundler website](http://bundler.io) or [@bundlerio](https://twitter.com/bundlerio) on Twitter for updates!

If you use Bundler, or if your company uses Bundler, support Bundler's development. For those of you with time but not money, we'd love your help on Bundler! You can tweet at us [@bundlerio](https://twitter.com/bundlerio) or email us at [team@bundler.io](mailto:team@bundler.io) and set you up with ways you can help. On the other hand, if you have money but not time, you can still make sure Bundler keeps getting better by joining [Ruby Together](https://rubytogether.org/) as a paying member.

Ruby Together membership fees go directly to support developers working on Bundler, RubyGems, and RubyGems.org. We're working to make sure that you can spend time on your own work, rather than solving dependency problems. As Ruby Together grows, we'll be tackling more community issues, including gem mirrors, better public benchmarks for Ruby and Rails, and more.
