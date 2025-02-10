---
date: "2010-03-23T00:00:00Z"
title: tm, TextMate project management
---
I realized, the other day, that I always create a new TextMate project by running `mate .` whenever I want to edit code on a project. Unfortunately, that approach has frustrating downsides like forgetting per-project ignores, open files, window positions, and sidebar arrangement. To save all that stuff, you have to save a .tmproj file somewhere. But I could never figure out where to put them, and I never managed to remember to open them later since I was already in the habit of `mate .`.

One day, I tried to run `mate bundler` and realized that I should just create a command that would open the .tmproj files for me. That way, I don't have to remember where they are and I still get all the benefits of saving .tmproj files. So I created [tm](http://github.com/indirect/tm), a little tiny ruby script that opens .tmproj files by name if you save them into ~/.tmproj. (I symlink my dotfiles out of my Dropbox, so this works across my machines, too.) If you are so inclined, `tm` is even smart enough to wrap `mate` transparently, with the only additions being the ability to open (and tab complete) projects by name. Pretty handy.
