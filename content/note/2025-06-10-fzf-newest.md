+++
title = 'fzf with the newest files'
date = 2025-06-10T15:10:17-07:00
+++

Today I ran `hugo new` to create a file, and then wanted to edit it. I have `fzf` set up to let me open files in Vim, but suddenly realized… why doesn’t the file I just created show up as the first option in `fzf`? Apparently the answer is that it’s really annoying to get a recursive list of files and then sort them by creation date, to the point where [a Reddit post asking my exact question] had no answers.

It took a while to dig around in various different tools’ docs and repos, but I eventually landed on using `rg` to list files. This does exactly what I wanted, and I’m really happy with it:

```
FZF_DEFAULT_COMMAND='rg --files --sortr created' fzf --tmux --print0 | xargs -0 -o $EDITOR
```

Here’s a breakdown:
- `rg --files`  is how you ask `ripgrep` to list all files in the current directory, recursively (like `find . -type f`, but also respecting `.gitignore`)
- `--sortr created` is how you tell `ripgrep` that it should take every single file it finds and reverse-sort the full list by creation date (that’s how the newest file is the first result inside `fzf`)
- `--print0` make sure that fzf will escape file boundaries with a null, in case of special characters in the file name and/or multiple files selected
- `xargs -0 -o` not only tells xargs to use null separators, but the `-o` is a non-POSIX BSD extension (so it’s in macOS as well) that tells xargs to reopen stdin as /dev/tty inside the process it’s about to run. that makes it possible to interact with the editor, if you use a CLI editor
