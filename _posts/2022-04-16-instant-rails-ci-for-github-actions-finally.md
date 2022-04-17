---
title: "Instant Rails CI for GitHub Actions (finally)"
layout: post
---

A couple of months ago, I [built a webapp from scratch using Rails 7](/2022/02/17/feedyouremail/). In addition to leaving Node out of my Rails app, I wanted to use GitHub Actions as the only CI for a real webapp that other people use.

GitHub Actions was [first introduced in 2018](https://techcrunch.com/2018/10/16/github-launches-actions-its-workflow-automation-tool/), and [one-click CI for GitHub Actions](https://github.blog/2021-12-17-getting-started-with-github-actions-just-got-easier/) was introduced in 2021. Because that is literally years in the past, I assumed that it would be straightforward to set up a Rails app to automatically run tests inside GHA. Nothing could have been further from the truth.

I started where you might expect, going to `/actions/new` inside my repo and searching the GitHub-provided starter actions for “Rails”. Somehow, even though Django and Laravel apps had one-click CI, the Rails starter workflow… runs Rubocop. And Brakeman. And no tests. I guess linting is better than nothing, but that is extremely not CI, and definitely does not help me know if it’s safe to deploy my app automatically.

Annoyed, I went to search for a public GitHub Action file that I could copy and paste into my project. Somehow, all the blog posts I could find were about the beta version of GitHub Actions, and none of the YAML files actually worked. On top of that, every single blog post told me I would need to make changes to my app’s code so that my tests would run. I know enough about Rails to know that is absolutely not true, but apparently no one who knew that ever wrote about it somewhere easily findable with a search engine.

At that point I was annoyed all the way into action: I frankenstiened together three different blog posts and then started deleting everything that seemed unneeded or would require changes to my code. By the time I was done, I had a [pretty concise YAML file](https://github.com/actions/starter-workflows/blob/main/ci/rubyonrails.yml) that 1) worked with any Rails app out of the box, 2) supported both minitest and rspec without any changes, and 3) ran security checks and lints in a second parallel job, so everything finished faster.

Once I had a working action, my first thought was to simply post it here… but then I realized I could fix the one-click workflow offered by GitHub itself to actually run tests instead of just linters! So I went and [spent four days getting my pull request accepted](https://github.com/actions/starter-workflows/pull/1353), and now there’s a gloriously straightforward two-click way to test your Rails application with GitHub Actions. Phew.

<img src="{% postfile starter_workflow.jpg %}">
