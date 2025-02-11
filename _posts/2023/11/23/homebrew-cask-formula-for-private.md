---
layout: post
title: "Homebrew cask formula for private GitHub repo releases"
microblog: false
guid: http://indirect-test.micro.blog/2023/11/24/homebrew-cask-formula-for-private/
post_id: 4971993
date: 2023-11-23T16:00:00-0800
lastmod: 2023-11-23T16:00:00-0800
type: post
url: /2023/11/23/homebrew-cask-formula-for-private/
---
I try to use [my dotfiles](https://github.com/indirect/dotfiles) to install software for myself, mainly via [Homebrew](https://brew.sh). This week, I ran into a new automation problem: I wanted to start using a program only available from a private GitHub repo, which requires authentication for downloads. To make things worse, new versions release frequently, so I can't use a static link to the GitHub Release entry's asset download link.

I ended up doing a bunch of experimenting and searching, and I initially found [several](https://blog.devgenius.io/create-homebrew-taps-for-private-github-repos-44daf2f4cff8) [posts](https://gist.github.com/minamijoyo/3d8aa79085369efb79964ba45e24bb0e) [about](https://dev.to/jhot/homebrew-and-private-github-repositories-1dfh) private GitHub repos, mostly centered around the idea of setting a special environment variable with a GitHub API token and then writing a custom Homebrew download strategy class.

I didn't want to have to keep track of another env var with another GitHub token, and I didn't want to have to maintain a custom download strategy class, so I kept looking. Eventually, I hit on [this pull request to Homebrew itself](https://github.com/Homebrew/brew/issues/15590) from a few months ago, adding support for setting HTTP headers needed to download private repo release assets.

Unfortunately, the example in that PR had exactly the problem I mentioned, using a static URL containing a GitHub release. After carefully re-reading the Homebrew docs about creating casks, and then reading the source code of the class that powers the `url` stanza, I was finally able to craft something that works.

In my particular case, the important bit was figuring out how to look up GitHub releases by tag name (since this repo keeps the same tag name for all releases), and then look up one specific asset on that release by filename, to get the correct archive for my OS.

Putting it all together, here's the formula I wound up with that requires no special environment variable, and requires no special download strategy, just uses the options built into Homebrew already, with commentary about each part:

```ruby
cask "appname" do
  # Use :latest to tell homebrew that this will always return the newest version, and there isn't a specific version number available.
  version :latest
  # Use :no_check to tell Homebrew that it can't know the checksum in advance, and so it should not try to validate the checksum of the downloaded archive.
  sha256 :no_check

  desc "some info"
  hompage "https://github.com/username/appname"
  # If there's no arguments and only a block, Homebrew will wait to run the block until it actually needs the URL to download the file at install-time.
  url do
    # Homebrew has a built-in GitHub API client, conveniently able to provide the list of releases, converted from JSON to Ruby hashes.
    assets = GitHub.get_release("username", "reponame", "tagname").fetch("assets")
    latest = assets.find{|a| a["name"] == "appname-macos-universal.zip" }.fetch("url")
    # The return value must match the arguments for the non-block version of `url`, first a URL, and then an options hash. The `header` option can take an array if you need to provide more than one header.
    [latest, header: [
      # The GitHub API will return the binary content of an asset instead of JSON data about that asset if you set the Accept header to application/octet-stream.
      "Accept: application/octet-stream",
      # Homebrew also has a built-in helper that will return GitHub credentials, checking the keychain, config files, gh CLI tool, and other locations automatically. We can re-use those same credentials that Homebrew uses to make API requests for our own download by setting this header.
      "Authorization: bearer #{GitHub::API.credentials}"
    ]]
  end

  app "appname.app"
end
```

I hope that helps anyone with a similar problem! At this point I'm just writing this down so that I can find this blog post later when I forget about it and need to create a formula for another private repo. 😅
