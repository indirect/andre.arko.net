---
layout: post
title: "Nested layouts on Rails ~> 3.1"
microblog: false
guid: http://indirect-test.micro.blog/2013/02/02/nested-layouts-on-rails/
post_id: 4971399
date: 2013-02-01T16:00:00-0800
lastmod: 2013-02-01T16:00:00-0800
type: post
url: /2013/02/01/nested-layouts-on-rails/
---

### tl;dr

Put this in your ApplicationHelper:

```ruby
def inside_layout(parent_layout)
  view_flow.set :layout, capture { yield }
  render template: "layouts/#{parent_layout}"
end
```

Then create inner templates (mine are usually for a controller) that look like this:

```erb
<%= inside_layout "application" do %>
  <p>before template</p>
  <%= yield %>
  <p>after template</p>
<% end %>
```

Works in Haml, too.

### Yet another way to nest your layouts

Nested layouts is a topic that has been discussed to death, both in the [official Rails views guide](http://guides.rubyonrails.org/layouts_and_rendering.html) and appears to have confused [many](http://stackoverflow.com/questions/6539239/multiple-level-nested-layout-in-rails-3) [different](http://stackoverflow.com/questions/741945/nested-layouts-in-ruby-on-rails) [people](http://stackoverflow.com/questions/4208380/confused-on-advanced-rails-layout-nesting) on Stack Overflow.

The “nested layouts” from the Rails view guide have always baffled me. Ultimately, the idea that they claim is best practice boils down to setting up a bunch of custom `yield` calls in your application layout and then using the child layouts to call `content_for` a bunch of times before rendering the application layout.

This week, I got asked about setting up nested layouts by someone who tried to read the Rails guide and just got confused, so I went to see if there was a better way. I ran across [this blog post](http://m.onkey.org/nested-layouts-in-rails-3), and that led to a gist demonstrating [layout nesting via partials](https://gist.github.com/740835). While those options did actually work, I didn’t like the semi-magic call to `parent_template` at the end of the first option, and I didn’t like the requirement of a partial in the second.

After beating my head against nested yield calls for a while, I managed to come up with a two-line helper method that takes a block with the “inner” layout inside it. I’m pretty happy with how it came out.

The `inside_layout` method just takes the name of the parent layout and a block with the inner layout contents. The inner layout must call `yield`, as usual, where the action template should be inserted. Since you read past the tl;dr, I’ll even explain what’s going on for you! :D

```ruby
  def inside_layout(parent_layout)
    view_flow.set :layout, capture { yield }
    render template: "layouts/#{parent_layout}"
  end
```

I didn’t know this before, but Rails 3.1+ views (and helpers) all have [a `view_flow` object](https://github.com/rails/rails/blob/master/actionpack/lib/action_view/flows.rb#L4) available to them that manages all of the various `content_for` sections. Using that object, we swap out what will be inserted when the next template rendered calls `yield`. What we put in instead is the result of calling `capture` with the block that was passed to our helper. That method returns a string with the result of rendering the block. Finally, we simply render the parent layout, knowing that when it calls `yield`, it will get the result of rendering our entire inner layout’s block. Pretty sweet.
