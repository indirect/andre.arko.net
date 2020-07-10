---
title: "Rails 6 with Webpack in app/assets (and no Sprockets)"
layout: post
---
The first version of Rails with Sprockets to manage JS and CSS assets shipped in May 2011. Generating a new Rails app today includes not only Sprockets, but an entire second JS and CSS asset pipeline that uses Webpack. It... sort of... makes sense to do this, for legacy reasons, but it's confusing.

Putting CSS into `app/javascript/css` doesn't really make sense. Wouldn't it make more sense to put CSS into `app/assets/css`? It would make a lot more sense, but Webpack is stuck in `app/javascript` is because Sprockets already owns `app/assets`.

Despite that, I have good news! It is possible to use `app/assets` for the JS, CSS, images, fonts, and other... assets... that are managed by Webpack. All you have to do is completely rip out Sprockets (giving up all gem-based JS and CSS) and then strategically reconfigure Webpack. Shall we get started?

If you're starting a new Rails 6 app, you can use `rails new --no-sprockets` to avoid most of Sprockets. If you have an existing app, you're going to have to yank it out by hand.

### Remove Sprockets

(Skip this step if you generated a new Rails app with the `--no-sprockets` option.)

1. `bundle remove sass-rails`
2. `rm config/initalizers/assets.rb`
3. Replace `require 'rails/all'` in `config/application.rb` with these lines instead:

    ```ruby
    require "rails"
    # Pick the frameworks you want:
    require "active_model/railtie"
    require "active_job/railtie"
    require "active_record/railtie"
    require "active_storage/engine"
    require "action_controller/railtie"
    require "action_mailer/railtie"
    require "action_mailbox/engine"
    require "action_text/engine"
    require "action_view/railtie"
    require "action_cable/engine"
    # require "sprockets/railtie"
    require "rails/test_unit/railtie"
    ```

4. Remove these lines from `config/application/development.rb`

    ```ruby
    # Debug mode disables concatenation and preprocessing of assets.
    # This option may cause significant delays in view rendering with a large
    # number of complex assets.
    config.assets.debug = true

    # Suppress logger output for asset requests.
    config.assets.quiet = true
    ```

5. Remove these lines from `config/application/production.rb`

    ```ruby
    # Compress CSS using a preprocessor.
    # config.assets.css_compressor = :sass

    # Do not fallback to assets pipeline if a precompiled asset is missed.
    config.assets.compile = false
    ```

Once you have Sprockets completely removed, make sure you [have Webpacker installed](https://github.com/rails/webpacker#installation). If you generated a fresh Rails 6 app, you already have it.

### Move Webpack to app/assets/

Now that you've gotten rid of Sprockets, you can configure the Webpacker gem to tell Webpack to use the `app/assets` directory to store your Webpack-organized CSS and JS.

For some reason, Rails 6 still generates a Sprockets-style `app/assets` directory, even if you explicitly disable Sprockets, so we'll have to remove that first.

```bash
rm -rf app/assets
```

Then, move the existing Webpack assets directory over there instead.

```bash
mv app/javascript app/assets
```

Create an application stylesheet in `packs`.

```bash
touch app/assets/packs/application.scss
```

(If you generate controllers, Rails will create stylesheets like `app/assets/stylesheets/controller.css`, and you can import those files with lines like `@import "../stylesheets/controller.css` in the pack.)

Update `app/views/layouts/application.html.erb` to use the pack instead of the now-gone Sprockets stylesheet.

```bash
sed -i '' s/stylesheet_link_tag/stylesheet_pack_tag/ app/views/layouts/application.html.erb
```

Finally, update the Webpacker gem config so that both Rails and Webpack will know where to look for your assets. 

In `config/webpacker.yml`, change `source_path: app/javascript` to `source_path: app/assets`.

That's it! Welcome to the confusing and somewhat terrifying world of modern frontend dependencies. You can't use any Javascript provided via RubyGems anymore, but you can use any Javascript or CSS provided by npm packages. Just run `yarn add package-name`, and import the package in your `application.js` or `application.scss`. Enjoy it.
