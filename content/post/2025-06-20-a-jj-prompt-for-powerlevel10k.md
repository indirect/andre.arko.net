+++
title = 'a jj prompt for powerlevel10k'
date = 2025-06-20T00:38:48-07:00
+++

I’m in the process of switching from git to [jj](github.com/jj-vcs/jj) right now. That switch is another post of its own, which I am still working on, but in the meantime I wanted to write up the way that I’ve set up my shell prompt to include information about the current jj repo. If you’re not already familiar with jj, you might find [the ways jj is different from git](https://jj-vcs.github.io/jj/latest/git-comparison/) helpful background reading for the rest of this post.

I use the default macOS shell, zsh, and I don’t put much information into my prompt: basically just the current directory and the current git branch name, colored to show if I’m ahead or behind the remote. Using jj adds some interesting caveats to this kind of prompt, since jj branches aren’t named, and jj bookmarks don’t move when you create new commits.

In order to keep the same kind of “where am I in this repo” information available in my prompt, I decided to show the name of the closest bookmark, as well as how many commits ahead or behind that bookmark I currently am. Conceptually, that changes my git prompt of `main` to a jj prompt of `main›3`, until I move the `main` bookmark up so I can push it to the git remote.

### the prompt itself

Let’s jump to the end first, and take a look at the final prompt I ended up with. I’m really happy with how it came out, I’ve deliberately broken it up into sections that can be enabled and disabled independently so other people can copy my implementation and turn on just the parts they like.

![a terminal prompt with the text "main›1 ⇣1⇡1 rouv [jj] add jj consume +1 ^1"](full-prompt.png)

    main›1 ⇣1⇡1 rouv [jj] add jj consume +1 ^1

In this prompt, `main` is the closest bookmark. It’s colored red because it is both ahead and behind the remote it is tracking. (If only behind, magenta, if only ahead, cyan, and if caught up, green.) The small arrow to the right and the number 1 are telling us that our current `@` is one non-empty commit beyond the local bookmark.

The downward and upward arrows only appear when the local bookmark is ahead or behind the remote tracking bookmark. In this case, `main` is exactly one commit behind and one commit ahead of `main@origin`.

As usual for `jj`, `r` is the shortest possible name for the current change, and `rouv` is the first four characters of that change. If the local and remote bookmarks are synced, and there are no changes beyond the local bookmark, this is the only visible indicator that we are in a `jj` repository vs just a plain `git` one.

If the current commit is in an unusual state, I add some icons here to tip me off:  unresolved conflicts get 💥, divergent changes (where a single change has more than one visible commit) get 🚧, hidden commits will show 👻, and immutable commits will show 🔒.

Then, `[jj] add jj consume` is the description of the current change. It can be hard to remember exactly what I meant to include or not include in a change while I’m working, so this helps, I think. If no description is set, but the commit isn’t empty, I display a pencil icon to remind me that I should add a description.

Finally, the `+1 -1 ^1` numbers are the count of new files, deleted files, and changed files in the current commit. If `@` is empty, those prompt segments just disappear.

To illustrate the base case, here’s an example where the local and remote bookmarks are synced, the working copy is empty, and this could be a git prompt (except for the `uump`, anyway).

![a terminal prompt with the text "main uump"](minimal-prompt.png)

    main uump

If all you care about is getting this prompt for yourself, you can copy [the full prompt segment](https://github.com/indirect/dotfiles/blob/main/dot_p10k.zsh#L1188-L1331) into your `~/.p10k` configuration file right now. If you’re interested in how it came about and how it works, keep reading.

### the prompt options so far

While initially setting up jj, I figured I would just copy and paste someone else’s shell prompt to start, and ended up surprised to find that there isn’t that much written up about jj shell prompts yet. For the [starship.io](https://starship.io) prompt manager, there’s [a pull request to add jj to starship](https://github.com/starship/starship/pull/5772) and a [tool named starship-jj that can output fixed information](https://gitlab.com/lanastara_foss/starship-jj). For zsh, there’s a page in the jj repo wiki, and the [zsh-jj](https://github.com/rkh/zsh-jj) repo that adds jj to the zsh builtin VCS info system.

In the course of trying to get jj status information into my prompt, I even briefly attempted switching my prompt entirely over to Starship, hoping I could simply slot in the existing jj support and continue on my way. Unfortunately, I happen to use [powerlevel10k](https://github.com/romkatv/powerlevel10k) to manage my zsh prompt, and it was written by someone absolutely obsessed with making shell prompts fast. As a result, I’ve gotten used to my shell prompt always showing up as fast as I can type new commands.

The existing prompt options not only aren’t quite able to provide the information that I wanted in my prompt, they also took a solidly noticeable amount of time to run, probably 200-300ms, blocking my shell prompt from appearing and making me annoyed at how slow my prompt suddenly became.

### making it fast

I was sure that someone, somewhere must have figured out how to leverage the optimized speed of p10k to provide status information even for programs that are slow to run, and it turned out I was right. After two days of wrangling Starship, I spent another hour of searching ever deeper into the wasteland of mostly-unrelated search results and hit the jackpot.

The author of p10k had once [given an example of how to write a shell prompt segment for a slow VCS system](https://www.reddit.com/r/zsh/comments/l2y976/comment/gkb9y72/) using the `zsh-async` library. Since the status commands run in the background, the prompt can first render the previous status, and then update shortly after with the latest fully up to date info.

Using that example as a baseline, someone else had posted a gist containing [a jj prompt using zsh-async](https://gist.github.com/mlcui-corp/78830fb9459f158b605cfcc87416e68f). That was the starting point that I could use to build a shell prompt that included all the information I wanted, without slowing down my shell interactions at all. My final prompt reuses the structure of powerlevel10k’s `my_git_formatter` function, set entirely inside the p10k + zsh-async framework set up in that gist.

### implementing the prompt

There are two parts to getting information out of jj: [revsets](https://jj-vcs.github.io/jj/latest/revsets/) and [templates](https://jj-vcs.github.io/jj/latest/templates/). Revsets are how you tell jj which changes you want to run the template against, and templates are how you tell jj what to output about each change. With those two primitives, you can extract just about anything you’d like to know.

While I was building the prompt, I tackled the sections from simplest to hardest, mostly because I was learning as I went and didn’t know how to get jj to output the more complicated stuff when I began. Let’s take a look at each section, and the commands that get run to create that output.

#### global options

Let’s look at the global options first, since they are shared across every section, and then we can take them as given.

    jj --ignore-working-copy --at-op=@ --no-pager

Option `--at-op=@` ensures that jj will not create an operation commit for this command. Then `--ignore-working-copy` stops jj from checking the filesystem for changes to add to the working copy. Together, those two options dramatically speed up the commands we are running. Finally, the global `--no-pager` option makes sure that jj won’t try to send the output to a pager no matter how long it is.

Okay, now back to the actual section commands.

#### jj\_add

The first section is named `jj_add`, and all it does is add changes from the filesystem into jj’s working copy `@`, so the following commands will reflect the latest state of the world. If you’re already using Watchman or some other mechanism to track filesystem changes, you don’t need this.

    ## jj_add
    jj debug snapshot

This section, uniquely out of all sections, does not include `--ignore-working-copy`, since that would defeat the point of updating the working copy.

Since this section doesn’t produce any output, it only contains the command that needs to be run. Every other section is going to contain a different pattern, assigning the output from jj into a shell variable, and then using conditionals on that variable to output the results with various colors and formatting.

For the full zsh code, please check out the repo. In this post I’m going to focus on explaining the jj commands, since the shell stuff is less novel (and this post is too long already).

#### jj\_op

The simplest section is the final one, `jj_op`. Somewhat like git’s reflog, jj tracks every change to the repo in a commit, allowing you either `jj undo` a single command, or jump to any previous state of the repo at any time. Since those operations are stored as commits, they have “operation IDs”.

    ## jj_op
    jj op log --no-graph --limit 1 --template "id.short()")

The jj command for this section is `op log`. The subcommand `op` is for dealing with operations, and `op log` simply prints the history of operations, similar to the command `git reflog`.  By default, jj prints logs as a kind of ascii graph, using circles and dashes to show how the commits are related. We disable that with `--no-graph`. Finally, we use `--limit 1` to only include the most recent operation, and `--template "id.short()"` to provide a jj template for the output we want.

In jj templates, the current object is implied and template methods will be called on that object. In this case, what we want is the short version of the commit sha ID for the most recent operation. The output from this template will be something like `896cefa54ed7`, and that’s what we color blue and then print at the end of the prompt.

#### jj\_desc

The next simplest section is `jj_desc`, which prints out either the first line of the current change’s description (a “commit message” in git), or a pencil icon to indicate that we have made changes but not yet described them. If there are no changes and no description, nothing is printed.

    ## jj_desc
    jj log --limit 1 --revset "@" --template "coalesce(
      description.first_line(),
      if(!empty, '\Uf040 ')
    )"

This command uses `--limit 1` in exactly the same way that the previous section did, but now applied to the `log` command which works very much like `git log`, showing the history of changes and their parents. The `revset` option tells jj which changes to include in the log, and by passing `@`, we are saying “only the current commit”. Basically the same as git’s `HEAD`, if you’re used to that.

The template option is where things get interesting: we’re starting to see the power of jj’s templating system here. First, we use the `coalesce()` function to return the first one of the arguments that has a value. If the first argument doesn’t have a value, we’ll get the second argument, and so on.

Our first argument starts with `description`, which is the full change description (like a commit message in git). The description property provides a function named `first_line()`. You can probably see where this is going. We’re going to get just the first line of the description (a commit title in git), if it exists.

The second argument is a compound value—it’s another top level function, `if()`. The `if` function returns the second argument only if the first argument is true. What’s the first argument? If a given change has no additions, deletions, or modifications in it, the `empty` property will be true. As in many languages, the `!` operator is a boolean negation, so the if statement will be true if the change is not empty. In that case, we return a string containing the Nerd Font unicode symbol for a [pencil icon](https://fontawesome.com/icons/pencil?s=solid).

If the change has no description, and is empty, both arguments will be empty, and so `coalesce()` will return nothing.

#### jj\_status

The status section might be the simplest jj command, even though the output parsing is a bit more complicated.

    ## jj_status
    VCS_STATUS_CHANGES=($(jj log -r @ -T "diff.summary()" 2> /dev/null | awk 'BEGIN {a=0;d=0;m=0} /^A / {a++} /^D / {d++} /^M / {m++} /^R / {m++} /^C / {a++} END {print(a,d,m)}'))

The template function `diff.summary()` returns just a list of added, removed, and changed files, one file per line. We use the revset `@` to only show the diff from the current change. The output is the main component of the output from running `jj status`, and looks a lot like `git status`.  Here’s an example:

    M .github/workflows/deploy.yml
    M archetypes/default.md
    A content/note/2025-06-13-fx.md
    M bin/build

If you count how many times each letter appears, that tells you how many files have been A(dded), D(eleted), or M(odified). The prompt section uses `awk` to count how many times each of those letters occurs, and then output the three numbers. The extra parentheses surrounding the jj command subshell tell zsh that it should create an array out of the values returned.

The next few lines of the prompt take those array items and add symbols and colors to make it clear which numbers mean what:

    (( VCS_STATUS_CHANGES[1] )) && res+=" %F{green}+${VCS_STATUS_CHANGES[1]}"
    (( VCS_STATUS_CHANGES[2] )) && res+=" %F{red}-${VCS_STATUS_CHANGES[2]}"
    (( VCS_STATUS_CHANGES[3] )) && res+=" %F{yellow}^${VCS_STATUS_CHANGES[3]}"

Luckily for us, zsh’s math mode `((expr))` treats a zero value as false, so we can use that to hide the parts that haven’t happened.

#### jj\_change

The jj\_change section is really only trying to print out the hash of the current change, equivalent to a git commit sha. Making it work the way jj expects required some gnarly bits, however.

    IFS="#" change=($(jj log -r "@" -T 'separate("#",
        change_id.shortest(4).prefix(),
        coalesce(change_id.shortest(4).rest(), "\0"),
        commit_id.shortest(4).prefix(),
        coalesce(commit_id.shortest(4).rest(), "\0"),
        concat(
            if(conflict, "💥"),
            if(divergent, "🚧"),
            if(hidden, "👻"),
            if(immutable, "🔒"),
        ),
    )'))

There are a few layers to making this work. The first one is setting `IFS`, the list of separators when splitting a string into an array. We only want to use `#`, a character that is guaranteed to not be part of any of our IDs.

Then, in the jj template itself, we use the `separate()` function. Every non-empty argument passed to separate will be printed out, with the separator character between. Unfortunately, that isn’t exactly what we want. We need to separate the “minimal prefix” from the remaining characters, so we can color things the same way jj would.

In some cases, the minimal prefix will be all four characters, and that means the second printed value will be empty. If it’s empty, the separate function skips it entirely, and there’s no way for us to tell whether the second or fourth argument is being left out.

To work around that problem, we’re using the `coalesce()` function, which returns the first argument that isn’t empty, along with a sentinel value of a single null, which jj considers “not empty”. Even better, zsh does consider a null to be empty, and so we get exactly the four item array that we want, even if the second or fourth value is empty.

    VCS_STATUS_CHANGE=($change[1] $change[2])
    VCS_STATUS_COMMIT=($change[3] $change[4])
    VCS_STATUS_ACTION=$change[5]

Once we have the four values, we print out the change ID and the commit ID with the same colorization that jj uses to indicate the smallest unambiguous ID for each.

    # 'zyxw' with the standard jj color coding for shortest name
    res+=" ${magenta}${VCS_STATUS_CHANGE[1]}${grey}${VCS_STATUS_CHANGE[2]}"

    # '💥🚧👻🔒' if the repo is in an unusual state.
    [[ -n $VCS_STATUS_ACTION ]] && res+=" ${red}${VCS_STATUS_ACTION}"

    # '123abc' with the standard jj color coding for shortest name
    res+=" ${blue}${VCS_STATUS_COMMIT[1]}${grey}${VCS_STATUS_COMMIT[2]}"

#### jj\_remote

Next, the remote output. Collecting these numbers depends on some work already done by the next section. You’ll see where this command slots in when we discuss the code in the next section, but for now all you need to know is that `$branch` is set to the name of the closest bookmark.

If the closest bookmark is tracking a remote bookmark with the same name, the jj template variable `remote` will contain the name of the remote, and we will print the tracking information that we want to show in the prompt.

    local counts=($(jj bookmark list -r $branch -T '
        if(remote, separate(" ",
            name ++ "@" ++ remote,
            coalesce(
                tracking_ahead_count.exact(),
                tracking_ahead_count.lower()
            ),
            coalesce(
                tracking_behind_count.exact(),
                tracking_behind_count.lower()
            ),
            if(tracking_ahead_count.exact(), "0", "+"),
            if(tracking_behind_count.exact(), "0", "+"),
        ) ++ "\n"
    )'))
    local VCS_STATUS_COMMITS_AHEAD=$counts[2]
    local VCS_STATUS_COMMITS_BEHIND=$counts[3]
    local VCS_STATUS_COMMITS_AHEAD_PLUS=$counts[4]
    local VCS_STATUS_COMMITS_BEHIND_PLUS=$counts[5]

Unfortunately, a performance optimization in jj means that sometimes the number of commits ahead or behind the remote is simply estimated. In my experience, this happens most often after reaching 10 commits, but the documentation seems to imply that it could happen at any number of commits.

If the `tracking_ahead_count.exact()` doesn’t exist, there will instead be a `tracking_ahead_count.lower()`, which is the lower bound of the number of commits that the local bookmark is ahead of the remote bookmark. In that case, we can also print an additional value of `+`, and use the same math evaluation mentioned before to decide whether to print the + or not.

Once we have the numbers, we check for non-zero values and print them out next to little arrows indicating whether the number is how many commits we are ahead or behind the remote. Here’s what that looks like.

    ## jj_remote

    # ⇣10+ if behind the remote.
    (( VCS_STATUS_COMMITS_BEHIND )) && res+=" ${green}⇣${VCS_STATUS_COMMITS_BEHIND}"
    (( VCS_STATUS_COMMITS_BEHIND_PLUS )) && res+="${VCS_STATUS_COMMITS_BEHIND_PLUS}"

    # ⇡10+ if ahead of the remote; no leading space if also behind the remote: ⇣10+⇡10+.
    (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && res+=" "
    (( VCS_STATUS_COMMITS_AHEAD  )) && res+="${green}⇡${VCS_STATUS_COMMITS_AHEAD}"
    (( VCS_STATUS_COMMITS_AHEAD_PLUS )) && res+="${VCS_STATUS_COMMITS_AHEAD_PLUS}"

#### jj\_at

The `jj_at` section is the most complicated one, so we’re going to break it down in pieces.

The first jj command is looking for the closest “named” change. A local bookmark, a remote bookmark, a tag, or if nothing else `trunk()`, a jj builtin for the bookmark named `main` or `master`.

    ## jj_at
    jj log --no-graph --limit 1 -r "coalesce(
      heads(::@ & bookmarks()),
      heads(::@ & remote_bookmarks()),
      heads(::@ & tags()),
      heads(@:: & bookmarks()),
      heads(@:: & remote_bookmarks()),
      heads(@:: & tags()),
      trunk()
    )" -T "separate(' ', bookmarks, tags)" | cut -d ' ' -f 1)


By combining `--limit 1` with this complicated revset, we get one single change. Let’s talk through the revset.

Coalesce means we’ll get the first one of the arguments that isn’t empty, so you can see that we are prioritizing local bookmarks, then remote bookmarks, then tags (which jj can read but not create), then the trunk branch.

The `heads()` function makes sure we get the very last change in the list, since it removes any commits with children from the list of arguments.

The `::@` means “any commit leading up to the current commit”, and then limiting that list to the intersection with `bookmarks()` gives us just the bookmarks that are an ancestor of the current commit.

Repeating that process for remote bookmarks and tags gives us every possible change with a name attached that is an ancestor of `@`. If we can’t find any, we check for descendants of `@`, and if we still can’t find any, we’ll just get `main`.

Once we have that one single commit, we print out a list of all bookmarks and tags that happen to apply, space separated, and then use `cut` to take just the first one. That will become our “branch”, the named commit that we use as a reference point for the other status indicators.

Now that we have a branch name, let’s find out close we are to it. Typically, the language used to refer to local and remote branches in git is “ahead” or “behind”, if there are local-only or remote-only commits, respectively.

Since ahead and behind (with up and down arrows) were already taken to track remote status, I landed on “before” and “after” (with left and right arrows) to indicate if our current change is an ancestor or a descendant of the named change. Here’s how we find that number:

    jj log --no-graph \
      -r "$branch..@ & (~empty() | merges())" \
      -T '"n"' | wc -c | tr -d ' '

This revset is simply every commit between our named branch and our current change, with empty commits removed. Since merge commits without conflict resolutions are also technically empty, we add them back in. This revset will return every commit between the named branch and the working copy, “after” the name. Repeating the command with an inverted revset of `@..$branch` returns changes “before” the name, if any.

Once we have that list of commits, we need to count it. Unfortunately, the way `jj log` works means it will run the template once per change in the revset. On the one hand, that’s very annoying because we want to know how many changes there are. On the other hand, that means we can just output any literal letter in the template and then use `wc` to count those literal letters to get our answer. That feels a little bit deranged to me, but is [apparently the best option available](https://github.com/jj-vcs/jj/discussions/6683).

After this, we run the code shown above in `jj_remote`, fetching the number of commits our current bookmark is ahead or behind the remote. With that information, we’re able to color-code the name we are about to print.

For me personally, just knowing if I am ahead or behind the remote is enough, and I don’t usually care to show exactly the number of commits in my prompt. As a result, I simply set the name to green by default, cyan if I have commits to push, and magenta if I have commits to pull. In the unlikely case I have both, I set the name to red.

    local status_color=${green}
    (( VCS_STATUS_COMMITS_AHEAD )) && status_color=${cyan}
    (( VCS_STATUS_COMMITS_BEHIND )) && status_color=${magenta}
    (( VCS_STATUS_COMMITS_AHEAD && VCS_STATUS_COMMITS_BEHIND )) \
      && status_color=${red}

Now that we’ve figured out the color of the name and added it to the prompt output, we can use the numbers we gathered a moment ago to print exactly how many commits we are before or after the name we found, with a “is this value nonzero” arithmetic check.

    # ‹42 if before the local bookmark
    (( VCS_STATUS_COMMITS_BEFORE )) && \
      res+="‹${VCS_STATUS_COMMITS_BEFORE}"
    # ›42 if beyond the local bookmark
    (( VCS_STATUS_COMMITS_AFTER )) && \
      res+="›${VCS_STATUS_COMMITS_AFTER}"

And that’s it! We’ve finally calculated everything from the jj prompt you saw at the beginning of this post. If you made it all the way to the end, congratulations! Feel free to grab your own copy of [the prompt segment code](https://github.com/indirect/dotfiles/blob/main/dot_p10k.zsh#L1188-L1331), customize the parts you want or don’t want, and add it to your p10k config.
