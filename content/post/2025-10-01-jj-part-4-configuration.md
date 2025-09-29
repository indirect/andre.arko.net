+++
title = '<code>jj</code> part 4: configuration'
slug = 'jj-part-4-configuration'
date = 2025-10-01T10:52:56+09:00
draft = true
+++

Just like git, jj offers tiers of configuration that layer on top of one another. Every setting can be set for a single repo, for the current user, or globally for the entire system. Just like git, jj offers the ability to create aliases, either as shortcuts or by building up existing commands and options into new completely new commands. 

Completely unlike git, jj also allows configuring revset aliases and default templates, extending or replacing built-in functionality. Let's look at the ways it's possible to customize jj via configurations. We'll cover basic config, custom revsets, custom templates, and custom command aliases.

### general configuration

Let's start with some general configuration basics.

To start with, did you know that you can globally configure jj to change your name and email based on a path prefix? You don’t have to remember to set your work email separately in each work repo anymore.

```Toml
[[--scope]]
--when.repositories = ["~/work"]
[--scope.user]
email = "me@work.domain"
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

Tools like mergiraf provide a way to attempt syntax-aware automated conflict resolution before handing off any remaining conflicts to a human to resolve. That approach can dramatically reduce the amount of time you spend manually handling conflicts.

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

Okay, enough of plain configuration. Now let’s talk about templates! Templates make it possible to do many, many things with jj that were not originally planned or built in, and I think that’s beautiful.

First, if you haven’t tried this yet, please do yourself a favor and go try every builtin jj template style for the `log` command. You can list them all with `jj log -T`, and you can try them each out with `jj log -T NAME`. If you find a builtin log style that you especially like, maybe you should set it as your default template style and skip the rest of this section. For the rest of you sickos, let’s see some more options.

The first thing that I want to show you all is the draft commit description. When you run `jj commit`, this is the template that gets generated and sent to your editor for you to complete. Since I am the kind of person who always sets git commit to verbose mode, I wanted to keep being able to see the diff of what I was committing in my editor when using jj. Here’s what that looks like:

```Toml
[templates]
draft_commit_description = '''
  concat(
    coalesce(description, default_commit_description, "\n"),
    surround(
      "\nJJ: This commit contains the following changes:\n", "",
      indent("JJ:     ", diff.stat(72)),
    ),
    "\nJJ: ignore-rest\n",
    diff.git(),
  )
'''
```

If you’re not already familiar with the jj template functions, this uses `concat` to combine strings, `coalesce` to choose the first value that isn’t empty, `surround` to add before+after if the middle isn’t empty, and `indent` to make sure the diff status is fully aligned. With this template, you get a preview of the diff you are committing directly inside your editor, underneath the commit message you are writing.

Now let’s look at the overridable subtemplates. The default templates are made of many repeated pieces, including IDs, timestamps, ascii art symbols to show the commit graph visually, and more. Each of those pieces can be overrides, giving you custom formats without having to change the default template that you use.

For example, if you are a UTC sicko, you can change all timestamps to render in UTC like `2025-02-17 21:23:47.000 +00:00`, with this configuration:

```Toml
[template-aliases]
"format_timestamp(timestamp)" = "timestamp.utc()"
```

Or alternatively, you can force all timestamps to print out in full, like `2025-02-13 01:53:08.000 -08:00` (which is similar to the default, but includes the time zone) by returning just the timestamp itself:

```Toml
[template-aliases]
"format_timestamp(timestamp)" = "timestamp"
```

And finally you can set all timestamps to show a “relative” distance, like `7 months ago`, rather than a direct timestamp:

```Toml
[template-aliases]
"format_timestamp(timestamp)" = "timestamp.ago()"
```

Another interesting example of a template fragment is supplied by `@scott2000` on GitHub, who changes the node icon specifically to show which commits might be pushed on the next `jj git push` command.

```Toml
[templates]
log_node = '''
if(self && !current_working_copy && !immutable && !conflict && in_branch(self),
  "◇",
  builtin_log_node
)
'

[template-aliases]
"in_branch(commit)" = 'commit.contained_in("immutable_heads()..bookmarks()")'
```

This override of the `log_node` template returns a hollow diamond if the change meets some pushable criteria, and otherwise returns the `builtin_log_node`, which is the regular icon.

It’s not a fragment, but I once spent a good two hours trying to figure out how to get a template to render just a commit message body, without the “title” line at the top. Searching through all of the built-in jj templates finally revealed the secret to me, which is a template function named `remove_prefix()`. With that knowledge, it becomes possible to write a template that returns only the body of a commit message:

```Toml
description_body = 'description.remove_prefix(description.first_line()).trim_start()'
```

We first extract the title line, remove that from the front, and then trim any whitespace from the start of the string, leaving just the description body.

Finally, I’d like to briefly look at the possibility of machine-readable templates. Attempting to produce JSON from a jj template string can be somewhat fraught, since it’s hard to tell if there are quotes or newlines inside any particular value that would need to be escaped for a JSON object to be valid when it is printed. Fortunately, about 6 months ago, jj merged an `escape_json()` function, which makes it possible to generate valid JSON with a little bit of template trickery. For example, we could create a `log` output of a JSON stream document including one JSON object per commit, with a template like this one:

```Toml
log_json_stream = '''
  "{" ++ 
    "change_id".escape_json() ++ ": " ++ stringify(change_id).escape_json() ++ ", " ++ 
    "author".escape_json() ++ ": " ++ stringify(author).escape_json() ++
  "}\n"
