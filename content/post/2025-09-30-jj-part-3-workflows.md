+++
title = '<code>jj</code> part 3: workflows'
slug = 'jj-part-3-workflows'
date = 2025-09-30T10:52:56+09:00
draft = true
+++

Now that you hopefully have an idea of how to operate jj, let’s look at the commands you need to get work done in jj. One great aspect of jj layering on top of git repos is that the git repo is still there underneath, and you can use any git command exactly like you usually would if there’s anything missing from your jj workflows.

### submit a pull request

The flow to create and send a PR will probably look pretty familiar: use `jj git clone` to get a copy of the repo, make your changes, use `jj commit` to create your new commits. When you’re ready, use `jj bookmark set NAME` to give your changes a name and `jj git push` to create a new branch on the remote. Use GitHub.com or `gh pr create --head NAME` to open the PR.

If you amend the commits in your PR, you can force-push the new commits with `jj git push`. If you add new changes on top, you’ll need to `jj bookmark set NAME` to update the bookmark to the latest change before you `jj git push` again.

That’s the whole flow! Congratulations on migrating from git to jj for your everyday work.

If using `bookmark set` all the time gets tedious, there’s a community alias named `jj tug` that finds the closest bookmark and moves it to the closest pushable change. I personally wrote an alias for myself named `jj push` that I use to handle pushing new changes to existing remote branches. We’ll talk about those aliases in the next major section, which is about configuring jj.

### work on multiple PRs at once

One situation I often find myself in is working on two (or even more) pull requests at the same time. With the powerful commit-editing primitives provided by jj, there are at least two (and probably more) ways to structure this kind of parallel work.

The first option is what I think of as merge-based: create a merge commit that unifies the tips of your two or more branches using `jj new -d A -d B`, do your work, and create new commits with `jj split` or `jj commit`. Then,  rebase those commits using `jj rebase -r @- --insert-before A` or the like, moving the new commits backwards into one of the PR branches. This is the same as the “megamerge” strategy described above, but it works just as well with two branches.

The second option is to liberally rebase every branch on top of each other, creating a completely linear history where PR #4 contains PR #3, which also contains PR #2, which also contains PR #1. Since jj uses change IDs to keep track of changes as their commits are amended or rebased, you can rebase the entire chain on top of new commits to `main`. Your bookmarks will stay in the same place, and you can `jj git push` to update each remote branch. Any time one of the PRs lands, you rebase your full chain on top of the new `main` and resume work where you left off.

If you want to work on multiple branches at once, you will probably also find the articles [Jujutsu Merge Workflow](https://ofcr.se/jujutsu-merge-workflow) and [Jujutsu Megamerges and `jj absorb`](https://v5.chriskrycho.com/journal/jujutsu-megamerges-and-jj-absorb/) interesting.

### further workflow reading

There are many new workflows that jj users have already developed, and this brief overview is just the tip of the iceberg. The jj docs include a section on [using jj with GitHub or GitLab](https://jj-vcs.github.io/jj/latest/github/), and there are some great reflections on different workflows in the blog posts  [Jujutsu VCS Introduction and Patterns](https://kubamartin.com/posts/introduction-to-the-jujutsu-vcs/), [Git experts should try Jujutsu](https://pksunkara.com/thoughts/git-experts-should-try-jujutsu/), and [jj tips and tricks](https://zerowidth.com/2025/jj-tips-and-tricks/).

### next time

Next up, we're going to talk about configuring jj. Want to use a diff tool? A merge tool? Add your own commands? Optimize your day to day work? We've got options.
