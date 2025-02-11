---
layout: post
title: "Jekyll postfiles plugin"
microblog: false
guid: http://indirect-test.micro.blog/2010/09/06/jekyll-postfiles-plugin/
post_id: 4971345
date: 2010-09-05T16:00:00-0800
lastmod: 2010-09-05T16:00:00-0800
type: post
url: /2010/09/05/jekyll-postfiles-plugin/
---
Through the years, I've used a lot of blogging engines. Nowadays, I use [Jekyll](http://jekyllrb.com/) to generate a static version of my blog. Jekyll has had one annoying shortcoming for me, though -- it doesn't support including files in a blog post. This has bitten me more than once, especially as I move between blogging engines (or just try to clean up random files on my web server).

About a year ago, I decided to try to fix that. So, I forked Jekyll and patched it to allow files associated with posts in a `_postfiles` directory. That worked for a while (although I had to install my fork onto my server, which was a little bit annoying). This week, I realized that my RSS feed had broken images because I was using relative paths to reference postfiles. To solve that, I decided to write a `&#123;&#123; '{% postfile foo ' }}%}` liquid tag that expanded file references out to absolute paths.

While working on the liquid tag, I discovered that Jekyll 0.7 supports plugins, and that I could stop forking Jekyll and just write a plugin instead. So I did. Presenting [jekyll-postfiles](http://github.com/indirect/jekyll-postfiles), a plugin for Jekyll that (optionally) adds files to each post. Just create a folder named `_postfiles`, next to the folder named `_posts`. When you have a file that you want to include in a post, create a folder with the same name as the post, and put the file in there, with a directory structure like this:

    _posts/
      2010-09-06-jekyll-postfiles-plugin.md
    _postfiles/
      2010-09-06-jekyll-postfiles-plugin/
        file.zip

Reference the file inside the post using the liquid tag, like `&#123;&#123; '{% postfile file.zip ' }}%}`, and you're all set.

### tl;dr

I wrote a Jekyll plugin to let you include files with your posts! You can get it on github at [indirect/jekyll-postfiles](http://github.com/indirect/jekyll-postfiles)
