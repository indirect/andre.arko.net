---
date: "2013-05-10T00:00:00Z"
title: Hack your bundle for fun and profit
---

Bundler has turned out to be an amazingly useful tool for installing and tracking gems a Ruby project needs. So useful, in fact, that nearly every Ruby project uses it. Even though it shows up practically everywhere, most people don’t know about Bundler’s built-in tools and helpers. In an attempt to increase awareness (and Ruby developer productivity), I’m going to tell you about them.

### Install, update, and outdated

You probably already know this, but I’m going to summarize for the people who are just getting started and don’t know yet. Run `bundle install` to install the bundle that’s requested by your project. If you’ve just run `git pull` and there are new gems? `bundle install`. If you’ve just added new gems or changed gem versions in the Gemfile? `bundle install`. It might seem like you want to `bundle update`, but that won’t just install gems — it will try to upgrade every single gem in your bundle. That’s usually a disaster unless you really meant to do it.

The update command is for when gems you use has been updated, and you want your bundle to have the newest version that your Gemfile will allow. Run `bundle outdated` to print a list of gems that could be upgraded. If you want to upgrade a specific gem, run `bundle update GEM`, or run `bundle update` to update everything. After the update finishes, make sure all your tests pass before you commit your new Gemfile.lock!

### Show and open

Most people know about `bundle show`, which prints the full path to the location where a gem is installed (probably because it’s called out in the success message after installing!). Far more useful, however, is the `bundle open` command, which will open the gem itself directly into your EDITOR. Here’s a minimalist demo:

```
$ bundle install
Fetching gem metadata from https://rubygems.org/..........
Resolving dependencies...
Installing rack (1.5.2)
Using bundler (1.3.1)
Your bundle is complete! Use `bundle show [gemname]` to see where a bundled gem is installed.
$ echo $EDITOR
mate -w
$ bundle open rack
```

That’s all you need to get the installed copy of rack open in your editor. Being able to edit gems without having to look for them can be an amazing debugging tool. It makes it possible to insert print or debugger statements in a few seconds. If you do change your gems, though, be sure to reset them afterwards! There will be a pristine command soon, but for now, just run `bundle exec gem pristine` to restore the gems that you edited.

### Searching

The show command still has one more trick up it’s sleeve, though: `bundle show --paths`. Printing a list of paths may not sound terribly useful, but it makes it trivial to search through the source of every gem in your bundle. Want to know where ActionDispatch::RemoteIp is defined? It’s a one-liner:

    $ grep ActionDispatch::RemoteIp `bundle show --paths`

Whether you use `grep`, `ack`, or `ag`, it’s very easy to set up a shell function that allows you to search the current bundle in just a few characters. Here’s mine:

    function back () {
      ack "$@" `bundle show --paths`
    }

With that function, searching becomes even easier:

    $ back ActionDispatch::RemoteIp

### Binstubs

One of the most annoying things about using Bundler is the way that you (probably) have to run `bundle exec whatever` anytime you want to run a command. One of the easiest ways around that is installing Bundler binstubs. By running `bundle binstubs GEM`, you can generate stubs in the `bin/` directory. Those stubs will load your bundle, and the correct version of the gem, before running the command. Here's an example of setting up a binstub for rspec.

```
$ bundle binstubs rspec-core
$ bin/rspec spec
No examples found.
Finished in 0.00006 seconds
0 examples, 0 failures
```

Use binstubs for commands that you run often, or for commands that you might want to run from (say) a cronjob. Since the binstubs don't have to load as much code, they even run faster. Rails 4 adopts binstubs as an official convention, and ships with `bin/rails` and `bin/rake`, both set up to always run for that specific application.

### Creating a Gemfile

I've seen some complaints recently that it's too much work to type `source 'https://rubygems.org'` when creating a new Gemfile. Happily, Bundler will do that for you! When you're starting a new project, you can create a new Gemfile with Rubygems.org as the source by running a single command:

    $ bundle init

At that point, you're ready to add gems and install away!

### Git local gems

A lot of people ask how they can use Bundler to modify and commit to a gem in their Gemfile. Thanks to work lead by José Valim, Bundler 1.2 allows this, in a pretty elegant way. With one setting, you can load your own git clone in development, but deploying to production will simply check out the last commit you used.

Here's how to set up a git local copy of rack:

    $ echo "gem 'rack', :github => 'rack/rack', :branch => 'master'" >> Gemfile
    $ bundle config local.rack ~/sw/gems/rack
    $ bundle show rack
    /Users/andre/sw/gems/rack

Now that it's set up, you can edit the code your application will use, but still commit in that repository as often as you like. Pretty sweet.

### Ruby versions

Another feature of Bundler 1.2 is ruby version requirements. If you know that your application only works with one version of ruby, you can require that version.  Just add one line to your Gemfile specifying the version number as a string.

```ruby
ruby '1.9.3'
```

Now Bundler will raise an exception if you try to run your application on a different version of ruby. Never worry about accidentally using the wrong version while developing again!

### Dependency graph

Bundler uses your Gemfile to create what is technically called a "dependency graph", where there are many gems that have various dependencies on eachother. It can be pretty cool to see that dependency graph drawn as a literal graph, and that's what the `bundle viz` command does. You need to install GraphViz and the ruby-graphviz gem.

```
$ brew install graphviz
$ gem install ruby-graphviz
$ bundle viz
```

Once you've done that, though, you get a pretty picture that's a lot of fun to look at. Here's the graph for a Gemfile that just contains the Rails gem.

<img src="bundle.png">

### IRB in your bundle

I have one final handy tip before the big finale: the console command. Running `bundle console` will open an IRB prompt for you, but it will also load your entire bundle and all the gems in it beforehand. If you want to try expirimenting with the gems you use, but don't have the Rails gem to give you a Rails console, this is a great alternative.

    $ bundle console
    >> Rack::Server.new
    => #<Rack::Server:0x007fb439037970 @options=nil>

### Creating a new gem

Finally, what I think is the biggest and most useful feature of Bundler after installing things. Since Bundler exists to manage gems, the Bundler team is very motivated to make it easy to create and manage gems. It's really, really easy. You can create a directory with the skeleton of a new gem just by running `bundle gem NAME`. You'll get a directory with a gemspec, readme, and lib file to drop your code into. Once you've added your code, you can install the gem on your own system to try it out just by running `rake install`. Once you're happy with the gem and want to share it with others, pushing a new version of your gem to rubygems.org is as easy as `rake release`. As a side benefit, gems created this way can also easily be used as git gems. That means you (and anyone else using your gem) can fork, edit, and bundle any commit they want to.

###  Step 3: Profit

Now that you know all of the handy stuff Bundler will do for you, I suggest trying it out! Search your bundle, create a gem, edit it with git locals, and release it to rubygems.org. As far as I'm concerned, the absolute best thing about Bundler is that it makes it easier for everyone to share useful code, and collaborate to make Ruby better for everyone.

<p class="aside">This post was also given as a lightinng talk at <a href="http://2013.la-conf.org/#eclair">La Conf</a>, and the slides for that talk are <a href="https://speakerdeck.com/indirect/hack-your-bundle-for-fun-and-profit-la-conf-2013">posted to SpeakerDeck</a>.</p>

<p class="aside">This post was originally written for, and posted to, the <a href="http://www.engineyard.com/blog/2010/homebrew-os-xs-missing-package-manager/">Engine Yard Blog</a>.</p>
