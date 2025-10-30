+++
title = 'stupid jj tricks'
slug = 'stupid-jj-tricks'
date = 2025-09-28T11:00:00-08:00
+++

<small>This post was originally given as a talk for <a href="https://github.com/jj-vcs/jj/wiki/JJ-Con-2025">JJ Con</a>. The [slides](https://speakerdeck.com/indirect/stupid-jj-tricks) are also available.</small>

<script defer class="speakerdeck-embed" data-id="f204b260f0ba4c6186ba335b01dbe28d" data-ratio="1.7777777777777777" src="//speakerdeck.com/assets/embed.js"></script>

<b>WARNING: This content was written for (and presented at) the inagural JJ Con, a conference for `jj` enthusiasts and contributors. If you're new to using `jj`, I strongly recommend you read my other posts about `jj` first: [part 1](/2025/09/28/jj-part-1-what-is-it/), [part 2](/2025/10/02/jj-part-2-commands/), [part 3](/2025/10/12/jj-part-3-workflows/), [part 4](/2025/10/15/jj-part-4-configuration/).</b>

Welcome to “stupid jj tricks”. Today, I’ll be taking you on a tour through many different jj configurations that I have collected while scouring the internet. Some of what I’ll show is original research or construction created by me personally, but a lot of these things are sourced from blog post, gists, GitHub issues, Reddit posts, Discord messages, and more.

To kick things off, let me introduce myself. My name is André Arko, and I’m probably best known for spending the last 15 years maintaining the Ruby language dependency manager, Bundler. In the `jj` world, though, my claim to fame is completely different: Steve Klabnik once lived in my apartment for about a year, so I’m definitely an authority on everything about `jj`. Thanks in advance for putting into the official tutorial that whatever I say here is now authoritative and how things should be done by everyone using `jj`, Steve.

### general configuration

The first jj tricks that I’d like to quickly cover are some of the most basic, just to make sure that we’re all on the same page before we move on to more complicated stuff.

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

**Update:** there is now a `json()` template function, which makes it much simpler to output valid JSON, like so: `jj log --no-graph -T 'json(self) ++ "\n"'`.

Templates have vast possibilities that have not yet been touched on, and I encourage you to investigate and experiment yourself.

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

### commands

Now let’s talk about jj commands. You probably think I mean creating jj commands by writing our own aliases, but I don’t! That’s the next section. This section is about the jj commands that it took me weeks or months to realize existed, and understand how powerful they are.

First up: `jj absorb`. When I first read about absorb, I thought it was the exact inverse of squash, allowing you to choose a diff that you would bring into the current commit rather than eject out of the current commit. That is wildly wrong, and so I want to make sure that no one else falls victim to this misconception. The absorb command iterates over every diff in the current commit, finds the previous commit that changed those lines, and squashes just that section of the diff back to that commit. So if you make changes in four places, impacting four previous commits, you can `jj absorb` to squash all four sections back into all four commits with no further input whatsoever.

Then, `jj parallelize`. If you’re taking advantage of jj’s amazing ability to not need branches, and just making commits and squashing bits around as needed until you have each diff combined into one change per thing you need to submit… you can break out the entire chain of separate changes into one commit on top of trunk for each one by just running `jj parallelize 'trunk()..@'` and letting jj do all the work for you.

Last command, and most recent one: `jj fix`. You can use fix to run a linter or formatter on every commit in your history before you push, making sure both that you won’t have any failures and that you won’t have any conflicts if you try to reorder any of the commits later.

To configure the fix command, add a tool and a glob in your config file, like this:

```Toml
[fix.tools.black]
command = ["/usr/bin/black", "-", "--stdin-filename=$path"]
patterns = ["glob:'**/*.py'"]
```

Now you can just `jj fix` and know that all of your commits are possible to reorder without causing linter fix conflicts. It’s great.

### aliases

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

This push handles looking for a tuggable bookmark, tugging it, doing a git push, and making sure that you’re tracking the origin copy of whatever you just pushed, in case you created a new branch.

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

### shell prompt tricks

I would love to also talk about all the stupid shell prompt tricks that I was forced to develop while setting up a zsh prompt that includes lots of useful jj information without slowing down prompt rendering, but I’m already out of time. Instead, I will refer you to my [blog post about a jj prompt for powerlevel10k](https://andre.arko.net/2025/06/20/a-jj-prompt-for-powerlevel10k/), and you can spend another 30 minutes going down that rabbit hole whenever you want.

### acknowledgements

Finally, I want to thank some people. Most of all, I want to thank everyone who has worked on creating jj, because it is so good.

I also want to thank everyone who has posted their configurations online, inspiring this talk. All the people whose names I was able to find in my notes include @martinvonz, @thoughtpolice, @pksunkara, @scott2000, @avamsi, @simonmichael, and @sunshowers. If I missed you, I am very sorry, and I am still very grateful that you posted your configuration.

Last, I need to thank @steveklabnik and @endsofthreads for being jj-pilled enough that I finally tried it out and ended up here as a result.

Thank you so much, to all of you.
