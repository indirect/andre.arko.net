---
title: Vim is the worst editor
layout: post
---
### &hellip;except all the other editors

I want to like Vim so badly! I've been using it full-time for just over three months now. I finished [Vim Adventures][vim-adventures], I've been reading [Practical Vim][pragprog], and watching some [Vimcasts][vimcasts]. I've even been asking my [smart][twitter 2] [vim][twitter 3] [friends][twitter 4] for help.

Unfortunately, it's still driving me insane. The things it does badly make me want to stop using it almost every single day. That makes me really sad, because the things it does well, it does _phenomenally_ well. After 3 months in Vim, I get incredibly angry trying to use other text editors because they do so many editing tasks so poorly in comparsion to Vim.

So, in no particular order, here's a list of things that drive me insane about Vim. After reading this list, feel free to tell me how I'm doing it wrong [on twitter][twitter 5].

  1. Janus

    "Here, we've set up everything you need to use Vim." Except it's way too much stuff, it's fiddly, it's semi-broken in various places, and having it installed makes Vim _incredibly slow_. It takes more than one second to open a new window in MacVim, and it takes more than one second to open a file in terminal Vim. That is crazy and unacceptable. That said, I'm still using it because I don't want to take the time to figure out how to manually add back in all of the pieces I actually do want, like support for all the languages I care about, and syntax checking on save, and the other stuff like that.

  1. Files that change.

    Argh, argh, argh. This is so frustrating. If I edit a file in another process, or if I edit a file using [pry-rescue][github]'s `edit` command, Vim screeches loudly that my file has been changed and do I want to reload it from disk. I have to read the message, decide what to do, and then continue. Every. Single. Time.

    While it's possible to turn on `autoload`, something still has to trigger Vim's `:checktime` command. Some people do things like trigger it on every cursor move, or every 1-2 seconds. That is _completely insane_. Every invocation stats the file on disk. If you have 100 buffers open, that is 100 stats per second. NO, because no.

    Other editors automatically save when they lose focus, and register for file system notifications when any file that's open changes. When the file is open, they immediately read the file again, whether in the foreground or background. I never have to think about it. It's great.

  1. Indenting pastes.

    You're all about to start yelling "use `p` instead of `⌘V`, you idiot", but that's not what I'm talking about at all. TextMate has an _incredibly_ smart paste system. Every paste is automatically re-indented to match the indentation level of the cursor at the moment of pasting. It never even occurred to me that indentation of pastes was a thing that ever required thought of any kind.

    Then I switched to Vim, and discovered that [leading Vim minds][twitter] [suggest][uniqpath] that you "simply" run ``V`]=`` after _every goddamn paste_. No, no, and also: no.

     I guess I can try to figure out how to hook vim to automatically run that after every time I use `p`, but that seems terrible, and would forcibly re-align sub-line pastes.

    To add insult to injury, Vim's automatic indentation, triggered by `==`, is frequently just wrong. Then I have to manually adjust by running ``V`]>`` or whatever, and that is also... pretty terrible.

  1. Project-wide find and replace

    I am aware of both `:Ack` and `:Ag`, but there's a reason that I rarely used them before: printing out lines with matches is not that great. Jumping to matches inside files, having the results live update as I make changes and then save, and being able to do a project-wide find and replace where I can live-preview the results of the replace operation for every single line in the project that matched? _That_ is a good project search.

    *Update:* The fantastic [Larry][twitter 2] tells me that this is possible in Vim:

        /Pragmatic\ze Vim
        :vimgrep /<C-r>// **/*.txt
        :Qargs
        :argdo %s//Practical/g
        :argdo update
    
    While I am incredibly impressed that Vim has primitives that allow this, five commands is a pretty crappy replacement for `<tab>Practical`, in my opinion.

  1. Opening files inside my project

    This seems completely insane, but there is no file opener that is as good as TextMate's decade-old ⌘T. The ctrl-p and command-t plugins both try, but neither one is as fast, they are both quite hard to exclude files from, and they have no facility for per-project excludes. In fact, anyone who wants per-project excludes is told to manually set up their own per-project vimrc files and then write the Vim configuration lines required to cause those files to be ignored. You have got to be kidding me.

  1. Navigating inside files

    Jump to method definition. Jump to CSS selector. Jump to class. Fuzzy string matching. All these things and more are what I am used to. Vim just _can't do them_. Everyone says to use `ctags`, which is a great idea, but completely isn't the thing that I am talking about. The tiny, tiny percentage of the time that I want to jump to the definition of a method that is named in my buffer, `ctags` is fantastic.
    
    The rest of the time, I want to jump to something that is _not_ written out inside this buffer, but is instead simply elsewhere in the file. Or is a CSS selector. Using `/` to search is not fuzzy matching. It is _terrible_ in comparison.

  1. Soft-wrapped text

      Welcome to the modern world! Text does not need to be hard wrapped at 80 columns, and paragraphs do not need to be indicated by two line-breaks in a row. In fact, it's entirely possible to edit plaintext files that are _softwrapped_ in any modern text editor. But not in Vim. In Vim, your options are automatic hardwrapping or remapping `j` and `k` to `gj` and `gk` so you can still use them in softwrapped text. Grrrr.
      
      If you then expect something completely absurd like your editor to have indentation awareness while softwrapping is turned on, I am afraid you are about to be highly disappointed. Beacuse Vim _literally cannot do that_. There's a [public and well-known patch][retracile] that you can apply to the Vim sourcetree and then compile your own fork of Vim if you want that feature. Of course, even if you do that, the patch is broken in several ways that are also well-known, which is why it's not part of mainstream Vim. Good luck with that.


In conclusion, Vim is a terrible editor, but it makes me less angry than all the other editors, so I'm still using it full time. Yay?



[github]: https://github.com/ConradIrwin/pry-rescue
[pragprog]: http://pragprog.com/book/dnvim/practical-vim
[retracile]: https://retracile.net/wiki/VimBreakIndent
[twitter]: https://twitter.com/mislav
[twitter 2]: http://twitter.com/lmarburger
[twitter 3]: http://twitter.com/hone02
[twitter 4]: http://twitter.com/tpope
[twitter 5]: http://twitter.com/indirect
[uniqpath]: http://mislav.uniqpath.com/2011/12/vim-revisited/
[vim-adventures]: http://vim-adventures.com/
[vimcasts]: http://vimcasts.org/
