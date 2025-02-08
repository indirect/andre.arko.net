---
date: "2010-10-15T00:00:00Z"
title: Extending Rails 3 with Railties
---

Rails 3.0 is finally released, and with it comes a fantastic new way to extend Rails: Railties. Railties are the basis of the core components of Rails 3, and are the result of months of careful refactoring by Carlhuda. It is easier to extend and expand Rails than it has ever been before, without an `alias_method_chain` in sight.

Unfortunately, while the system for extending and expanding Rails has been completely overhauled, the documentation hasn't been updated yet. The [Rails Plugins Guide][plugins] only covers writing plugins in the old Rails 2 style. Ilya Grigorik wrote a [Railtie & Creating Plugins][ilya] blog post, but just scratched the surface of what is possible with a Railtie plugin. This post covers writing Railtie plugins, hooking into the Rails initialization process, packaging Railtie plugins as gems, and using gem plugins in a Rails 3 application.

[plugins]: http://guides.rubyonrails.org/plugins.html
[ilya]: http://www.igvita.com/2010/08/04/rails-3-internals-railtie-creating-plugins/


## Creating Railtie plugins

Creating a Railtie is easy. Just create a class that inherits from [`::Rails::Railtie`][railtie]. Every subclass of Railtie is used to initialize your Rails application. Since ActionController, ActionView, and the other Rails components are also Railties, your plugin can function as a first-class member of the Rails application. It will have access to the same methods and context that are used by the official Rails components. Here is a sample minimal Railtie that will be loaded when your Rails application boots.

{{< highlight ruby >}}
require 'rails'
class MyCoolRailtie < Rails::Railtie
  # railtie code goes here
end
{{< / highlight >}}

The [Railtie documentation][railtie] lists all of the methods that are available inside each Railtie class, but doesn't really go into depth about what you can use Railties to do. Here are some example Railties explaining how to use the Railtie methods (in alphabetical order) to customize and extend Rails.

[railtie]: http://api.rubyonrails.org/classes/Rails/Railtie.html

### `console`

The `console` method allows your Railtie to add code that will be run when a Rails console is started.

{{< highlight ruby >}}
console do
  Foo.console_mode!
end
{{< / highlight >}}

### `generators`

Rails will require any generators defined in `lib/generators/*.rb` automatically. If you ship [Rails::Generators][generators] with your Railtie in some other directory, you can require them using this method.

{{< highlight ruby >}}
generators do
  require 'path/to/generator'
end
{{< / highlight >}}

[generators]: http://api.rubyonrails.org/classes/Rails/Generators.html

### `rake_tasks`

If you ship rake tasks for apps with your Railtie, load them using this method.

{{< highlight ruby >}}
rake_tasks do
  require 'path/to/railtie.tasks'
end
{{< / highlight >}}

### `initializer`

The `initializer` method provides Railties with a lot of power. They create initializers that will be run during the Rails boot process, like the files put into `config/initializers` in the app directory. The `initializer` method takes two options, `:after` or `:before`, if there are specific initializers that you want to run before or after yours.

{{< highlight ruby >}}
initializer "my_cool_railtie.boot_foo" do
  Foo.boot(Bar)
end

initializer "my_cool_railtie.boot_bar",
  :before => "my_cool_railtie.boot_foo" do
    Bar.boot!
end
{{< / highlight >}}


## Rails configuration hooks

The biggest extension hook that Railties provide is somewhat unassuming: the `config` method. That method returns the instance of [`Railtie::Configuration`][config] that belongs to the application being booted. This opens up all sorts of interesting possibilities, since the `config` object is the same one that is made available inside a Rails application's `environment.rb` file. Here are some annotated examples of using `config` to change how a Rails application is initialized and configured.

[config]: http://api.rubyonrails.org/classes/Rails/Railtie/Configuration.html

### `after_initialize`

This method takes a block that will be run after Rails is is completely initialized, and all of the application's initializers have run.

### `app_middleware`

This method exposes the [MiddlewareStack][middleware] that will be used to handle requests to your Rails application. You can use any of the methods defined on MiddlewareStack, including `use` and `swap`, to manage the Rails application's Rack middlewares. For example, if your Railtie included the Rack middleware `MyRailtie::Middleware`, you could add it to the Rails application middleware stack like this.

{{< highlight ruby >}}
config.middlewares.use MyRailtie::Middleware
{{< / highlight >}}

[middleware]: http://api.rubyonrails.org/classes/ActionDispatch/MiddlewareStack.html

### `before_configuration`

Code passed in a block to this method will be run after immediately before the application configuration block inside `application.rb` is run. This is usually the best place to set default options that users of your plugin should be able to override themselves, as in the `jquery-rails` example below.

### `before_eager_load`

The block passed to `before_eager_load` will be run before Rails requires the application’s classes. Eager load is never run in development mode. However, if you need to run code after Rails loads but before any application code loads, this is the place to put it.

{{< highlight ruby >}}
config.before_eager_load do
  SomeClass.set_important_value = "RoboCop"
end
{{< / highlight >}}

### `before_initialize`

This method takes a block to be run before the Rails initialization process happens -- this is basically equivalent to creating an initializer, and setting it to run :before the first initializer the app has.

### `generators`