'''
```

This template produces valid JSON that can then be read and processed by other tools, looks like this.

![json output from jj log, parsed and formatted by jq](json.png)

Templates have vast possibilities that have not yet been touched on, and I encourage you to investigate and experiment yourself.

### Revset aliases

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

### Templates

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

### revsets

Now let’s look at some revsets. The biggest source of revset aliases that I have seen online is from @thoughtpolice’s jjconfig gist, but I will consolidate across several different config files here to demonstrate some options.

The first group of revsets roughly corresponds to “who made it”, and composes well with other revsets in the future. For example, it’s common to see a `user(x)` type alias, and a `mine()` type alias to let the current user easily identify any commits that they were either author or committer on, even if they used multiple different email addresses.

```Toml
'user(x)' = 'author(x) | committer(x)'
'mine()' = 'user("me@personal.domain") | user("me@domain")'
```

Another group uses description prefixes to identify commits that have some property, like WIP or “private”. It’s then possible to use these in other revsets to exclude these commits, or even to configure jj to refuse to push them.

```Toml
'wip()' = 'description(glob:"wip:*")'
'private()' = 'description(glob:"private:*")'
```

Thoughtpolice seems to have invented the idea of a `stack`, which is a group of commits on top of some parent:

```Toml
# stack(x, n) is the set of mutable commits reachable from 'x',
# with 'n' parents. 'n' is often useful to customize the display
# and return set for certain operations. 'x' can be used to target
# the set of 'roots' to traverse, e.g. @ is the current stack.
'stack()' = 'stack(@)'
'stack(x)' = 'stack(x, 2)'
'stack(x, n)' = 'ancestors(reachable(x, mutable()), n)'
```

Building on top of the stack, it’s possible to construct a set of commits that are “open”, meaning any stack reachable from the current commit or other commits authored by the user. By setting the stack value to 1, nothing from trunk or other remote commits is included, so every open commit is mutable, and could be changed or pushed.

```Toml
'open()' = 'stack(mine() | @, 1)'
```

Finally, building on top of the open revset, it’s possible to define a “ready” revset that is every open change that isn’t a child of wip or private change:

```Toml
'ready()' = 'open() ~ descendants(wip() | private())'
```

It’s also possible to create a revset of “interesting” commits by using the opposite kind of logic, as in this chain of revsets composed by `@sunshowers`. 

```Toml
'uninterested()' = '::remote_bookmarks() | tags()'
'interested()' = 'mine() ~ uninterested()'
'open()' = '''
    ancestors(interested(), 3)
      | tracked_remote_bookmarks()
      | ancestors(@, 3)
