+++
title = '<code>jj</code> part 4: configuration'
slug = 'jj-part-4-configuration'
date = 2025-10-15T19:52:56-09:00
+++

Just like git, jj offers tiers of configuration that layer on top of one another. Every setting can be set for a single repo, for the current user, or globally for the entire system. Just like git, jj offers the ability to create aliases, either as shortcuts or by building up existing commands and options into new completely new commands.

Completely unlike git, jj also allows configuring revset aliases and default templates, extending or replacing built-in functionality. Let's look at the ways it's possible to customize jj via configurations. We'll cover basic config, custom revsets, custom templates, and custom command aliases.

### config basics

Let's start with some configuration basics. You can globally configure jj to change your name and email based on a path prefix, so you don’t have to remember to set your work email separately in each work repo anymore.

```Toml
[[--scope]]
--when.repositories = ["~/work"]
[--scope.user]
email = "me@work.domain"
```

Or perhaps you want jj to wait for your editor if you are writing a commit message, but you don't want jj to wait for your editor to exist if you are editing your jj configuration file. You can ensure that using a scope.

```Toml
ui.editor = "code -w"
[[--scope]]
--when.commands = ["config"]
[--scope.ui]
ui.editor = "code"
```

I also highly recommend trying out multiple options for formatting your diffs, so you can find the one that is most helpful to you. A very popular diff formatter is `difftastic`, which provides syntax aware diffs for many languages. I personally use `delta`, and the configuration to format diffs with delta looks like this:

```Toml
[[--scope]]
--when.commands = ["diff", "show"]
[--scope.ui]
pager = "delta"
diff-formatter = ":git"
```

Another very impactful configuration is which tool jj uses to handle interactive diff editing, such as in the `jj split` or `jj squash -i` commands. While the default terminal UI is pretty good, make sure to also try out Meld, an open source GUI.

```Toml
[ui]
diff-editor = "meld" # or vimdiff, vscode, etc
```

In addition to changing the diff editor, you can also change the merge editor, which is the program that is used to resolve conflicts. Meld can again be a good option, as well as any of several other merging tools.

```Toml
[ui]
merge-editor = "meld" # or vimdiff, vscode, mergiraf etc
```

