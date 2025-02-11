---
layout: post
title: "Changing git and GitHub's default branch name"
microblog: false
guid: http://indirect-test.micro.blog/2020/06/06/changing-git-and-githubs-default/
post_id: 4971966
date: 2020-06-05T16:00:00-0800
lastmod: 2020-06-05T16:00:00-0800
type: post
url: /2020/06/05/changing-git-and-githubs-default/
---

First off: [Black lives matter](https://blacklivesmatter.com). Go support Black activism in your community right now. I'll wait. If you're in the bay area, try [People's Breakfast Oakland](https://www.instagram.com/peoplesbreakfastoakland/), the [Transgender Gender-Variant & Intersex Justice Project](http://www.tgijp.org), the [Bay area anti-repression committee](https://antirepressionbayarea.com), and the [National Lawyer's Guild SF](https://nlgsf.org).

Okay, now that you're back, let's talk about a tiny way you can avoid referencing the incredibly fucked up history of racist oppression in the US while writing software: stop naming branches `master`. It's surprisingly hard, since neither git nor GitHub let you set a default for all new repos. These are some scripts I have cobbled together to work around that for my preferred primary branch name `main`.

To work around the way `master` is literally hardcoded into `git`, you'll need to replace `git init`. Git doesn't let you override subcommands with aliases, so this has to be a shell function. That said, this function should work just fine in either bash or zsh.

```bash
function git() {
  command git "$@"
  if [[ "$1" == "init" && "$@" != *"--help"* ]]; then
    git symbolic-ref HEAD refs/heads/main
  fi
}
```

The somewhat trickier part is changing the GitHub default branch, which you can't do by pushing branches. If (and only if) your very first push to the empty repo is on a different branch, that branch will become your default. Assuming you used the modified `git init` listed above, you can create a repo with `hub create`, and push directly using `git push`. ([The `hub` command](https://github.com/github/hub) is a very useful CLI tool for interacting with GitHub.)

If you've already pushed, or used the web UI, however, the default branch has automatically been set. The only official way to change a default branch is using the website, going to Settings, and clicking a bunch. I don't want to do that over and over, so I also created a wrapper for `hub` that adds a subcommand to change the default branch on GitHub for the repo in the current directory. This function should also work with either bash or zsh.

```bash
function hub() {
  if [[ "$1" == "default-branch" && "$@" != *"--help"* ]]; then
    local BRANCH="${2:-main}"
    git checkout -b "$BRANCH" 2>/dev/null || git checkout "$BRANCH"
    git push origin "$BRANCH:$BRANCH" 1>/dev/null
    hub api repos/{owner}/{repo} -X PATCH -F default_branch="$BRANCH" 1> /dev/null
    git branch -D master 2>/dev/null
    git push origin :master 2>/dev/null
  else
    command hub "$@"
  fi
}
```

To use it, run `hub default-branch [NAME]` in a checkout of the repo you want to change. If you pass an argument, that will be used as the branch name. Otherwise, the branch name `main` will be used.

Now that your git repos are slightly less bad, why not spend some time looking for actions you can take to oppose racism today?