'''
```

You take remote commits and tags, then subtract those from our own commits, and then show anything that is either local-only, tracking the remote, or close to the current commit.

### templates

Okay, enough of plain configuration. Now let’s talk about templates! Templates make it possible to do many, many things with jj that were not originally planned or built in, and I think that’s beautiful.

First, if you haven’t tried this yet, please do yourself a favor and go try every builtin jj template style for the `log` command. You can list them all with `jj log -T`, and you can try them each out with `jj log -T NAME`. If you find a builtin log style that you especially like, maybe you should set it as your default template style and skip the rest of this section. For the rest of you sickos, let’s see some more options.

The first thing that I want to show you all is the draft commit description. When you run `jj commit`, this is the template that gets generated and sent to your editor for you to complete. Since I am the kind of person who always sets git commit to verbose mode, I wanted to keep being able to see the diff of what I was committing in my editor when using jj. Here’s what that looks like:

```Toml
[templates]
draft_commit_description = '''
  concat(
    coalesce(description, default_commit_description, "\n"),
    surround(
      "\nJJ: This commit contains the following changes:\n", "",
      indent("JJ:     ", diff.stat(72)),
    ),
    "\nJJ: ignore-rest\n",
    diff.git(),
  )
'''
```

If you’re not already familiar with the jj template functions, this uses `concat` to combine strings, `coalesce` to choose the first value that isn’t empty, `surround` to add before+after if the middle isn’t empty, and `indent` to make sure the diff status is fully aligned. With this template, you get a preview of the diff you are committing directly inside your editor, underneath the commit message you are writing.

Now let’s look at the overridable subtemplates. The default templates are made of many repeated pieces, including IDs, timestamps, ascii art symbols to show the commit graph visually, and more. Each of those pieces can be overrides, giving you custom formats without having to change the default template that you use.

For example, if you are a UTC sicko, you can change all timestamps to render in UTC like `2025-02-17 21:23:47.000 +00:00`, with this configuration:

```Toml
[template-aliases]
"format_timestamp(timestamp)" = "timestamp.utc()"
```

Or alternatively, you can force all timestamps to print out in full, like `2025-02-13 01:53:08.000 -08:00` (which is similar to the default, but includes the time zone) by returning just the timestamp itself:

```Toml
[template-aliases]
"format_timestamp(timestamp)" = "timestamp"
```

And finally you can set all timestamps to show a “relative” distance, like `7 months ago`, rather than a direct timestamp:

```Toml
[template-aliases]
"format_timestamp(timestamp)" = "timestamp.ago()"
```

Another interesting example of a template fragment is supplied by `@scott2000` on GitHub, who changes the node icon specifically to show which commits might be pushed on the next `jj git push` command.

```Toml
[templates]
log_node = '''
if(self && !current_working_copy && !immutable && !conflict && in_branch(self),
  "◇",
  builtin_log_node
)
'

[template-aliases]
"in_branch(commit)" = 'commit.contained_in("immutable_heads()..bookmarks()")'
```

This override of the `log_node` template returns a hollow diamond if the change meets some pushable criteria, and otherwise returns the `builtin_log_node`, which is the regular icon.

It’s not a fragment, but I once spent a good two hours trying to figure out how to get a template to render just a commit message body, without the “title” line at the top. Searching through all of the built-in jj templates finally revealed the secret to me, which is a template function named `remove_prefix()`. With that knowledge, it becomes possible to write a template that returns only the body of a commit message:

```Toml
description_body = 'description.remove_prefix(description.first_line()).trim_start()'
```

We first extract the title line, remove that from the front, and then trim any whitespace from the start of the string, leaving just the description body.

Finally, I’d like to briefly look at the possibility of machine-readable templates. Attempting to produce JSON from a jj template string can be somewhat fraught, since it’s hard to tell if there are quotes or newlines inside any particular value that would need to be escaped for a JSON object to be valid when it is printed. Fortunately, about 6 months ago, jj merged an `escape_json()` function, which makes it possible to generate valid JSON with a little bit of template trickery. For example, we could create a `log` output of a JSON stream document including one JSON object per commit, with a template like this one:

```Toml
log_json_stream = '''
  "{" ++ 
    "change_id".escape_json() ++ ": " ++ stringify(change_id).escape_json() ++ ", " ++ 
    "author".escape_json() ++ ": " ++ stringify(author).escape_json() ++
  "}\n"
'''
```

This template produces valid JSON that can then be read and processed by other tools, looks like this.

![json output from jj log, parsed and formatted by jq](json.png)

Templates have vast possibilities that have not yet been touched on, and I encourage you to investigate and experiment yourself.

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
closest="$(jj log -r 'closest_bookmark(@)' -n 1 -T 'bookmarks' --no-graph | cut -d ' ' -f 1)"
closest="${closest%\\*}"
jj git fetch
jj log -n 1 -r "${closest}" 2>&1 > /dev/null && jj rebase -d "${closest}" || jj rebase -d 'trunk()'
jj log -r 'stack()'
"""]
```

