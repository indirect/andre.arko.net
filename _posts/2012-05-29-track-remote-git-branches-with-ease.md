---
title: Track remote git branches with ease
layout: post
---
## tl;dr

    # ~/.gitconfig
    [aliases]
      track = "!f(){ branch=$(git name-rev --name-only HEAD); cmd=\"git branch --set-upstream $branch ${1:-origin}/${2:-$branch}\"; echo $cmd; $cmd; }; f"

## The problem

Git is really great. That said, I find myself frequently annoyed by trying to manage upstream tracking branches. If you're creating a new branch for the first time, it's incredibly easy because git does the work for you.

If you already have a branch, though, and you're trying to change the upstream branch, it’s incredibly annoying. I expect to be able to use the same arguments that I use with `git pull`. That means I invoke `git branch --set-upstream` with invalid arguments, get an error message, start to read the `git branch` manpage, give up, and then edit `.git/config` directly to fix my problem.

I kept thinking that there must is a better way. At some point in the past, I wrote a git alias named “track” that attempted to make it easier. The problem with my initial attempt was that I still had to remember the exact syntax, and pass the local and remote branch names in a form like `master origin/master`. That was pretty much impossible for me to remember on the fly, and so things weren’t really any easier.

### The solution 

This week, I needed to change tracking branches again, and I decided that I would just keep going until I had something that I wanted. Worst case, I could always write a ruby script, right? Happily, things turned out to be much simpler than that. I discovered that you can define shell functions inside git aliases, and then figured out that bash provides a special syntax for “variable or constant value”. Combine those two together, and bam, awesome `git track`.

The best part of this particular alias is that all the arguments are optional. You can invoke it with the remote and branch, just the remote, or neither one. Here are some examples:

```
# make the current branch track origin/master
git track

# make the current branch track indirect/master
git track indirect

# make the current branch track indirect/feature
git track indirect feautre
```

You too can use this particular git alias. Just copy this line into your `.gitconfig` file, in the `[aliases]` section:

```
track = "!f(){ branch=$(git name-rev --name-only HEAD); cmd=\"git branch --set-upstream $branch ${1:-origin}/${2:-$branch}\"; echo $cmd; $cmd; }; f"
```

Enjoy!