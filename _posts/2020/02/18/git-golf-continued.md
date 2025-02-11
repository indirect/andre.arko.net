---
layout: post
title: "git golf continued"
microblog: false
guid: http://indirect-test.micro.blog/2020/02/19/git-golf-continued/
post_id: 4971635
date: 2020-02-18T16:00:00-0800
lastmod: 2020-02-18T16:00:00-0800
type: post
url: /2020/02/18/git-golf-continued/
---
In the ongoing quest to type even less while using git on a day to day basis, I noticed that I sometimes need to switch back and forth between branches with similar names. To pick a completely hypothetical example, let’s call those branches `update-ruby` and `update-rails`.

When all my branches have nice, unique names I can switch between them by typing `git co X<tab>`, where X is the first letter of the branch name. In this case, though, I have to type `git co u<tab><tab>`, then read the list of autocomplete options to figure out what the next letter I need to type is, and then type `u<tab>` to complete the branch I actually want.

Wouldn’t it be easier to check out the branch by any unique string contained within its name, without having to tab-complete? Yes, it would.

Leveraging the magic of [fzf](https://github.com/junegunn/fzf), I have updated my [previously mentioned `gb` alias](/2019/01/20/git-in-as-fw-chrs-as-psbl/) to be even more powerful:

```bash
function gb {
  if [[ -z "$1" ]]; then
    git branch -v
  else
    git branch | grep -v "^*" | fzf -f "$1" | head -n1 | xargs git checkout
  fi
}
```

Now, see a list of local branches with `gb`, and then choose a branch with `gb foo`, where `foo` is any string that allows fzf to tell which branch you mean. That could be a unique string, but it could even be a unique set of characters that appear in the same order in the target branch name. fzf is great.

Now my daily branch workflow is more like `gb`, `gb ruby`, do some work, `gi`, `gp`, `gb rails`, do some other work, `gi`. As long as we measure only in terms of buttons pushed to use git, life continues to improve!