Then, you can `jj pull` to find the closest bookmark to `@`, do a git fetch, rebase your current local commits on top of whatever just got pulled, and then show your new stack. When you’re done, just `jj push`.

```Toml
push = ["util", "exec", "--", "bash", "-c", """
tuggable="$(jj log -r 'closest_bookmark(@)..closest_pushable(@)' -T '"n"' --no-graph)"
[[ -n "$tuggable" ]] && jj tug
pushable="$(jj log -r 'remote_bookmarks(remote=origin)..@' -T 'bookmarks' --no-graph)"
[[ -n "$pushable" ]] && jj git push || echo "Nothing to push."
closest="$(jj log -r 'closest_bookmark(@)' -n 1 -T 'bookmarks' --no-graph | cut -d ' ' -f 1)"
closest="${closest%\\*}"
tracked="$(jj bookmark list -r ${closest} -t -T 'if(remote == "origin", name)')"
[[ "$tracked" == "$closest" ]] || jj bookmark track "${closest}@origin"
"""]
```

This push handles looking for a huggable bookmark, tugging it, doing a git push, and making sure that you’re tracking the origin copy of whatever you just pushed, in case you created a new branch.

### combo tricks

Last, but definitely most stupid, I want to show off a few combo tricks that manage to deliver some things I think are genuinely useful, but in a sort of cursed way.

First, we have counting commits. In git, you can pass an option to log that simply returns a number rather than a log output. Since jj doesn’t have anything like that, I was forced to build my own when I wanted my shell prompt to show how many commits beyond trunk I had committed locally. In the end, I landed on a template consisting of a single character per commit, which I then counted with `wc`.

```Toml
jj log --no-graph -r "main..@ & (~empty() | merges())" -T '"n"' 2> /dev/null | wc -c | tr -d ' '
```

That’s [the best anyone on GitHub could come up with, too](https://github.com/jj-vcs/jj/discussions/6683). See? I warned you it was stupid.

Next, via `@marchyman` on Discord, I present: `jj log` except for the closest three commits it also shows `jj status` at the same time.

```Toml
[aliases]
ll = ["log", "-T", "log_with_files"]

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

Simply create a new template that copies the regular log template, while inserting a single conditional line that adds `diff.summary()` if the current commit is inside your new revset that covers the newest 3 commits. Easy. And now you know how to create the `jj ll` alias I promised to explain earlier.

Last, but definitely most stupid, I have ported my previous melding of `git branch` and `fzf` over to `jj`, as the subcommand `fuzzy_bookmark`, which I alias to `jj z` because it’s inspired by `zoxide`, the shell cd fuzzy matcher with the command `z`.

```Toml
z = ["fuzzy_bookmark"]
za = ["bookmark", "list", "-a"]

fuzzy_bookmark = ["util", "exec", "--", "sh", "-c", """
if [ "x$1" = "x" ]; then
  jj bookmark list
else
  jj bookmark list -a -T 'separate("@", name, remote) ++ "\n"' 2> /dev/null | sort | uniq | fzf -f "$1" | head -n1 | xargs jj new
fi
""", ""]
```

This means you can `jj z` to see a list of local bookmarks, or `jj za` to see a list of all bookmarks including remote branches. Then, you can `jj z some` to do a fuzzy match on `something`, and execute `jj new something`. Jump to work on top of any named commit trivially by typing a few characters from its name.

### further reading

My jj config
[https://github.com/indirect/dotfiles/blob/main/private\_dot\_config/private\_jj/config.toml](https://github.com/indirect/dotfiles/blob/main/private_dot_config/private_jj/config.toml)

Thoughtpolice’s jj config
[thoughtpolice/jjconfig.toml](https://gist.github.com/thoughtpolice/8f2fd36ae17cd11b8e7bd93a70e31ad6)

Pksunkara’s jj config
[https://gist.github.com/pksunkara/622bc04242d402c4e43c7328234fd01c](https://gist.github.com/pksunkara/622bc04242d402c4e43c7328234fd01c)

### next time

Hopefully this tour through jj configuration options has revealed some ways that jj can be used to do more than was possible with only git. Next time, we'll focus on the ways that jj goes beyond git, offering things that were impractical or even impossible before.
