+++
title = '<code>jj</code> part 2: commands & revsets'
slug = 'jj-part-2-commands'
date = 2025-10-02T10:52:56+09:00
+++

Previously on this blog: [`jj` part 1: what is it](/2025/09/28/jj-part-1-what-is-it/)

Now, let’s take a look at the most common jj commands, with a special focus on the way arguments are generally consistent and switches don’t hide totally different additional commands.

### jj log

The log command is the biggest consumer of revsets, which are passed using `-r` or `--revisions`. With `@`, which is the jj version of `HEAD`, you can build a revset for exactly the commits you want to see. The git operator `..` is supported, allowing you to log commits after A and up to B with `-r A..B`, but that’s just the start. Here’s a quick list of some useful revsets to give you the flavor:
- `@-` the parent of the current commit
- `kv+` the first child of the change named `kv`
- `..A & ..B` changes in the intersection of `A` and `B`’s ancestors
- `~description(glob:"wip:\*")` changes whose message does _not_ start with `wip:`, because tilde negates a revset
- `heads(::@ & mutable() & ~description(exact:"") & (~empty() | merges()))` the closest “pushable” change, meaning the nearest ancestor of `@` that is mutable (by default mutable means “not in the main/trunk branch”), that has some description set, and that either has some changes or is a merge commit. (Some jj merge commits can be empty, if there were no conflicts.)

Using the jj config file, you can give any revset an alias, and then use that alias. I use `closest_pushable(@)` quite a bit, especially when naming branches and pushing.

For a full review of everything that’s possible with revsets, check out [the revset documentation](https://jj-vcs.github.io/jj/latest/revsets/) and the blog post [Understanding Revsets for a Better JJ Log Output](https://willhbr.net/2024/08/18/understanding-revsets-for-a-better-jj-log-output/).

### jj commit / desc / new / edit / split

The functionality of `git commit` is broken up into four separate jj commands. You use `new` to create a new empty child change, defaulting to `@`, and edit it. The `desc` command lets you set the description (or message) on a given change. The `commit` command works like git, but is effectively the same as `jj desc && jj new`. You use `edit` to re-open an existing change for amending, and `split` to interactively select a diff to break out into a second change. These are all common git workflows, done by using flags or multiple git commands, made direct and straightforward single commands in jj.

### jj restore / abandon

What if using `checkout` and `reset` to roll back either files or full commits had clearer names?

If you want to get back a file from a previous change, you can use `restore`. Specify which change you want to bring back, and also provide a file name or glob to limit the restoration to specific files.

Where you might have previously used `git reset` or `git checkout` to manipulate which commits are included in the current branch, you can now use `abandon` to remove entire changes from your history. Without any arguments it will remove `@`, the working commit, which is similar to `git reset --hard`. With arguments, `abandon` will remove all changes in the given revset from the local history.

### jj bookmark list / set / track

Bookmarks are jj’s alternative to named git branches, and can be set up to automatically track a branch in a git remote. While compatibility with git branches is nice, names aren’t required by jj’s model. You can push your current unnamed change instantly with `jj git push --change @`, and jj will use the change ID (which stays the same across amends and rebases) as the git branch name. Now you don’t have to think of a good name for your branch before you can work on it (or push it!).

For more detail comparing and contrasting bookmarks to branches, I recommend the post [Understanding Jujutsu bookmarks](https://neugierig.org/software/blog/2025/08/jj-bookmarks.html).

### jj git push / fetch

It does what you would expect based on git, but the defaults are different than you might expect. Unless you configure the `git.fetch` and `git.push` settings, jj will only push to or fetch from `origin`. To operate on another remote, pass `--remote NAME`. To operate on all remotes, use `glob:*` as the remote name.

### jj rebase / squash

The rebase command works like you would expect, but better. You can rebase a  single change to a different place with `jj rebase -r id --insert-before A`, or rebase a change and all it’s descendants with `jj rebase -s id --insert-after B`. You can even rebase an entire branch automatically with `jj rebase -b @ --destination C`, moving every ancestor of `@` that is not an ancestor of `C` into a new chain of commits descending from `C`. I did all of these constantly in git, and it’s much more involved.

The squash command is just a clear, single command for the common git operation where you move a diff into a commit or move a diff out of a commit, by change ID and/or filename.

### jj merge (doesn’t exist)

The git rebase and merge commands (also including apply-patch, cherry-pick, and others) are all a bit special because they can create conflicts that have to be resolved before git will allow the commit to be… committed. This is the other half of the magic of jj: your new commit just holds any conflicts inside it. It’s impossible to lose work in a merge disaster because everything is always committed. You can resolve conflicts immediately, after other merges, or never! The results are always immediately stored, no matter how complete or incomplete your resolution is at the time.

Thanks to this feature, you don’t need a dedicated merge command—any new change can have however many parents you want, regardless of conflicts. It’s just as valid to `jj new A B C D E` as it is to `jj new A`. One pattern that is common in jj but was miserable in git is to create a “megamerge” combining all your current work branches. All editing happens on top of the megamerge, and you move individual changes backwards into a specific branch as you decide where to put them. Compared to git, it feels like magic.

### commands beyond git

There are many jj commands that have no analogous git command. Some real standouts include `jj absorb`, `jj parallelize`, and `jj undo`. We’ll talk more about those commands in a future post about jj beyond git.

### further command reading

The previously mentioned [jj cheat sheet PDF](https://justinpombrio.net/src/jj-cheat-sheet.pdf) has a second page, containing a quick summary of each command, what it does, and the arguments it accepts.

### next time

Now that we have talked about commands, next up is workflows! How can you use jj to work on a pull request? How can you work on multiple branches or PRs at the same time?

Continue with [`jj` part 3: workflows](/2025/10/12/jj-part-3-workflows/).

The full series also includes: [part 4: configuration](/2025/10/15/jj-part-4-configuration/)
