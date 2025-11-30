+++
title = '<code>jj</code> part 1: what is it'
slug = 'jj-part-1-what-is-it'
date = 2025-09-28T14:07:48+09:00
+++

I’ve been working on a blog post about migrating to jj for two months now. Rather than finish my ultimate opus and smother all of you in eight thousand words, I finally realized I could ship incrementally and post as I finish each section. Here’s part 1: what is jj and how do I start using it?

### pls, I just want to use `jj` with GitHub

Sure, you can do that. Convert an existing git repo with `jj git init --colocate` or clone a repo with `jj git clone`. Work in the repo like usual, but with no `add` needed, changes are staged automatically.

Commit with `jj commit`, mark what you want to push with `jj bookmark set NAME`, and then push it with `jj git push`. If you make any additional changes to that branch, update the branch tip by running `jj bookmark set NAME` again before each push.

Get changes from the remote with with `jj git fetch`. Set up a local copy of a remote branch with `jj bookmark track NAME@REMOTE`. Check out a branch with `jj new NAME`, and then loop back up to the start of the previous paragraph for commit and push. If you just want a slightly more detailed version of that, try [jj for my workflow](https://matthewkmayer.github.io/blag/public/post/jj-for-my-workflow/). That’s probably all you  need to get started, so good luck and have fun!

### `jj` concepts

Still here? Cool, let’s talk about how jj is different from git. There’s [a list of differences from git](https://jj-vcs.github.io/jj/v0.13.0/git-comparison/) in the jj docs, but more than specific differences, I found it helpful to think of jj as like git, but every change in the repo creates a commit.

Edit a file? There’s a commit before the edit and after the edit. Run a jj command? There’s a commit before the command and after the command. Some really interesting effects fall out of storing every action as a commit, like no more staging, trivial undo, committed conflicts , and change IDs.

When edits are always immediately committed, you don’t need a staging area, or to manually move files into the staging area. It’s just a commit, and you can edit it by editing the files on disk directly.

Any jj command you run can be fully rewound, because any command creates a new operation commit in the op log. No matter how many commits you just revised in that rebase, you can perfectly restore their previous state by running  `jj undo`.

Any merge conflict is stored in the commit itself. A rebase conflict doesn’t stop the rebase—your rebase is already done, and now has some commits with conflicts inside them. Conflicts are simply commits with conflict markers, and you can fix them whenever you want. You can even rebase a branch full of conflicts without resolving them! They’re just commits. (Albeit with conflict markers inside them.)

Ironically, every action being a commit also leads away from commits: how do you talk about a commit both before and after you amended it? You add change IDs. Changes give you a single identifier for your intention, even as you need many commits to track how you amended, rebased, and then merged those changes.

Once you’ve internalized a model where every state is a commit, and change IDs stick around through amending commits, you can do some wild shenanigans that used to be quite hard with git. Five separate PRs open but you want to work with all of them at once? Easy. Have one commit that needs to be split into five different new commits across five branches? Also easy.

One other genius concept jj offers is **revsets**. In essence, revsets are a query language for selecting changes, based on name, message, metadata, parents, children, or several other options. Being able to select lists of changes easily is a huge improvement, especially for commands like log or rebase.

### further reading

For more about jj’s design, concepts, and why they are interesting, check out the blog posts [jj strategy](https://reasonablypolymorphic.com/blog/jj-strategy/), [What I’ve Learned From JJ](https://zerowidth.com/2025/what-ive-learned-from-jj/), [jj init](https://v5.chriskrycho.com/essays/jj-init/), and [jj is great for the wrong reason](https://www.felesatra.moe/blog/2024/12/23/jj-is-great-for-the-wrong-reason). For a quick reference you can refer to later, there’s a single page summary in the [jj cheat sheet PDF](https://justinpombrio.net/src/jj-cheat-sheet.pdf).

### next time

Keep an eye out for the next part of this series in the next few days. We’ll talk about commands in jj, and exactly how they are both different and better than git commands.

Continue with [`jj` part 2: commands & revsets](2025/10/02/jj-part-2-commands/).

The full series also includes: [part 3: workflows](/2025/10/12/jj-part-3-workflows/), [part 4: configuration](/2025/10/15/jj-part-4-configuration/)
