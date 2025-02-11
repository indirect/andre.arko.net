---
layout: post
title: "The New Rubygems Index Format"
microblog: false
guid: http://indirect-test.micro.blog/2014/03/28/the-new-rubygems-index-format/
post_id: 4971614
date: 2014-03-27T16:00:00-0800
lastmod: 2014-03-27T16:00:00-0800
type: post
url: /2014/03/27/the-new-rubygems-index-format/
---
This post is a part news, part technical documentation, and part request for comment. I'm going to explain the technical nitty-gritty details of the planned next generation index that allows Bundler and Rubygems to know what gems exist and how to install them.

The current index is a mishmash of different files that were created at different times to serve different needs. I'll walk you through the reasons that each of the current index files exists, and then explain how the new index plans to handle all those needs at the same time, in a simple and fast way.

In the beginning was `Marshal.4.8.gz`. It wasn't actually 4.8, because that's the current version of Ruby's marshalling format, but it was certainly marshalled and gzipped. It contains an array of every `Gem::Specification` object for every gem that exists. As you might expect, that file is pretty big now that we have almost 100,000 gems.

Once that file got big and unweildy, the `specs.4.8.gz` file was introduced. Confusingly, it doesn't actually contain any specs, but is instead an array of smaller arrays. Each smaller array contains the name, version, and platform of a single gem, so one item in that specs array is `["rack", Gem::Version.new("1.0.0"), "ruby"]`. This was much, much faster to download and decompress.

In addition, those three items could be used to download only the gemspec for the single gem that had been given to `gem install`. Those files are YAML serializations of Gem::Specification objects, and are served at URLs like `/specs/rack-1.0.0.gemspec`.

At some later point, Rubygems gained support for "prerelease" versions, which are not installed by default, but must be opted into using `gem install --pre`. A similar marshalled array listing those gems can be found as `prerelease_specs.4.8.gz`. Gemspecs for prerelease versions are downloaded in the same way as regular versions.

Eventually, even `specs.4.8.gz` got too big and unweildy, though, and so `latest_specs.4.8.gz` was added. It contains an array with one entry for the latest non-prerelease version of each gem that exists. Since that array does not grow with each release of each gem, its size has stayed more manageable. However, it's only useful if you are absolutely sure that you want to install the very latest version of a gem, which may or may not contain the code you are expecting.

This is the world that Bundler was born into. Bundler did something new: it started with the latest version of a gem, but would successively try earlier versions of the gem, looking for one that was compatible with the dependencies of every other gem included in the bundle. In order for this to be done in a reasonable amount of time, Bundler was forced to ignore all the "faster" indexes, and just rely on `Marshal.4.8.gz`. That single file contained all the gemspecs, enabling Bundler to check the dependencies of every version that it tried while resolving the Gemfile.

As many people noticed and pointed out, though, this was suuuuper slow. Downloading every single gemspec of every gem ever when the Gemfile only contained Rack was a bit wasteful. On top of that, it could even start swapping on servers with around 128MB of RAM, increasing a minute or two install to ten or twenty minutes. After some discussion with the Rubygems.org team, they suggested a dedicated Bundler API.

The Bundler API is served at `/api/v1/dependenices`, and returns the same array-of-small-arrays format that `specs.4.8.gz` does. But it only includes the gems that are specifically asked for by name. That means that when a Gemfile only includes Rack, Bundler only downloads a list of all the versions of Rack. Using that list, Bundler can then try various versions looking for one that fits the bundle. Then it can download the gemspec of that version to make sure there are no dependency conflicts.

Unfortunately, the Bundler API is much, much more demanding on the server than serving static marshalled files. After six months of Bundler users upgrading to the version that used the API, the server load was simply too much for Rubygems.org to handle, and it went down. The API had to be disabled to bring Rubygems.org back up again. As a result, the Bundler team built a dedicated app, deployed separately from Rubygems.org, that serves nothing but the Bundler API.