This object holds the configuration for the generators that are invoked when you run the `rails generate` command.

{{< highlight ruby >}}
config.generators do |g|
  g.orm             :datamapper, :migration => true
  g.template_engine :haml
  g.test_framework  :rspec
end
{{< / highlight >}}

You can also use it to disable colorized logging in the console.

{{< highlight ruby >}}
config.generators.colorize_logging = false
{{< / highlight >}}

### `to_prepare`

Last, but quite importantly, `to_prepare` allows you the chance to do one-time setup. The block you pass to this method will be run for every request in development mode, but only once in production. Use it when you need to set something up once before the app starts serving requests.


## Examples

At this point, you're probably thinking "why would I actually want to do any of that stuff?". So, here are a few select examples of Railtie plugins packaged as gems.

### [rspec-rails][rspec-rails]

The rspec-rails plugin ships with a set of rake tasks and generators that integrate the [RSpec][rspec] gem with Rails.

{{< highlight ruby >}}
module RSpec
  module Rails
    class Railtie < ::Rails::Railtie
      config.generators.integration_tool :rspec
      config.generators.test_framework   :rspec

      rake_tasks do
        load "rspec/rails/tasks/rspec.rake"
      end
    end
  end
end
{{< / highlight >}}

This Railtie just does three things: First, it sets the generators that will be used for integration tests via the `integration_tool` method. Next, it sets the generators that will be used to generate model, controller, and view tests (via the `test_framework` method). Last, it loads the RSpec rake tasks to run RSpec tests instead of test-unit tests.

[rspec-rails]: http://github.com/rspec/rspec-rails
[rspec]: http://github.com/rspec/rspec

### [jquery-rails][jquery]

The jquery-rails plugin ships with a generator that downloads and installs jQuery, the jquery-ujs script that enables Rails helpers with jQuery, and optionally installs jQueryUI as well.

{{< highlight ruby >}}
module Jquery
  module Rails
    class Railtie < ::Rails::Railtie
      config.before_configuration do
        if ::Rails.root.join(
          "public/javascripts/jquery-ui.min.js").exist?
          config.action_view.javascript_expansions[:defaults] =
            %w(jquery.min jquery-ui.min rails)
        else
          config.action_view.javascript_expansions[:defaults] =
            %w(jquery.min rails)
        end
      end
    end
  end
end
{{< / highlight >}}

This Railtie only sets one setting, but checks for the jQueryUI library to determine the value to set. By using the `config.before_configuration` hook, it runs right before the `application.rb` config block runs. That means it has access to the Rails.root, which is needed to check for jQueryUI, and it means that users can still override `javascript_expansion[:defaults]` in their `application.rb` if they want something different than the new defaults that the plugin provides.

[jquery]: http://github.com/indirect/jquery-rails

### [haml-rails][haml]

The haml-rails gem provides generators for views written in Haml instead of the default generated views that are written in ERB.

{{< highlight ruby >}}
module Haml
  module Rails
    class Railtie < ::Rails::Railtie
      config.generators.template_engine :haml

      config.before_initialize do
        Haml.init_rails(binding)
        Haml::Template.options[:format] = :html5
      end
    end
  end
end
{{< / highlight >}}

This Railtie simply changes the template engine that Rails invokes when you run `rails generate`, and then initializes Haml for Rails, and sets the Haml output format to HTML5.

[haml]: http://github.com/indirect/haml-rails


## Packaging up gem plugins

Railtie plugins are easy to turn into gem plugins for Rails. This makes them easy to distribute, manage, and upgrade. The first thing you need is a gem. If you don't have a gem yet, you can create a new gem easily using [Bundler][bundler]. Just run `bundle gem my_new_gem` and Bundler will generate a skeleton gem and gemspec that follow gem best practices. Once you have a gem, just make sure that your Railtie subclass is defined when `lib/my_new_gem.rb` is loaded. You can define the Railtie in a separate file and require that file, or define it directly. Last, add a dependency on the Rails gem (~>3.0) to your gemspec.

[bundler]: http://gembundler.com

If your gem is also a plain Ruby library, and you don't want to depend on the Rails gem, then you can put your Railtie in a separate file, and conditionally require that file inside your main library file.

{{< highlight ruby >}}
# lib/my_new_gem/my_cool_railtie.rb
module MyNewGem
  class MyCoolRailtie < ::Rails::Railtie
    # Railtie code here
  end
end
{{< / highlight >}}

{{< highlight ruby >}}
# lib/my_new_gem.rb
require 'lib/my_cool_railtie.rb' if defined?(Rails)
{{< / highlight >}}

This ensures that your gem can be loaded (without the Railtie) if it is loaded outside the context of a Rails application.

Now that your gem has a Railtie, you can build it and release it to [Gemcutter][gemcutter]. Once your gem is on Gemcutter, using it with Rails 3 applications is extremely easy -- just add the gem to your `Gemfile`. Bundler will download and install your gem when you run `bundle install`, Rails will load it, and the `Rails::Railtie` class takes care of the rest!

[gemcutter]: http://gemcutter.org

<p class="aside">This post was originally written for, and posted to, the <a href="http://www.engineyard.com/blog/2010/extending-rails-3-with-railties/">Engine Yard Blog</a>.</p>