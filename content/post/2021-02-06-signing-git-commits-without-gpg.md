---
date: "2021-02-06T00:00:00Z"
title: signing git commits without gpg
---
Given the [”incredibly perfect heap overflow”](https://twitter.com/FiloSottile/status/1355225801172660224) in gpg that [dropped this week](https://dev.gnupg.org/T5275), it seems worthwhile to write up my strategy for signing git commits.

My strategy for securely signing git commits goes like this:

1. [Stop using encrypted email](https://latacora.micro.blog/2020/02/19/stop-using-encrypted.html)
2. Don’t let gpg touch your secret keys
3. Don’t even install gpg onto your machine

It's sad that the perfectly encrypted cyberpunk utopia we were promised devolved into user-hostile systems [full of exploitable bugs](https://gist.github.com/rjhansen/67ab921ffb4084c865b3618d6955275f), but that's what we have. We can do infinitely better by realistically acknowledging how computers (and people!) actually work.

With that disappointing but honest admission out of the way, let’s do this!

**Step 1** Install [boats' privacy barricade](https://github.com/withoutboats/bpb/).

    brew install indirect/tap/bpb

The `bpb` project is written in Rust by [@withoutboats](https://twitter.com/withoutboats), a long-time member of the Rust programming language design team. It contains just enough code to generate a private key and use it to sign git commits, and doesn’t do anything else.

Because I am lazy, I don’t want to have to check out a repository and build a binary every time I set up a new machine, so I packaged up binaries for Intel and Apple Silicon Macs running Big Sur and made them available via my Homebrew tap. Feel free to check out the [homebrew formula](https://github.com/indirect/homebrew-tap/blob/master/Formula/bpb.rb) and [release tarballs](https://github.com/indirect/homebrew-tap/releases/tag/bpb-v1.2.0) if you’re interested.

**Step 2** Generate a new secret key.

    bpb init "André Arko <andre@arko.net>"

You probably want the userid associated with the key to match your git configuration, but as far as I know it doesn’t actually matter what you use. I just make it exactly the same as my git name/email config.

**Step 3** Test `bpb` to make sure it’s able to sign things.

If your setup worked, you’ll be able to use the `bpb` command to sign things via stdin. You can check to make sure by running something like this:

    $ echo "hello" | bpb --sign

If it worked, you’ll see a PGP-formatted signature as the output. Here’s the output when I run the example above:

```plain
[GNUPG:] SIG_CREATED 
-----BEGIN PGP SIGNATURE-----

iQB1BAAWCAAdFiEE7U7DQTZs3fUOkr3Au+UhJSudFWoFAmAfBiAACgkQu+UhJSudFWoDRAD+OuSWJzN2FWemZKrlQgZ4rcp6YfjxhKsqfUrnn8M06gEA/2eqNf7/J3JPvSfEfVA44xVOOfni7utAa/+sP1CdbwsG
=BZb0
-----END PGP SIGNATURE-----
```

**Step 4** Configure `git` to automatically sign commits using `bpb`.

Now the important part, making sure `git` will use `bpb` to sign your commits.  I use three git configuration settings to produce the signature setup that I want. Here’s the relevant section of my `.gitconfig`:

```plain
[gpg]
program = bpb
[commit]
gpgSign = true
[tag]
forceSignAnnotated = true
```

Depending on how your `$PATH` is set up, you might need to give the full path to `bpb`. If you installed `bpb` via my Homebrew tap, that full path will be `/usr/local/bin/bpb` on Intel Macs, and `/opt/homebrew/bin/bpb` on Apple Silicon Macs.

Setting `gpgSign` to true means that git will automatically try to sign any commit you make, and setting `forceSignAnnotated` to true means that git will automatically sign any tags you create that have annotations, which I find is usually what I want.

I have one more bit of useful git config, an alias named `sign`. It will re-create all the commits in my current branch (by rebasing against the repo’s main branch), and sign every commit on the way.

```gitconfig
[alias]
sign = "!f() { git rebase \"${1:-$((git branch | egrep 'main|master|development|latest|release' || echo 'master') | sed 's|* |origin/|' | awk '{print $1}')}\" --exec 'git commit --amend --no-edit -n -S'; }; f"
```

If the signatures on my commits are somehow wrong or missing, running `git sign` and force-pushing is a quick way to clean things up.

**Step 5** Tell GitHub about your new signing key.

Now that you have working git commit signatures, you probably want to tell GitHub that this new key you’re using belongs to your account. The entire reason you’re doing all this work is to get those little green “Verified” bubbles on your commits on GitHub, right?

Copy your public key to the clipboard by running `bpb print | pbcopy`, and then navigate to [your GitHub settings page to add a GPG key](https://github.com/settings/gpg/new). Paste your public key into the box and hit the “Add GPG Key” button.

Now you have signed and verified git commits, without involving `gpg`. Congrats! 🎉

**Step 6 (optional)** Use gpg how to verify your signed commits.

If you want to verify your own signed commits, just to know that it's working, or to debug an issue with GitHub's signature verification, you'll need to use `gpg`. Sorry. 😞
(Feel free to uninstall `gpg` when you're done!) There are three steps:

1. Import the public key into `gpg`

        bpb print | gpg --import

2. Tell `gpg` to give the key ultimate trust

        gpg --list-keys --fingerprint --with-colons | \
        sed -E -n -e 's/^fpr:::::::::([0-9A-F]+):$/\1:6:/p' | \
        gpg --import-ownertrust

3. Check the signatures on your commits with `git log`

        git log --date=relative --pretty='format:%C(yellow)%h%C(reset) %G? %C(blue)%>(14,trunc)%ad %C(green)%<(19)%aN%C(reset)%s%C(red)% gD% D'

The `%G?` bit is the signature check, printed into the second column after the commit sha. According to the man page it will
> show "G" for a good (valid) signature, "B" for a bad signature, "U" for a good signature with unknown validity, "X" for a good signature that has expired, "Y" for a good signature made by an expired key, "R" for a good signature made by a revoked key, "E" if the signature cannot be checked (e.g. missing key) and "N" for no signature

**Step 7 (optional)** Move your actual secret key out of your dotfiles and into the macOS Keychain.

If you’re like me, you might keep your dotfiles in [a public git repository](https://github.com/indirect/dotfiles). If your dotfiles are public, this new configuration file with a PGP key in it is a problem. You can’t commit the file and publish your secret key, but you want to have a single secret key that you share across whatever machines you happen to be working on.

Happily, `bpb` has a solution for you! The config file supports replacing the secret with a program that `bpb` can run to get the secret, instead. On macOS, the easiest candidate for this is the `security` command, which can fetch secrets from the macOS Keychain.

To set this up, open the Keychain Access application, and choose "New Password Item" from the "File" menu. Enter "bpb key" as the "Keychain Item Name", and paste the secret from `~/.bpb_keys.toml` into the "Password" field.

Next, create a new bash script that can fetch the secret from the keychain. Mine is lives in my PATH with the name `bpb-key`, with contents like this:

    #!/bin/bash
    /usr/bin/security find-generic-password -l 'bpb key' -w | tr -d '\n'

Finally, edit `~/.bpb_keys.toml` to invoke the script anytime it needs access to the secret. Here's what mine looks like.

    ❯ cat ~/.bpb_keys.toml
    [public]
    key = "5373b1ccc46af267b8e7dab5392eecdea13de78b03e5cb21e2f956d891b20939"
    userid = "André Arko <andre@arko.net>"
    timestamp = 1534364503
    [secret]
    program = "bpb-key"

Test `bpb` to make sure that it still works by running `echo "test" | bpb --sign`, and you're all set!

**Step 8 (optional)** Copy your secret key into iCloud Keychain or 1Password

Now that you have all of that set up, it would be really great if there was some way to automatically copy that secret onto new machines, wouldn't it?

I was really hoping that iCloud Keychain would be the secret ingredient here, and I would have access to my bpb key on every machine as long as I had iCloud Keychain syncing turned on.

Unfortunately, iCloud Keychain is a completely different thing from regular macOS keychains, and the `security` program can't interact with iCloud Keychains at all. 😞

The least-bad thing I have figured out how to do is to manually copy the secret into the iCloud Keychain, so that new machines can be set up by manually copying from iCloud Keychain into the macOS Keychain for `security` to read.

If you have any better ideas, [let me know!](mailto:andre+bpb@arko.net)
