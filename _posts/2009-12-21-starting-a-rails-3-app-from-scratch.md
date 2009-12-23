---
title: Starting a Rails 3 app from scratch
layout: post
---


There's not much in the way of documentation on using Rails 3 at the moment, so I thought I'd collect my notes from getting a new app up and running so other people could use them as well.

First thing you need is the bundler gem, to save you from gem dependency hell (hurrah):

  gem install bundler


### A new Rails app

Then you need an app. Assuming that your app is named "myapp" (which is a pretty bad assumption), here's what you might do:

    mkdir myapp
    cd myapp
    curl -O http://j.mp/Gemfile
    gem bundle

That creates a new directory for your app, pulls down a (sort of) minimal Gemfile, and then tells the bundler to bundle up Rails and all its dependencies for you to use in this app.

Then you'll want to use the copy of Rails that you just bundled to generate the default app structure, like so:

    ./bin/rails .

When it asks you if you want to overwrite the Gemfile, you know what to do: just say `n`, kids.

After you're done, I suggest running `./script/about` to make sure that all the bundling went well and Rails can load and all that good stuff. Assuming it works, you have yourself a new Rails 3 app! And without installing any system gems. How about that.


### Gems and generators and ooh shiny

At this point, you are pretty much set, and can run off and make your app do whatever it is that your heart desires. However, there are some more cool edgy things available, should you be interested. My current set of goodies includes Rack::Bug, Thor, RSpec, DataMapper, respond_to scaffolds. Most of these goodies were inspired (or just copied) from github.com/josevalim/third_rails.

  1. To get their gems installed, uncomment the lines in the Gemfile and the run `gem bundle` again to install them all.

  2. Export the generators into `lib/generators`:

      git clone git://github.com/indirect/rails3-generators.git lib/generators
      rm -rf lib/generators/.git

  3. To enable the generators, put these lines into your `config/application.rb`:

        config.generators do |g|
          g.scaffold_controller :responders_controller
          g.orm                 :datamapper
          g.template_engine     :erb, :layout => true
          g.test_framework      :rspec,
                                :fixtures => true,
                                :integration_tool => false,
                                :routes => true,
                                :views => false
          g.integration_tool    :rspec
        end

  4. Switching to RSpec is then pretty easy:

      ./script/generate rspec:install
      rm -rf test

  5. Thor needs a Thorfile, and can replace the Rakefile that Rails included with your app.

        curl -O http://j.mp/Thorfile
        rm Rakefile
        thor -T

  6. Rack::Bug is just a plugin, so it's pretty easy (although it may or may not be working with Rails 3 at the exact moment that you are reading this).

        script/plugin install git://github.com/josevalim/rack-bug.git

  Then, in `config/development.rb`, add this line:

        config.middleware.use "Rack::Bug"

### Git it done already

This is probably a good time to start tracking your app in source control:

    git init
    curl -O http://j.mp/gitignore
    git add .
    git commit -m "Fresh new Rails 3 app"


### TextMate with Rspec Bundle

Lastly, if you want to use RSpec from TextMate in the manner to which you have (likely) become accustomed, you will need to install a new version of RSpec.tmbundle that has support for libraries installed via the bundler.

    cd ~/Library/Application\ Support/TextMate/Bundles/
    git clone git://github.com/indirect/rspec-tmbundle.git RSpec.tmbundle
    osascript -e 'tell app "TextMate" to reload bundles'


### Phew.

If you've actually made it all the way here, I'm terribly impressed. If for some reason you want to follow along with these steps, you can check out my [blank Rails 3 app](http://github.com/indirect/rails3-app) repository at Github. Have fun with Rails 3!