+++
title = 'Migrating to <code>jj</code>'
slug = 'Migrating to jj'
date = 2025-09-05T13:32:46-07:00
draft = true
+++

### I just want to use jj with GitHub, please

Sure, you can do that. Convert an existing git repo with `jj git init --colocate` or clone a repo with `jj git clone`. Work in the repo like usual, but with no `git add` needed, changes are staged automatically.

Commit with `jj commit`, mark what you want to push with `jj bookmark set my-github-branch`, and then push it with `jj git push`. If you make any additional changes to that branch, update the branch tip by running `jj bookmark set my-github-branch` again before each push.

Get changes from the remote with with `jj git fetch`. Set up a local copy of a remote branch with `jj bookmark track branch-name@origin`. Check out a branch with `jj new branch-name`, and then loop back up to the start of the previous paragraph for commit and push. That’s probably all you need to get started, so good luck and have fun!

### concepts

Still here? Cool, let’s talk about how jj is different from git. There’s [a list of differences from git](https://jj-vcs.github.io/jj/v0.13.0/git-comparison/) in the jj docs, but more than specific differences, I found it helpful to think of jj as like git, but every change in the repo creates a commit.

Edit a file? There’s a commit before the edit and after the edit. Run a jj command? There’s a commit before the command and after the command. Some really interesting effects fall out of storing every action as a commit, like no more staging, trivial undo, committed conflicts , and change IDs.

When edits are always immediately committed, you don’t need a staging area, or to manually move files into the staging area. It’s just a commit, and you can edit it by editing the files on disk directly.

Any jj command you run can be fully rewound, because any command creates a new operation commit in the op log. No matter how many commits you just revised in that rebase, you can perfectly restore their previous state by running  `jj undo`.

Any merge conflict is stored in the commit itself. A rebase conflict doesn’t stop the rebase—your rebase is already done, and now has some commits with conflicts inside them. Conflicts are simply commits with conflict markers, and you can fix them whenever you want. You can even rebase a branch full of conflicts without resolving them! They’re just commits. (Albeit with conflict markers inside them.)

Ironically, every action being a commit also leads away from commits: how do you talk about a commit both before and after you amended it? You add change IDs. Changes give you a single identifier for your intention, even as you need many commits to track how you amended, rebased, and then merged those changes.

Once you’ve internalized a model where every state is a commit, and change IDs stick around through amending commits, you can do some wild shenanigans that used to be quite hard with git. Five separate PRs open but you want to work with all of them at once? Easy. Have one commit that needs to be split into five different new commits across five branches? Also easy.

One other genius concept jj offers is **revsets**. In essence, revsets are a query language for selecting changes, based on name, message, metadata, parents, children, or several other options. Being able to select lists of changes easily is a huge improvement, especially for commands like log or rebase.

### further conceptual reading

For more about jj’s design, concepts, and why they are interesting, check out the blog posts [What I’ve Learned From JJ](https://zerowidth.com/2025/what-ive-learned-from-jj/), [jj init](https://v5.chriskrycho.com/essays/jj-init/), and [jj is great for the wrong reason](https://www.felesatra.moe/blog/2024/12/23/jj-is-great-for-the-wrong-reason). For a quick reference you can refer to later, there’s a single page summary in the [jj cheat sheet PDF](https://justinpombrio.net/src/jj-cheat-sheet.pdf).

### commands

Now, let’s take a look at the most common jj commands, with a special focus on the way arguments are generally consistent and switches don’t hide totally different additional commands.

The log command is the biggest consumer of revsets, which are passed using `-r` or `--revset`. With `@`, which is the jj version of `HEAD`, you can build a revset for exactly the commits you want to see. The git operator `..` is supported, allowing you to log commits after A and up to B with `-r A..B`, but that’s just the start. Here’s a quick list of some useful revsets to give you the flavor:
#### jj log
- `@-` the parent of the current commit
- `kv+` the first child of the change named `kv`
- `..A & ..B` changes in the intersection of `A` and `B`’s ancestors
- `~description(glob:"wip:\*")` changes whose message does _not_ start with `wip:`, because tilde negates a revset
- `heads(::@ & mutable() & ~description(exact:"") & (~empty() | merges()))` the closest “pushable” change, meaning the nearest ancestor of `@` that is mutable (by default mutable means “not in the main/trunk branch”), that has some description set, and that either has some changes or is a merge commit. (Some jj merge commits can be empty, if there were no conflicts.)

Using the jj config file, you can give any revset an alias, and then use that alias. I use `closest_pushable(@)` quite a bit, especially when naming branches and pushing.

For a full review of everything that’s possible with revsets, check out [the revset documentation](https://jj-vcs.github.io/jj/latest/revsets/) and the blog post [Understanding Revsets for a Better JJ Log Output](https://willhbr.net/2024/08/18/understanding-revsets-for-a-better-jj-log-output/).

#### jj commit / new / edit / split
The functionality of `git commit` is broken up into three separate jj commands. You use `new` to create a new empty child change, defaulting to `@`, and edit it. You use `edit` to re-open an existing change for amending, and `split` to interactively select a diff to break out into a second change. These are all common git workflows, done by using flags or multiple git commands, made direct and straightforward single commands in jj.

#### jj restore / abandon
What if `checkout` with file arguments had a semantic name? You go back to a previous file version using `restore` or use `abandon` to get files from your immediate parent.

#### jj bookmark list / set / track
Bookmarks are jj’s alternative to named git branches, and can be set up to automatically track a branch in a git remote. While compatibility with git branches is nice, names aren’t required by jj’s model. You can push your current unnamed change instantly with `jj git push --change @`, and jj will use the change ID (which stays the same across amends and rebases) as the git branch name. Now you don’t have to think of a good name for your branch before you can work on it (or push it!).

For more detail comparing and contrasting bookmarks to branches, I recommend the post [Understanding Jujutsu bookmarks](https://neugierig.org/software/blog/2025/08/jj-bookmarks.html).

#### jj git push / fetch
It does what you would expect based on git, but the defaults are different than you might expect. Unless you configure the `git.fetch` and `git.push` settings, jj will only push to or fetch from `origin`. To operate on another remote, pass `--remote NAME`. To operate on all remotes, use `glob:*` as the remote name.

#### jj rebase / absorb / squash
The rebase command works like you would expect, but better. You can rebase a  single change to a different place with `jj rebase -r id --insert-before A`, or rebase a change and all it’s descendants with `jj rebase -s id --insert-after B`. You can even rebase an entire branch automatically with `jj rebase -b @ --destination C`, moving every ancestor of `@` that is not an ancestor of `C` into a new chain of commits descending from `C`. I do all of these constantly in git, and it’s much more involved.

The absorb and squash commands are just clear, single commands for the common git operations where you move a diff into a commit or move a diff out of a commit, by change ID and/or filename.

#### jj undo / restore / op log
The op log is the first half of the big magical-feeling difference from git. Run any jj command, and don’t like the results? You can `jj undo` right back to the commits and files you had before. This magic is accomplished by creating a special kind of commit (an operation) every time a jj command is run. Operations are stored in a separate list, and `undo` is the same as restoring the parent of the current operation. The full list is available with `op log`, which also accepts revsets to filter and select operations.

#### jj merge (doesn’t exist)
The git rebase and merge commands (also including apply-patch, cherry-pick, and others) are all a bit special because they can create conflicts that have to be resolved before git will allow the commit to be… committed. This is the other half of the magic of jj: your new commit just holds any conflicts inside it. It’s impossible to lose work in a merge disaster because everything is always committed. You can resolve conflicts immediately, after other merges, or never! The results are always immediately stored, no matter how complete or incomplete your resolution is at the time.

Thanks to this feature, you don’t need a dedicated merge command—any new change can have however many parents you want, regardless of conflicts. It’s just as valid to `jj new A B C D E` as it is to `jj new A`. One pattern that is common in jj but was miserable in git is to create a “megamerge” combining all your current work branches. All editing happens on top of the megamerge, and you move individual changes backwards into a specific branch as you decide where to put them. Compared to git, it feels like magic.

#### further command reading

The previously mentioned [jj cheat sheet PDF](https://justinpombrio.net/src/jj-cheat-sheet.pdf) has a second page, containing a quick summary of each command, what it does, and the arguments it accepts.

### workflows

Now that you hopefully have an idea of how to operate jj, let’s look at the commands you need to get work done in jj. One great aspect of jj layering on top of git repos is that the git repo is still there underneath, and you can use any git command exactly like you usually would if there’s anything missing from your jj workflows.

#### submit a pull request
The flow to create and send a PR will probably look pretty familiar: use `jj git clone` to get a copy of the repo, make your changes, use `jj commit` to create your new commits. When you’re ready, use `jj bookmark set NAME` to give your changes a name and `jj git push` to create a new branch on the remote. Use GitHub.com or `gh pr create --head NAME` to open the PR.

If you amend the commits in your PR, you can force-push the new commits with `jj git push`. If you add new changes on top, you’ll need to `jj bookmark set NAME` to update the bookmark to the latest change before you `jj git push` again.

That’s the whole flow! Congratulations on migrating from git to jj for your everyday work.

If using `bookmark set` all the time gets tedious, there’s a community alias named `jj tug` that finds the closest bookmark and moves it to the closest pushable change. I personally wrote an alias for myself named `jj push` that I use to handle pushing new changes to existing remote branches. We’ll talk about those aliases in the next major section, which is about configuring jj.

#### work on multiple PRs at once

One situation I often find myself in is working on two (or even more) pull requests at the same time. With the powerful commit-editing primitives provided by jj, there are at least two (and probably more) ways to structure this kind of parallel work.

The first option is what I think of as merge-based: create a merge commit that unifies the tips of your two or more branches using `jj new -d A -d B`, do your work, and create new commits with `jj split` or `jj commit`. Then,  rebase those commits using `jj rebase -r @- --insert-before A` or the like, moving the new commits backwards into one of the PR branches. This is the same as the “megamerge” strategy described above, but it works just as well with two branches.

The second option is to liberally rebase every branch on top of each other, creating a completely linear history where PR #4 contains PR #3, which also contains PR #2, which also contains PR #1. Since jj uses change IDs to keep track of changes as their commits are amended or rebased, you can rebase the entire chain on top of new commits to `main`. Your bookmarks will stay in the same place, and you can `jj git push` to update each remote branch. As long as you merge your PRs in ascending order, the final repo result will reflect your incrementally reviewed and landed changes.

If you want to work on multiple branches at once, you will probably find the post [Jujutsu Megamerges and `jj absorb`](https://v5.chriskrycho.com/journal/jujutsu-megamerges-and-jj-absorb/) interesting.

#### further workflow reading

There are many new workflows that jj users have already developed, and this brief overview is just the tip of the iceberg. The jj docs include a section on [using jj with GitHub or GitLab](https://jj-vcs.github.io/jj/latest/github/), and there are some great reflections on different workflows in the blog posts  [Jujutsu VCS Introduction and Patterns](https://kubamartin.com/posts/introduction-to-the-jujutsu-vcs/), [Git experts should try Jujutsu](https://pksunkara.com/thoughts/git-experts-should-try-jujutsu/), and [jj tips and tricks](https://zerowidth.com/2025/jj-tips-and-tricks/).

### configuration

Just like git, jj offers tiers of configuration that layer on top of one another. Every setting can be set for a single repo, for the current user, or globally for the entire system. Just like git, jj offers the ability to create aliases, either as shortcuts or by building up existing commands and options into new completely new commands. Completely unlike git, jj also allows configuring revset aliases and default templates, extending or replacing built-in functionality.

#### Revset aliases

Building on the earlier section where we talked about [`jj log`](#jj-log "jj log"), creating your own revset aliases is a powerful way to construct views tailored to your personal needs.

A built-in revset alias we can use to illustrate this is `immutable()`. In the same way that git requires `--force` to push over an existing remote commit, jj requires `--ignore-immutable` to edit a commit matched by `immutable()`.

(Incidentally, I believe this arrangement is also an example of the way jj’s design is an improvement on git. Instead of deciding to overwrite published commits during a push, you are forced to decide much earlier, during the edit itself, if you are okay with changing a published commit. Anyway, back to revset aliases.)

The default `immutable_heads()` revset is `present(trunk()) | tags() | untracked_remote_bookmarks()`, which composes four other revsets together. Let’s look at each one. The `trunk()` revset is simply the primary branch, whether it is named `main` or `master`, wrapped in `present()` to remove it if none of those branches exist. The `tags()` revset is every change that has been given a tag. The `untracked_remote_bookmarks()` revset is exactly what it sounds like: any branch provided by the remote that you have not manually opted in to tracking locally (which is what you would do if you are working on the branch). All three revsets are combined into one overall list with the `|` operator. Those heads are then used to construct the full list of immutable commits, which is every ancestor of those heads.

Now that you know how that works, we can change it. For example, perhaps you want the same immutability rules that `git` provides, where commits are immutable once they have been pushed to any remote at all. In that case, you could add this to your config file:

```Toml
[revset-aliases]
"immutable_heads()" = "present(trunk()) | tags() | remote_bookmarks()"
```

With that configuration, jj will extrapolate that it cannot change any commits on the primary branch, all the commits leading up to a tag, and all commits leading up to a named branch in the remote. If you use this revset, jj will stop you from changing commits once you have pushed them to a branch, since you told it to make those immutable.

With this power at your disposal, you can change the default revset shown when you run `jj log`, or you can create your own named revsets for your own purposes. You can see [my revset aliases](https://github.com/indirect/dotfiles/blob/main/private_dot_config/private_jj/config.toml#L107) in my dotfiles, and read more about the default aliases in the jj docs.

### templates

The next configuration power that jj offers is templates, the ability to control how jj will display information about commits, diffs, and pretty much everything else. The jj templating language is limited, but pretty powerful! It has types, methods, and the ability to convert values to JSON for other software to read.
While the [jj template docs](https://jj-vcs.github.io/jj/latest/templates/) are a great reference, they don’t do very much to show off what’s possible by using templates, so we’ll show some examples.

The first and most obvious template is the `jj log` template, which controls how each change is rendered in the log output. The default template is named `builtin_log_compact`, and jj comes with a few pre-built template options for the log view, like `builtin_log_detailed` and `builtin_log_oneline`. You can see them all by running `jj log -T`.

Use `jj log -T NAME` to try them out and see how they look. If you want to experiment with your own custom log formats, you can provide a template string instead of the name of an existing template. Here’s an example inline template that prints out just the short change ID, a newline, and then the change description:

```bash
jj log -T 'change_id.short() ++ "\n" ++ description'
```

Try out the various [documented template properties](https://jj-vcs.github.io/jj/latest/templates/) yourself! Once you’re happy with a template that you’ve tested, you can add it to your config with a name, and then use it by name.

Here’s a more complicated example, adapted from @marchyman in the jj Discord, with several of the elements that we’ve discussed so far. This example changes the default command, adding extra options. It also uses a named revset alias, and a named template alias.

```bash
[ui]
default-command = ["log", "-T", "log_with_files", "--limit" "7"]

[revset-aliases]
'recent_work' = 'ancestors(visible_heads(), 3) & mutable()'

[template-aliases]
log_with_files = '''
if(root,
  format_root_commit(self),
  label(if(current_working_copy, "working_copy"),
    concat(
      format_short_commit_header(self) ++ "\n",
      separate(" ",
        if(empty, label("empty", "(empty)")),
        if(description,
          description.first_line(),
          label(if(empty, "empty"), description_placeholder),
        ),
      ) ++ "\n",
      if(self.contained_in("recent_work"), diff.summary()),
    ),
  )
)
'
```

The named template recreates the regular template from `log`, and uses a revset filter to include the list of changed files in changes that are both mutable (that is, not yet pushed) and also within 3 commits of the end of a branch. By showing up to 7 changes, but the file list for up to 3 mutable changes, the log output becomes more useful, reminding you what files have been changed in the most recent commits that you might want to push.

One more template you might want to adjust is the default description, shown when running `jj commit` or `jj desc` for a change that does not yet have a description. If you don’t use a VCS GUI, it can be helpful to see the diff of what is being committed at the same time as you write the commit message. In git, that meant running `git commit --verbose`, but in jj that means adjusting the default description. The [jj config docs](https://jj-vcs.github.io/jj/latest/config/#default-description) provide an example template that will replicate that effect, and show you the diff while you write the message.

One last semi-deranged templating trick before we move on to command aliases: counting changes. Git has a flag `--count` that prints a number, but jj doesn’t have that kind of flag. When I needed to count commits [for my jj shell prompt](https://andre.arko.net/2025/06/20/a-jj-prompt-for-powerlevel10k/), I was forced to come up with something to handle that

```bash
jj log --no-graph -r "main..@ & (~empty() | merges())" -T '"n"' 2> /dev/null | wc -c | tr -d ' '
```

This example returns the count of commits between the commit named `main` and the current commit `@`. It does that by printing a single letter for each commit, and then piping the output into `wc` for a count of characters, and then using `tr` to get rid of the extra whitespace. I’m not saying it’s good, but it does seem to be [the best option currently available](https://github.com/jj-vcs/jj/discussions/6683).

### Command aliases

### Further reading

My jj config
[https://github.com/indirect/dotfiles/blob/main/private\_dot\_config/private\_jj/config.toml](https://github.com/indirect/dotfiles/blob/main/private_dot_config/private_jj/config.toml)

Thoughtpolice’s jj config
[thoughtpolice/jjconfig.toml](https://gist.github.com/thoughtpolice/8f2fd36ae17cd11b8e7bd93a70e31ad6)

Pksunkara’s jj config
[https://gist.github.com/pksunkara/622bc04242d402c4e43c7328234fd01c](https://gist.github.com/pksunkara/622bc04242d402c4e43c7328234fd01c)

## jj beyond git

tk

Now that you’ve mastered replacing git with jj, what about the amazing new powers unlocked by jj itself? Well, the biggest power of jj is that you don’t need branches anymore. Create changes, rebase changes, stack five separate changes together and work on top of them while all five of them are reviewed separately. The world is your oyster.

[Reorient GitHub Pull Requests Around Changesets](https://mitchellh.com/writing/github-changesets)
[Why some of us like "interdiff" code review](https://gist.github.com/thoughtpolice/9c45287550a56b2047c6311fbadebed2)

Tangled.sh has shipped [jujutsu on tangled](https://blog.tangled.sh/stacking), allowing pull requests to be reviewed directly as stacked diffs.

