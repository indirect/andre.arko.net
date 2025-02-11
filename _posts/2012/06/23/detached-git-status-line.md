---
layout: post
title: "Detached git status line"
microblog: false
guid: http://indirect-test.micro.blog/2012/06/24/detached-git-status-line/
post_id: 4971393
date: 2012-06-24T00:00:00-0800
lastmod: 2012-06-23T16:00:00-0800
type: post
url: /2012/06/23/detached-git-status-line/
---
It's been [a really long time](/2007/12/19/git-branch-in-prompt-with-svn-support/) since I posted about a prompt with git status support built in. I don't care so much about svn these days, but something that has bothered me for quite a while about the default git status line is that it's pretty useless if you aren't at the tip of a branch. The default `__git_ps1` function simply returns the sha of the current commit. It's really unhelpful to simply see `(abc1234...)`, especially when you're doing a git bisect or something like that.

Instead of just using `__git_ps1`, you can spruce up your git prompt to tell you exactly where you are! Git knows that commit `abc1234` is actually `master~2` or `feature_branch~25`. Wouldn't it be more helpful to see that?

After some agonizing, I've managed to glue together a couple of git commands that actually provide that extremely useful information. There was a minor bug that put "master" in the prompt if you had just created a new branch, but I got that fixed too.

Implemented in glorious, horrifying bash script, here is the somewhat more informative git prompt:

```bash
function parse_git_dirty {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit (working directory clean)" ]] && echo "⚡"
}

function parse_git_branch {
  local b="$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/^* //')"
  if [ -n "$b" ] && [ "$b" = "(no branch)" ]; then
    local b="$(git name-rev --name-only HEAD 2> /dev/null)"
  fi

  if [ -n "$b" ]; then
    printf "($b$(parse_git_dirty))"
  fi
}

export PS1='\[\033k\033\\\]\[\e[0;34m\][\u \w]$(parse_git_branch)\$\[\e[0;39m\] '
```

I've also [posted this as a gist](https://gist.github.com/631628) with some examples if you'd like to comment or fork my code.