While the foundations for the current index files are entirely pragmatic, those files definitely have some shortcomings. They're not security friendly, because they store gemspecs as Ruby marshal or YAML marshal data, which has repeatedly been shown to be vulnerable to various remote exploit scenarios. They're not local-cache friendly, beacuse the entire marshalled file changes if an item is appended to the array. They're not server friendly, because the API requires thousands of dollars per month of server infrastructure just to stay up. They're not Bundler friendly, because even the Bundler API doesn't provide critical information like required Ruby version or required Rubygems version, leading to some `bundle install` commands that seem to succeed, but then explode. They don't contain any checksum information, making it extremely difficult to tell if the downloaded or locally cached copy of a .gem file has been corrupted. They're not high-latency friendly, because the "efficient" Bundler API requires many, many round trip requests to the server that is currently hosted solely in EC2's US-East-1. They're not even low-bandwidth friendly, because the data is requested over and over again, even if it was just sent seconds ago.

The new index tries to address all of these issues. First, it's just plaintext. That saves us from all the YAML and Marshal security concerns right away. It's caching friendly, because the line-based format allows new data to simply be appended at the end of the file. It's local-cache friendly, because the client can download any file once and then simply download new lines that have been appended since the last check. It's server friendly, because it's just flat files that are generated once when a gem is pushed. It's Bundler friendly, because it includes dependency information as well as required Ruby and Rubygems versions. It contains checksums, so that it is trivial to ensure that a local `.gem` file is the correct one before it is used. It's both high-latency and low-bandwidth friendly, by reducing the number of requests needed and the number of bytes downloaded thanks to local caching on each client. Finally, it's still fast: parsing plain text files using `split()` is on par with loading serialized data in our benchmarks.

The new index provides three files: `names`, which is just a plaintext list of the name of every existing gem, one per line. It's not used by anything at present, but could be cached locally to be used for autocomplete or other similar things.
Then there's the main index file, `versions`. That file is simply the name of a gem and a list of each version/platform pair for the gem, comma separated. A simple versions file might look like this:

```
# /versions
rack 0.9.2,1.0.0,1.0.1,1.1.0
sinatra 1.0,1.0.1,1.0.1-jruby,1.1
```

Knowing which versions exist makes it straightforward to dowload the gemspec of the corresponding gem. That's not usually needed, though, thanks to the other files, `/deps/GEM_NAME`. One file per named gem that exists, and each line contains a version and dependency information. A simple deps file might look like this.

```
# /deps/nokogiri
1.1.5 |checksum:abc123
1.1.6 rake:>= 0.7.1,activesupport:= 1.3.1|ruby:> 1.8.7,checksum:bcd234
1.1.7.rc2 rake:>= 0.7.1|ruby:>= 1.8.7,rubygems:> 1.3.1,checksum:cde345
1.1.7.rc3 |rubygems:> 1.3.1,checksum:def456
1.2.0-java mini_portile:~> 0.5.0|checksum:fgh567
```

Using this format, these files can be saved on the client machine the first time they are requested. After that, it is simply a matter of checking for changes using an HTTP etag header, and requesting any missing data using a Range header in the HTTP request. If the `versions` file is already up to date, there are no new versions of any gems, and no further work needs to be done. If there are new gems, the newly pushed versions can be inspected, and the `deps` files for only those gems can be updated as necessary when the bundle is resolved. Ruby version, Rubygems version, and checksums take care of the remaining issues with the Bundler API format.

Now it's time for a confession: I said this was the planned format, but it's already implemented. There is existing code in Bundler and the Bundler API that uses this index format to install gems. It's not terribly optimized yet, but it's working, and it's going to get better as we got closer to releasing it. The Rubygems and Rubygems.org teams have agreed that this format is an improvement for everyone. The Bundler team will lead an integration effort once the client code is complete, and Bundler and Rubygems will share and improve the same index client library.

If you have ideas for how the next-generation Rubygems index format could be even better, let me know on Github at https://github.com/bundler/new-index/issues/new or on Twitter, where I am @indirect. Even better, if you want to help integrate it into Rubygems and Rubygems.org, let me know! It would be great to work together.

<p class="aside">This post was also crossposted to the <a href="https://blog.engineyard.com/2014/new-rubygems-index-format">Engine Yard blog</a>.</p>
