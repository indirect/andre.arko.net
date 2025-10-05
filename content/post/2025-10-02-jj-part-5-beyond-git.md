+++
title = '<code>jj</code> part 5: beyond git'
slug = 'jj-part-5-beyond-git'
date = 2025-10-02T10:52:56+09:00
draft = true
+++

### commands

Now let’s talk about jj-only commands. This section is about the jj commands that took me weeks or months to realize existed, and to understand how powerful they are.

#### jj absorb

First up: `jj absorb`. Let's take a look at what the docs say about it to start.

> Move changes from a revision into the stack of mutable revisions
> 
> This command splits changes in the source revision and moves each change to the closest mutable ancestor where the corresponding lines were modified last. If the destination
> revision cannot be determined unambiguously, the change will be left in the source revision.
> 
> The source revision will be abandoned if all changes are absorbed into the destination revisions, and if the source revision has no description.
> 
> The modification made by `jj absorb` can be reviewed by `jj op show -p`.

When I first read about absorb, I thought it was the exact inverse of squash, allowing you to choose a diff that you would bring into the current commit rather than eject out of the current commit. That is wildly wrong, and so I want to make sure that no one else falls victim to this misconception. The absorb command iterates over every diff in the current commit, finds the previous commit that changed those lines, and squashes just that section of the diff back to that commit. So if you make changes in four places, impacting four previous commits, you can `jj absorb` to squash all four sections back into all four commits with no further input whatsoever.

#### jj parallelize

Then, `jj parallelize`. If you’re taking advantage of jj’s amazing ability to not need branches, and just making commits and squashing bits around as needed until you have each diff combined into one change per thing you need to submit… you can break out the entire chain of separate changes into one commit on top of trunk for each one by just running `jj parallelize 'trunk()..@'` and letting jj do all the work for you.

#### jj fix

Last command, and most recent one: `jj fix`. You can use fix to run a linter or formatter on every commit in your history before you push, making sure both that you won’t have any failures and that you won’t have any conflicts if you try to reorder any of the commits later.

To configure the fix command, add a tool and a glob in your config file, like this:

```Toml
[fix.tools.black]
command = ["/usr/bin/black", "-", "--stdin-filename=$path"]
patterns = ["glob:'**/*.py'"]
```

Now you can just `jj fix` and know that all of your commits are possible to reorder without causing linter fix conflicts. It’s great.

