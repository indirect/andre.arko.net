+++
title = 'Migrating to <code>jj</code>'
date = 2025-07-17T13:32:46-07:00
draft = true
+++

## I just want to use jj with GitHub, man

Sure, you can do that. Convert an existing git repo with `jj git init --colocate` or clone a repo with `jj git clone`. Work in the repo like usual, but with no `add` needed, changes are staged automatically.

Commit with `jj commit`, mark what you want to push with `jj bookmark set NAME`, and then push it with `jj git push`.

Get changes from the remote with with `jj git fetch`. Switch where you’re working (like checking out a branch) with `jj new NAME`. That’s probably all you  need to get started, so good luck and have fun!

## concepts

Still here? Cool, let’s talk about how jj is different from git. There’s [a list of differences from git](https://jj-vcs.github.io/jj/v0.13.0/git-comparison/) in the jj docs, but more than specific differences, I found it helpful to think of jj as “what if everything in git was made into a commit”. That includes the staging area and the results of every single jj command. Some interesting effects fall out of treating everything as a commit, including undo, committed conflicts, and change IDs.

While using jj, any command can be rewound using `jj undo` because any command creates a new operation in the op log. Any merge conflict can be rebased without resolving it because the conflict itself is stored in the merge commit. A rebase failure doesn’t stop the rebase—your rebase now includes commits with conflicts inside them that you can fix any time later.

Ironically, everything being a commit leads away from commits: how do you talk about a commit both before and after you amended it? You add change IDs. Changes give you a single unchanging name for what you’re doing in a commit that’s been amended, rebased, and then used in a merge.

Once you’ve internalized a model where everything is a commit, and change IDs stick across amends, you can do some wild shenanigans that used to be quite hard with git. Five separate PRs open but you want to work with all of them at once? Easy. Made changes that need to be split into five different new commits across five branches? Also easy.

One other genius concept jj offers is revsets. In essence, it’s a query language for selecting changes, based on name, message, metadata, parents, children, or several other options. Being able to select lists of changes easily is a huge improvement for commands like log or rebase.

### further conceptual reading

For more about jj’s design, concepts, and why they are interesting, check out the blog posts [What I’ve Learned From JJ](https://zerowidth.com/2025/what-ive-learned-from-jj/) and [jj init](https://v5.chriskrycho.com/essays/jj-init/). For a quick reference you can refer to later, there’s a single page summary in the [jj cheat sheet PDF](https://justinpombrio.net/src/jj-cheat-sheet.pdf).

## commands

Now, let’s take a look at the most common jj commands, with a special focus on the way arguments are generally consistent and switches don’t hide totally different additional commands.

### jj log
The log command is the biggest consumer of revsets, which are passed using `-r` or `--revset`. With `@`, which is the jj version of `HEAD`, you can build a revset for exactly the commits you want to see. The git operator `..` is supported, allowing you to log commits after A and up to B with `-r A..B`, but that’s just the start. Here’s a quick list of some useful revsets to give you the flavor:
- `@-` the parent of the current commit
- `kv+` the first child of the change named `kv`
- `..A & ..B` changes in the intersection of `A` and `B`’s ancestors
- `~description(glob:"wip:\*")` changes whose message does _not_ start with `wip:`, because tilde negates a revset
- `heads(::@ & mutable() & ~description(exact:"") & (~empty() | merges()))` the closest “pushable” change, meaning the nearest ancestor of `@` that is mutable (by default mutable means “not in the main/trunk branch”), that has some description set, and that either has some changes or is a merge commit. (Some jj merge commits can be empty, if there were no conflicts.)

Using the jj config file, you can give any revset an alias, and then use that alias. I use `closest_pushable(@)` quite a bit, especially when naming branches and pushing.

For a full review of everything that’s possible with revsets, check out [the revset documentation](https://jj-vcs.github.io/jj/latest/revsets/) and the blog post [Understanding Revsets for a Better JJ Log Output](https://willhbr.net/2024/08/18/understanding-revsets-for-a-better-jj-log-output/).

### jj commit / new / edit / split
The functionality of `git commit` is broken up into three separate jj commands. You use `new` to create a new empty child change, defaulting to `@`, and edit it. You use `edit` to re-open an existing change for amending, and `split` to interactively select a diff to break out into a second change. These are all common git workflows, done by using flags or multiple git commands, made direct and straightforward single commands in jj.

### jj restore / abandon
What if `checkout` with file arguments had a semantic name? You go back to a previous file version using `restore` or use `abandon` to get files from your immediate parent.

### jj bookmark list / set / track
Bookmarks are jj’s equivalent to named git branches, and can be set up to automatically track a branch in a git remote. Compatibility with git branches is nice, but names aren’t required by jj’s model. You can push any change directly with `jj git push --change @`, and jj will use the change ID (which stays the same across amends and rebases) as the git branch name. Now you don’t have to think of a good name for your branch before you can work on it (or push it!).

### jj git push / fetch
The defaults here are different than you might expect. Unless you configure the `git.fetch` and `git.push` settings, jj will only push to or fetch from `origin`. To operate on another remote, pass `--remote NAME`. To operate on all remotes, use `glob:*` as the remote name.

### jj rebase / absorb / squash
The rebase command works like you would expect, but better. You can rebase a  single change to a different place with `jj rebase -r id --insert-before A`, or rebase a change and all it’s descendants with `jj rebase -s id --insert-after B`. You can even rebase an entire branch automatically with `jj rebase -b @ --destination C`, moving every ancestor of `@` that is not an ancestor of `C` into a new chain of commits descending from `C`. I do all of these constantly in git, and it’s much more involved.

The absorb and squash commands are just clear, single commands for the common git operations where you move a diff into a commit or move a diff out of a commit, by change ID and/or filename.

### jj undo / restore / op log
The op log is the first half of the big magical-feeling difference from git. Run any jj command, and don’t like the results? You can `jj undo` right back to the commits and files you had before. This magic is accomplished by creating a special kind of commit (an operation) every time a jj command is run. Operations are stored in a separate list, and `undo` is the same as restoring the parent of the current operation. The full list is available with `op log`, which also accepts revsets to filter and select operations.

### jj merge (doesn’t exist)
The git rebase and merge commands (also including apply-patch, cherry-pick, and others) are all a bit special because they can create conflicts that have to be resolved before git will allow the commit to be… committed. This is the other half of the magic of jj: your new commit just holds any conflicts inside it. It’s impossible to lose work in a merge disaster because everything is always committed. You can resolve conflicts immediately, after other merges, or never! The results are always immediately stored,  no matter how complete or incomplete your resolution is at the time.

Thanks to this feature, you don’t need a dedicated merge command—any new change can have however many parents you want, regardless of conflicts. It’s just as valid to `jj new A B C D E` as it is to `jj new A`. On top of merging always being possible, you can rebase your work on top of the “megamerge”backwards into any branch as you make new changes. Compared to git, it feels like magic.

### further command reading

The previously mentioned [jj cheat sheet PDF](https://justinpombrio.net/src/jj-cheat-sheet.pdf) has a second page, containing a quick summary of each command, what it does, and the arguments it accepts.

## workflows

Now that you hopefully have an idea of how to operate jj, let’s look at the commands you need to get work done in jj. One great aspect of jj layering on top of git repos is that the git repo is still there underneath, and you can use any git command exactly like you usually would if there’s missing from your jj workflows.

### submit a pull request
The flow to create and send a PR will probably look pretty familiar: use `jj git clone` to get a copy of the repo, make your changes, use `jj commit` to create your new commits. When you’re ready, use `jj bookmark set NAME` to give your changes a name and `jj git push` to create a new branch on the remote. Use GitHub.com or `gh pr create --head NAME` to open the PR.

If you amend the changes in your PR, you can push updated commits with `jj git push`. If you add new changes on top, you’ll need to `jj bookmark set NAME` to update the name to the latest change before you `jj git push` again. If that gets tedious, there’s a community alias named `jj tug` that finds the closest bookmark and moves it to the closest pushable change. We’ll talk about that in the next section, which is about configuring jj.

That’s the whole flow! Congratulations on migrating from git to jj for your everyday work.

### work on multiple PRs at once

tk

### further workflow reading

The jj docs include a section on [using jj with GitHub or GitLab](https://jj-vcs.github.io/jj/latest/github/), and there are some great reflections on different workflows in the blog posts [Jujutsu VCS Introduction and Patterns](https://kubamartin.com/posts/introduction-to-the-jujutsu-vcs/), [Git experts should try Jujutsu](https://pksunkara.com/thoughts/git-experts-should-try-jujutsu/), and [jj tips and tricks](https://zerowidth.com/2025/jj-tips-and-tricks/).

## configuration

tk

We are gonna talk so much about configuration.

My jj config
[https://github.com/indirect/dotfiles/blob/main/private\_dot\_config/private\_jj/config.toml](https://github.com/indirect/dotfiles/blob/main/private_dot_config/private_jj/config.toml)

Thoughtpolice’s jj config
[thoughtpolice/jjconfig.toml](https://gist.github.com/thoughtpolice/8f2fd36ae17cd11b8e7bd93a70e31ad6)

Pksunkara’s jj config
[https://gist.github.com/pksunkara/622bc04242d402c4e43c7328234fd01c](https://gist.github.com/pksunkara/622bc04242d402c4e43c7328234fd01c)

git commit —verbose
[https://jj-vcs.github.io/jj/latest/config/#default-description](https://jj-vcs.github.io/jj/latest/config/#default-description)

counting changes via `jj log`
[https://github.com/jj-vcs/jj/discussions/6683](https://github.com/jj-vcs/jj/discussions/6683)

jj template docs
[https://jj-vcs.github.io/jj/latest/templates/](https://jj-vcs.github.io/jj/latest/templates/)


## jj beyond git

tk

Now that you’ve mastered replacing git with jj, what about the amazing new powers unlocked by jj itself? Well, the biggest power of jj is that you don’t need branches anymore. Create changes, rebase changes, stack five separate changes together and work on top of them while all five of them are reviewed separately. The world is your oyster.

Tangled.sh has shipped [jujutsu on tangled](https://blog.tangled.sh/stacking), allowing pull requests to be reviewed directly as stacked diffs.

[Reorient GitHub Pull Requests Around Changesets](https://mitchellh.com/writing/github-changesets)
[Why some of us like "interdiff" code review](https://gist.github.com/thoughtpolice/9c45287550a56b2047c6311fbadebed2)
