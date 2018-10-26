---
title: "Parsing logs 230x faster with Rust"
layout: post
---

Perhaps surprisingly, one of the most challenging things about operating [RubyGems.org](https://rubygems.org) is the logs. Unlike most Rails applications, RubyGems sees between 4,000 and 25,000 requests per second, all day long, every single day. As you can probably imagine, this creates... a lot of logs. A single day of request logs is usually around 500 gigabytes on disk. We've tried some hosted logging products, but at our volume they can typically only offer us a retention measured in hours.

About a year ago, the only thing I could think of to do with the full log firehose was to run it through `gzip -9` and then drop it in S3. With gzip, the files shrink by about 92%, and with S3's "infrequent access" and "less duplication" tiers, it's actually affordable to keep those logs in a bucket: each month worth of logs costs about $3.50 per month to store.

Buried in those logs, there are a bunch of stats that I'm super interested in: what versions of Ruby and Bundler are actively using RubyGems.org, or per-version and per-day gem download counts. Unfortunately, gzipped JSON streams in S3 are super hard to query for data.

### is this... big data?

So every day, we generate about 500 files that are 85MB on disk, and contain about a million streaming JSON objects that take up 1GB when uncompressed. What we want out of those files is incredibly tiny—a few thousand integers, labelled with names and version numbers. For example, "2018-10-25 Bundler 1.16.2 123456", or "2018-10-25 platform x86\_64-darwin17 9876".

With a full set of those counts, we would be able provide seriously useful information about the state of the whole Ruby ecosystem. It would help gem authors to know what versions of Ruby are important to support, and help everyone using Ruby to know whether or not they are upgrading in pace with the majority of other Ruby devs.

### the slow way

Without any real idea of how to get those counts out of S3, I started by writing a proof of concept Ruby script that could parse one of the 500 log files and print out stats from it. It proved that the logs did contain the data I wanted, but it also took a _really long time_. Even on my super-fast laptop, my prototype script would take more than 16 hours to parse 24 hours worth of logs.

If I was going to make this work, I would need to figure out some way to massively parallelize the work. After setting it aside for a while, I noticed that AWS had just announced [Glue](https://aws.amazon.com/glue/), their managed Hadoop cluster that runs Apache Spark scripts.

### python and glue

Starting from zero experience with Glue, Hadoop, or Spark, I was able to rewrite my Ruby prototype and extend it to collect more complete statistics in Python for Spark, running directly against the S3 bucket of logs. With 100 parallel workers, it took 3 wall-clock hours to parse a full day worth of logs and consolidate the results.

While 3 realtime hours is pretty great, my script must have been very bad, because it was using 300 cpu-hours per day of logs, an average of 36 minutes per log file. That worked out to almost $1,000 per month, which was too much for Glue to work as a permanent solution.

### maybe rust?

After shelving the problem again, I thought of it while idly wondering if there was anything that I'd like to use [Rust](https://www.rust-lang.org/en-US/) for. I'd heard good things about [fast JSON](https://github.com/serde-rs/json-benchmark#-cargo-run---release---bin-json-benchmark) and [fast text search](https://blog.burntsushi.net/ripgrep/) in Rust, so it seemed like it might be a good fit.

It turns out [`serde`](https://serde.rs), the Rust JSON library, is  super fast. It tries very hard to not allocate, and it can deserialize the (uncompressed) 1GB of JSON into Rust structs in 2 seconds flat.

Impressed by how fast Rust was at JSON, I searched for "rust parsing" and found [`nom`](https://github.com/Geal/nom), a parser combinator library. After a few nights of work, I had a working parser combinator that did what I wanted, and I used it to parse the same log files. Excitingly, it could parse a 1GB logfile in just 3 minutes, which felt like a huge win coming from ~30 minutes in Python on Glue.

While wondering if there was a way to make it faster, I started re-reading the `nom` docs carefully, and that's when I noticed that "sometimes, `nom` can be almost as fast as `regex`". 🤦🏻‍♂️ Feeling pretty silly, I went and rewrote my rust program to use the [`regex`](https://github.com/rust-lang/regex#regex) crate, and sure enough it got 3x faster. Down to 60 seconds per file, or 30x as fast as Python in Spark in Glue. Even 2x faster than the Ruby prototype! (Though that comparison isn't very fair because the Python and Rust versions collect more data.)

At that point, I excitedly shared how fast my Rust version was with [@reinh](https://twitter.com/reinh)... and his response was "WHY IS IT SO SLOW YOU MUST PROFILE IT". I'm still not sure how much of that was a joke, since it was already 30x faster than my last version. But I was curious, so I started looking into how to profile programs in Rust.

### release mode

The first thing I learned about profiling programs in Rust is that you have to do it with compiler optimizations turned on. Which I was not doing. 🤯 Rerunning the exact same Rust program while passing the `--release` flag to `cargo` turned on compiler optimizations, and suddenly I could parse a 1GB log file in... **8 seconds**.


So, to recap, here's a table of processing speeds:

```
   ~525 records/second/cpu in Python on AWS Glue
 50,534 records/second/cpu in Rust with nom
121,153 records/second/cpu in Rust with regex
```

### thanks, rayon. thayon.

At that point, I remembered that Rust also has a [parallel iteration library, Rayon](https://github.com/rayon-rs/rayon). With a 5 character change to my program, Rayon ran the program against multiple log files at the same time. I was able to use all 8 cores on my laptop, and go even faster:

```
 ~4,200 records/second in Python with 8 worker instances on AWS Glue
399,300 records/second in Rust with 8 cores and rayon on a MacBook Pro
```

While workers on Glue seem to scale linearly, that definitely wasn't the case on my laptop. Even with 8x the cores, I only got a 3.3x speedup. It's not a super fair comparison since the code is running on different machines, but it's 100x faster with 8 cores, and 230x faster on one core.

I didn't include it in the table above, beacuse it's sort of cheating, but I was able to go even faster than that. By leaving some JSON fields out of the Rust struct, and skipping some JSON objects if I could tell they had duplicate information, I was able to get the runtime for a 1GB log file down to 6.4 seconds. That's 151,441 records/second/cpu, or 288x faster.

### back to aws

After rewriting my parser in Rust, I had a new problem: how do I deploy this thing? My first idea (which probably would have worked?) was to cross-compile Rust binaries for Heroku and make [Sidekiq](https://sidekiq.org) run the binary once for each new log file in S3.

Fortunately, before I tried to actually do that, I discovered [`rust-aws-lambda`](https://github.com/srijs/rust-aws-lambda), a crate that lets your Rust program run on AWS Lambda by pretending to be a Go binary. As a nice bonus for my usecase, it's only a few clicks to have AWS run a Lambda as a callback every time a new file is added to an S3 bucket.

Between `rust-aws-lambda` and  `docker-lambda`, I was able to port my parser to accept an AWS S3 Event, and output a few lines of JSON with counters in them. From there, I can read those tiny files out of S3 and import the counts into a database. With Rust in Lambda, each 1GB file takes about 23 seconds to download and parse. That's about a 78x speedup compared to each Python Glue worker.

### wait, _how_ much?

As fantastic gravy on top of this whole situation, after a few days I realized that I needed to know exactly how much it would cost. With each log file taking about 23 seconds, and there being about 500 log files per day, it seemed like I would need about 350,000 seconds of Lambda execution time per month.

Then, when I went to look up Lambda pricing, I noticed that it has a free tier: 400,000 seconds per month. So in the end, it seems like I'm parsing 500GB of logs per day... for free. 😆

If you want to read the code, or better yet send me pull requests making it even faster, it lives on GitHub at [rubytogether/kirby](https://github.com/rubytogether/kirby).

<small>Thanks to Steve Klabnik, Ashley Williams, without boats, Rein Henrichs, Coda Hale, Nelson Minar, Chris Dary, Sunah Suh, Tim Kordas, and Larry Marburger for feedback and encouragement to turn our conversations into a post.</small>
