---
layout: post
title: "git in as fw chrs as psbl"
microblog: false
guid: http://indirect-test.micro.blog/2019/01/20/git-in-as-fw-chrs/
post_id: 4971633
date: 2019-01-20T00:00:00-0800
lastmod: 2025-02-10T15:01:18-0800
type: post
images:
- https://cdn.uploads.micro.blog/205145/2025/7010e483c1.jpg
photos:
- https://cdn.uploads.micro.blog/205145/2025/7010e483c1.jpg
photos_with_metadata:
- url: https://cdn.uploads.micro.blog/205145/2025/7010e483c1.jpg
url: /2019/01/19/git-in-as-fw-chrs/
---
### or: learn from my dotfile mistakes

Over the years, I have accumulated a _lot_ of dotfiles around my coding workflow, and most of them are focused on git. Each time I notice that I'm spending a lot of time doing something over and over, I looked for a way to wrap that work up into a shortcut to make it faster. Today, I have a vibrant ecosystem of git aliases, bash aliases, and scripts that interact with both `git` and `hub` to make things happen.

None of it was designed, and none of it fundamentally makes sense, but I have a decade worth of muscle memory built up for this exact set of shortcuts and there's not a whole lot I can do about that now. So I'm going to show off my nonsensical gibberish that makes git do exactly what I want, and you can decide which pieces you want to steal but give names or shortcuts that make more sense.

Let's start with the workflow that I have personally optimized the most: cloning an open source project, forking it, making changes, pushing those changes, and opening a pull request. This will only touch a few of my shortcuts, but it will include the ones that I've put the most time and work into.

In this hypothetical example, I'm going to use [Bundler](https://github.com/bundler/bundler) (as if I were not a maintainer).

### OSS pull requests

		$ gc bundler/bundler
		$ hub fork
		$ git co -b indirect/bugfix
		# do some work here
		$ gs
		$ gd
		$ gi -am "Fixed the bug"
		$ # get distracted by something else for two days
		$ git rup
		$ git rebase origin master
		$ gp indirect
		$ hub prl
		https://github.com/bundler/bundler/pulls/12345

As you probably noticed, every line there (except `hub fork`) was some sort of shortcut. Let's look through them one at a time.

The `gc` command checks out a git repo into a specific directory structure: `~/src/username/reponame`, and then `cd`s into the directory. The `hub fork` command creates a fork of the repo under my own GitHub account. The `gs` command runs `git status`, the `gd` command shows a `git diff`, and the `gi` command runs `git commit`.

After two days of progress on the upstream, I use `rup` as an alias for `remote update`, which fetches the latest commits from all remotes, including both my fork and the upstream. Then I rebase against the upstream, use `gp indirect` to `git push` my HEAD commit to the `indirect` remote with the same remote branch name as I am using locally (which is `indirect/bugfix` in this example). After pushing to my fork, I use the `hub prl` shortcut to create a new pull request from my fork against the upstream, using the title of my last commit as the PR title, and using the body of my last commit message as the PR body.

It’s probably over-optimized, but when your workday includes anywhere from a few to dozens of PRs against repos that you don’t own, it really adds up.

I also have some other aliases that I use as a maintainer of Bundler. Here’s an example workflow.

### OSS code review

		$ j bundler
		$ git rup
		$ git ff
		$ git cleanup
		$ gb
		$ git pr 6754
		$ gd master
		# review the diff, run the code, etc

This set of commands fetches updates both from my fork and the upstream repo, fast forwards the main branch to the latest commit, deletes any local branches that have been merged into the main branch, and then checks out and reviews a PR.

		$ hub remote add username
		# make changes
		$ gp username pr-source-branch
		$ git wipe

In this OSS bonus round, I’m making some changes to an open PR against a repo where I am a maintainer. Since PRs grant edit permissions to maintainers, I am able to add the fork of the PR author, make changes, push to their PR branch, and then remove all remotes other than my own and the upstream with `wipe`.

### Daily work

		$ j codebase
		$ git rup
		$ git co latest
		$ git ff
		$ git cleanup
		$ git co -b indirect/something
		# make some commits here
		$ gp
		# notice a typo, fix it
		$ git add .
		$ git fixup
		$ gp -f
		# come back the next day
		$ git rup
		$ git co master
		$ git ff
		$ git co -
		$ git rebase master
		$ gp
		$ hub browse
		# use a browser to make a pull request

### Other git aliases

There are also a lot of shortcuts for more... esoteric... usecases. Let's look at some of those, too.