Tools like [mergiraf](https://mergiraf.org/) provide a way to attempt syntax-aware automated conflict resolution before handing off any remaining conflicts to a human to resolve. That approach can dramatically reduce the amount of time you spend manually handling conflicts.

You might even want to try FileMerge, the macOS developer tools built-in merge tool. It supports both interactive diff editing and conflict resolution.

```Toml
[merge-tools.filemerge]
program = "open"
edit-args = ["-a", "FileMerge", "-n", "-W", "--args",
             "-left", "$left", "-right", "$right",
             "-merge", "$output"]
merge-args = ["-a", "FileMerge", "-n", "-W", "--args",
              "-left", "$left", "-right", "$right",
              "-ancestor", "$base", "-merge", "$output",]
```

Just two more configurations before we move on to templates. First, the default subcommand, which controls what gets run if you just type `jj` and hit return. The default is to run `jj log`, but my own personal obsessive twitch is to run `jj status` constantly, and so I have changed my default subcommand to `status`, like so:

```Toml
[ui]
default-command = ["status"]
```

The last significant configuration is the default revset used by `jj log`. Depending on your work patterns, the multi-page history of commits in your current repo might not be helpful to you. In that case, you can change the default revset shown by the log command to one that’s more helpful. My own default revset shows only one change from my origin. If I want to see more than the newest change from my origin I use `jj ll` to get the longer log, using the original default revset. I'll show that off later.

```Toml
[revsets]
log = "(trunk()..@):: | (trunk()..@)-"
```

### templates

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

### revset aliases

Building on the earlier section where we talked about [`jj log`](#), creating your own revset aliases is a powerful way to construct views tailored to your personal needs.

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

### command aliases

Okay. Now we can talk about command aliases. First up, the venerable `tug`. In the simplest possible form, it takes the closest bookmark, and moves that bookmark to `@-`, the parent of the current commit.

```Toml
tug = ["bookmark", "move", "--from", "heads(::@- & bookmarks())", "--to", "@-"]
```

What if you want it to be smarter, though? It could find the closest bookmark, and then move it to the closest _pushable_ commit, whether that commit was `@`, or `@-`, or `@---`. For that, you can create a revset for `closest_pushable`, and then tug from the closest bookmark to the closest pushable, like this:

```Toml
[revset-aliases]
'closest_pushable(to)' = 'heads(::to & mutable() & ~description(exact:"") & (~empty() | merges()))'
[aliases]
tug = 'bookmark move --from "heads(::@ & bookmarks())" --to "closest_pushable(@)"'
```

Now your bookmark jumps up to the change that you can actually push, by excluding immutable, empty, or descriptionless commits.

What if you wanted to allow tug to take arguments, for those times when two bookmarks are on the same change, or when you actually want to tug a different bookmark than the closest one? That’s also pretty easy, by adding a second variant of the tug command that takes an argument:

```Toml
tug = ["util", "exec", "--", "sh", "-c", """
if [ "x$1" = "x" ]; then
  jj bookmark move --from "closest_bookmark(@)" --to "closest_pushable(@)"
else
  jj bookmark move --to "closest_pushable(@)" "$@"
fi
""", ""]
```

This version of tug works just like the previous one if no argument is given. But if you do pass an argument, it will move the bookmark with the name that you passed instead of the closest one.

How about if you’ve just pushed to GitHub, and you want to create a pull request from that pushed bookmark? The `gh pr create` command isn’t smart enough to figure that out automatically, but you can tell it which bookmark to use:

```Toml
pr = ["util", "exec", "--", "bash", "-c", """
gh pr create --head $(jj log -r 'closest_bookmark(@)' -T 'bookmarks' --no-graph | cut -d ' ' -f 1)
"""]
```

Just grab the list of bookmarks attached to the closest bookmark, take the first one, pass it to `gh pr create`, and you’re all set.

What if you just want single commands that let you work against a git remote, with defaults tuned for automatic tugging, pushing, and tracking? I’ve also got you covered.

```Toml
init = ["util", "exec", "--", "bash", "-c", """
jj git init --colocate
# only track origin branches, not upstream or others
jj bookmark track 'glob:*@origin'
"""]
```

Use `jj init` to colocate jj into this git repo, and then track any branches from upstream, like you would get from a git clone.

```Toml
pull = ["util", "exec", "--", "bash", "-c", """

# Find the closest bookmark
closest="$(jj log -r 'closest_bookmark(@)' \
  -n 1 -T 'bookmarks' --no-graph | cut -d ' ' -f 1)"

# Remove the trailing * from the name if there is one
closest="${closest%\\*}"

# Now fetch from the git remote
jj git fetch

# If the closest bookmark still exists, rebase on it (else trunk)
jj log -n 1 -r "${closest}" 2>&1 > /dev/null \
  && jj rebase -d "${closest}" || jj rebase -d 'trunk()'

# Show the new state of things after the pull
jj log -r 'stack()'
"""]
```

Then, you can `jj pull` to find the closest bookmark to `@`, do a git fetch, rebase your current local commits on top of whatever just got pulled, and then show your new stack. When you’re done, just `jj push`.

```Toml
push = ["util", "exec", "--", "bash", "-c", """

# Check to see if we can tug a bookmark to @
tuggable="$(jj log -r 'closest_bookmark(@)..closest_pushable(@)' \
  -T '"n"' --no-graph)"

# If we can, tug that bookmark as close to @ as possible
[[ -n "$tuggable" ]] && jj tug

# Now find the closest thing that we can push to `origin`
pushable="$(jj log -r 'remote_bookmarks(remote=origin)..@' \
  -T 'bookmarks' --no-graph)"

# If we have something to push, run `jj git push`
[[ -n "$pushable" ]] && jj git push || echo "Nothing to push."

# Now that we have pushed, find the closest bookmark and remove *
closest="$(jj log -r 'closest_bookmark(@)' -n 1 -T 'bookmarks' \
  --no-graph | cut -d ' ' -f 1)"
closest="${closest%\\*}"

# Check to see if that bookmark is already tracking origin
tracked="$(jj bookmark list -r ${closest} -t \
  -T 'if(remote == "origin", name)')"

# If that bookmark isn't tracking origin, start to track origin
[[ "$tracked" == "$closest" ]] \
  || jj bookmark track "${closest}@origin"
"""]
```

This push handles looking for a tuggable bookmark, tugging it, doing a git push, and making sure that you’re tracking the origin copy of whatever you just pushed, in case you created a new branch.

### further reading

For another perspective on jj configuration, partly overlapping with this post, check out my JJ Con talk, [stupid jj tricks](/2025/09/28/stupid-jj-tricks/).

You can also try reading some jj config files directly, like [my jj config](https://github.com/indirect/dotfiles/blob/main/private_dot_config/private_jj/config.toml), or [thoughtpolice's jj config](https://gist.github.com/thoughtpolice/8f2fd36ae17cd11b8e7bd93a70e31ad6), or [pksunkara's jj config](https://gist.github.com/pksunkara/622bc04242d402c4e43c7328234fd01c).

### next time

Hopefully this tour through jj configuration options has revealed some ways that jj can be used to do more than was possible with only git. Next time, we'll focus on the ways that jj goes beyond git, offering things that were impractical or even impossible before.
