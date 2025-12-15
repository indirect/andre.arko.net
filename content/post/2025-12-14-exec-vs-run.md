+++
title = 'Why are <code>exec</code> and <code>run</code> so confusing?'
slug = 'exec-vs-run'
date = 2025-12-14T21:20:10-08:00
canonical = 'https://spinel.coop/news/exec-vs-run/'
+++

<small>Originally posted [on the Spinel blog](https://spinel.coop/news/exec-vs-run/).</small>

While working on [rv](https://rv.dev), there's a specific question that has come up over and over again, in many different forms. In the simplest possible form, it boils down to:

> What is the difference between `rv exec` and `rv run`? Why have both?

We haven't finished implementing either `rv exec` or `rv run` yet, but every time one or the other comes up in a conversation, everything instantly becomes more confusing.

This post will summarize the history of `exec` and `run` in Bundler, npm, Cargo, and uv. Once we have the history laid out, we can take a look at what we plan to do in rv, and you can [give us your feedback](https://github.com/spinel-coop/rv/discussions/235).

## Bundler `exec`

Bundler manages project-specific packages, but not generally available "global" commands. Project-specific packages installed with Bundler can include their own commands.

While working on Bundler 1.0, we needed a standard way to do something new: run commands completely scoped inside a project, rather than scoped to the entire Ruby installation on the current machine. We tried both a wrapper command (`bundle exec COMMAND`) and generating dedicated scripts in the project's `bin/` directory. With binstubs, you could run `bin/rake` to get the project rake, and `rake` to get the global rake.

I personally preferred the binstub approach, but it was `bundle exec` that ultimately became the popular way to use commands inside your project. My theory is that it won because you can use it to run any command, including `ruby`, or `bash`, or anything else you want.

## RubyGems `exec`

Somewhat confusingly (inspired by the `npm exec` command explained below) there is a separate `gem exec` command that is not related to Bundler and instead installs and runs a command from a package. RubyGems only manages global packages and commands, so `gem exec` is more of a convenience to make it easier to globally install and run a package with just one command.

## npm `run` and `exec`

npm manages both project-specific and global packages, and can install any package so its commands are available either only within a project or globally across every project that uses the same version of Node.

The project-focused design of npm expects commands from project packages to be run by first adding the command to `package.json` in the `script` section, and the run via `npm run SCRIPT`. This is even more inconvenient than Bundler's binstubs, and so I think there was pent-up demand to be able to "just run a command directly". That was eventually provided by `npm exec` and its alias `npx`.

The `npx COMMAND` setup makes it very easy to run any command, whether the package is in the local project or not, whether a script is set up or not, and even whether the package is installed at all or not. Simply running the command is enough to install the needed package and run its command.

It's especially helpful to have `npx` available when you need to create a new project by running an npm package, since it's a huge pain to create a project and install a package and set up a script just so you can run the package to overwrite your project. The most popular example of this I am aware of is `npx create-react-app`, but it's a popular idiom for many packages that contain commands.

## Cargo `run` and `install`

Cargo is simalarly a package manager, but unlike Ruby and Node, project-level packages do not include commands, and package commands are installed globally. Library packages are added to a project with `cargo add`, while command packages are installed globally with `cargo install`. Once a package is installed globally, it can simply be available on your `$PATH`, and Cargo no longer has to be involved in running it.

The `cargo run` command is extremely limited in scope, and only allows you to build and run a binary created by your own project -- it does not work to run commands from packages, either project-local or global.

## uv `exec` and `run`

In uv, the `exec` command seems to be most strongly inspired by `npm exec`, including having its own short alias of `uvx`. The `uv exec` command is exclusively for running commands directly from packages, automatically installing them if necessary. To give an example, that means you can use `uv exec github-backup` to install and run the github-backup command from the Python package named github-backup, whether or not that packge is included in your current project.

Conversely, the `uv run` command is closer to `bundle exec`: it installs and configures Python, installs project packages if inside a project, and then runs a command from `$PATH` or runs a file. That means `uv run` can be used for both `uv run bash` to get a shell with only your project's Python and packages, and can also be used as `uv run myscript.py` to run a script file directly.

## Summary

`bundle exec` runs:
- commands created by your package
- commands from project packages (like `bundle exec rails`)
- commands from $PATH (like `bundle exec bash`)
- scripts from files (like `bundle exec ./myscript.rb`)

`npm run` runs:
- project-defined script commands (like `npm run my-project-script`), which can call:
  - commands from project packages (like `generate_pdf.js`)
  - commands from $PATH (like `bash`)
  - scripts from files (like `./myscript.js`)

`npm exec` installs and runs:
- non-project commands from any package (like `npx create-react app`)

`cargo run` builds and runs:
- commands created by your package

`uv run` installs python and any project packages, then runs:
- commands from project packages (like `uv run datasette`)
- commands from $PATH (like `uv run python`)
- scripts from files (like `uv run ./myscript.py`)
- project-defined script commands (like `uv run my-project-script`), which can call:
  - commands from project packages (like `github-backup`)
  - commands from $PATH (like `bash`)
  - scripts from files (like `./myscript.py`)

`uv exec` installs python and the named package, then runs:
- non-project commands from any package (like `uv exec github-backup`)

## The question for `rv`

With all of that background now set up, what should `rv exec` do? What should `rv run` do?

To be the most like Bundler, we should use `rv exec` to run commands for a project. To be the most like `npm` and `uv`, we should use `rv exec` to install and run a single package with a command.

Today, we're leaning towards an option that includes all of the useful functionality from every command above, and aligns Ruby tooling with JS tooling and Python tooling:

`rv run` installs ruby and any project packages, then runs:
- commands from project packages (like `rv run rspec`)
- commands from $PATH (like `rv run bash`)
- scripts from files (like `rv run ./myscript.rb`)
- project-defined script commands (like `rv run my-project-script`), which can call:
  - commands from project packages (like `rspec`)
  - commands from $PATH (like `bash`)
  - scripts from files (like `./myscript.rb`)

`rv exec` installs ruby and the named package, then runs:
- non-project commands from any package (like `rv exec rails`)

If we try to combine those two commands into one command, we quickly run into the ambiguity that has been so frustrating to handle in Bundler for all of these years: if you `rv run rake`, do you want the global rake package? Or do you want the project-local rake package? How can we know which you want?

In my opinion, `uv` solves this relatively elegantly by having `uvx` always run a package globally, and `uvr` always run a package locally inside the current project, if one exists.

What do you think? [Let us know in the GitHub discussion about this post.](https://github.com/spinel-coop/rv/discussions/235)