`git sha` prints the SHA of the HEAD commit.

`git cpsha` copies the SHA of the HEAD commit to the clipboard, so I can paste it somewhere else.

`git burn` deletes the most recent commit. It’s an alias to `git reset --hard HEAD^`.

`git nuke` removes every file that isn’t tracked by git. It’s an alias for `git reset --hard HEAD`.

`git nuke-all` removes every file and every directory that isn’t tracked by git. It’s an alias for `git reset --hard HEAD && git clean -fd`.

`git ls` combines a one-line git log format with verification of git commit signatures. The output shows sha, relative time, author, and commit subject, as well as a color-coded letter indicating whether a signature is valid, invalid, unknown, or missing.

![example of git ls](https://indirect-test.micro.blog/uploads/2025/7010e483c1.jpg)

### Other bash aliases

I also have a lot of Bash aliases, although most of them are shortcuts to common git commands.

    alias gb="git branch -v"
    alias gba="git branch -va --color | grep -v 'remotes/origin/pr'"
    alias gbl="git branch -vv --color | grep -v '\[.*\/.*\] '"
    alias gbr="git branch -vr --color | grep -v 'origin/HEAD'"
    alias gcp="git cherry-pick"
    alias gd="git diff"
    alias gds="git diff --cached"
    alias gdw="git diff --word-diff"
    alias gf="git fetch --all"
    alias gi="git commit -v"
    alias gia="git commit --amend -v"
    alias gl="git lg"
    alias gs="git status -sb"

    function gc {
      local repo=${1#*github.com/}
      repo=${repo%.git}
      hub clone --recursive "$repo" "$HOME/src/$repo"
      cd "$HOME/src/$repo"
    }

    function current_branch {
      status=$(git status 2> /dev/null)

      # Bail if status failed, not a git repo
      if [[ $? -ne 0 ]]; then return 1; fi

      # Try to get the branch from the status we already have
      if [[ $status =~ "# On branch (.*?) " ]]; then
        name="${BASH_REMATCH[1]}"
      fi

      # Check the output of `branch` next
      if [[ -z "$name" ]]; then
        name=$(git branch | grep '^*' | cut -b3- | grep -v '^(')
      fi

      # Fall back on name-rev
      if [[ -z "$name" ]]; then
        name=$(git name-rev --name-only --no-undefined --always HEAD)
        name="${name#tags/}"
        name="${name#remotes/}"
      fi

      echo "$name"
    }

    function gp {
      local current_branch=$(current_branch)
      local upstream=$(git config branch.$current_branch.remote)

      if [[ -z "$upstream" ]]; then
        if [[ "$1" == "-f" ]]; then
          local options="-uf"
          local remote="${2-origin}"
        else
          local remote="${1-origin}"
        fi

        git push "${options--u}" "$remote" "$current_branch"
      else
        git push "$@"
      fi
    }

    function mcd {
      mkdir -p "$@"
      cd "$@"
    }

I use `gc` and `gp` a lot in my day to day work.

The `current_branch` function does something that I’ve never seen anywhere else. Not only does it show the branch name, if you are in one, if you check out a commit that doesn’t have its own branch it will show you where you are relative to the nearest named branch or tag. For example, if you check out `branchname~6`, my git status line will show `branchname~6`. Every other status line that I’ve seen falls back to a generic 8-character SHA when you check out a commit that isn’t at the tip of a branch, which is (IMO) wayyyy less useful.

### Other git config

I don't actually know how to use git without these things turned on.

		[rerere]
			enabled = true
		[merge]
			conflictstyle = diff3
		[rebase]
			autoStash = true
		[diff]
			algorithm = patience

The `rerere` option means that you can resolve a rebase conflict one time, and have that resolution applied anytime you hit the same rebase conflict in the future.

The `diff3` conflict style means that when there’s a merge conflict, not only do you see the other commit, and your commit, you also see _the original content before either commit_. Those lines are often invaluable to me when I’m trying to figure out what the other person changed, what I changed, and how to combine them.

The `autoStash` option just means that you can rebase without committing everything first—the rebase command stashes before running, and pops after running. It’s great.

Finally, the `patience` algorithm optimizes diffs to reduce the (so, so common!) issue where adding a function creates a diff partly in the previous function and partly in the next function. With `patience` turned on, the diff will show just the new function, where you added it.

### Conclusion

That about wraps things up! These functions and aliases definitely aren’t something that I would directly recommend to anyone else, but hopefully seeing the kinds of things that I find useful has given you some inspiration for your own shortcuts. Hpy hkng!
