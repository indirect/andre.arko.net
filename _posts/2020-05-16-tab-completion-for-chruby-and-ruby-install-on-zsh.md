---
layout: post
title: Tab completion for chruby and ruby-install on zsh

---
I switched to zsh as part of upgrading to macOS 10.15 Catalina. I'm not using oh-my-zsh, but I was _incredibly_ helped by the [Scripting OSX series](https://scriptingosx.com/2019/06/moving-to-zsh/), and my new best friend is [Powerlevel10k](https://github.com/romkatv/powerlevel10k).

Anyway, now that you're caught up, my problem of the day is wanting tab-completion for my other best friends: `chruby` and `ruby-install`. There's a bunch of tab-completion options for `chruby` rattling around in GitHub issues and pull requests, but none of them were easy enough to find. I eventually wound up extracting one from [oh-my-zsh's chruby plugin](https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/chruby/chruby.plugin.zsh), which does _way_ more than I wanted. Here's the whole thing, which I keep in `~/.zsh/completion/_chruby`:

```zsh
#compdef chruby

compadd $(chruby | tr -d '* ')
local default_path='/usr/local/bin:/usr/bin'
if PATH=${default_path} type ruby &> /dev/null; then
  compadd system
fi
```

Once I had `chruby` working, I wanted tab-completion for `ruby-install`. I figured I could also extract that from oh-my-zsh, but... it's listed as a TODO. :/ So I wrote my own! As far as I can tell from my scatterbrained googling, this is literally the first zsh completion for ruby-install to ever be posted on the internet. Yay me? I keep this in (predictably) `~/.zsh/completion/_ruby-install`.

```zsh
#compdef ruby-install

compadd $(ruby-install | tail -n+2 | ruby -e '
ARGF.read.lines.each do |l|
  next @name = l.tr(":", "").strip if l.include?(":")
  puts "#{@name}-#{l.strip}"
end
')
```

(I know, I know, macOS won't ship with a built-in Ruby starting with 10.16 or 10.17, and this will break then. I just don't have the patience to rewrite it as a zsh script today.)

To include and activate these, you need something like this in your `~/.zshrc`:

```zsh
fpath+=~/.zsh/completion
autoload -Uz compinit && compinit
```

And that's it! Tab complete your way to happiness:

```
$ chruby ⇤
ruby-2.6.6  ruby-2.7.1  system

$ ruby-install ⇤
jruby-9.2.11.1  rbx-4.15  ruby-2.5.8  ruby-2.7.1  mruby-2.1.0  ruby-2.4.10  ruby-2.6.6  truffleruby-20.0.0  
```