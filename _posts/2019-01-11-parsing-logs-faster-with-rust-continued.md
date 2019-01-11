---
title: "Parsing logs faster with Rust, continued"
layout: post
---

Previously, I [wrote about parsing logs 230x faster using Rust](/2018/10/25/parsing-logs-230x-faster-with-rust/). Since publishing that post, I've discovered some new information! Here's what I've learned.

First, several people argued that that it is unfair to use Python inside Apache Spark as the base case. Either Python or Ruby by itself is capable of processing logs much faster than Python scripts that have to go through the Spark APIs while running in a Hadoop cluster. That's... kind of true. Python or Ruby by itself can manage much more than 525 records/second/cpu. For me, the problem was that I had too many records to process on a single CPU, and needed an automatic way to parallelize the work. AWS Glue was the first thing I stumbled across, so I tried using it.

The next thing I discovered is that I was benchmarking the Rust code completely wrong. Running `time cargo run --release` always invokes the Cargo compilation cycle, which takes a lot of time. Instead, I should have been doing something like `cargo build --release && time ./kirby`. I've resolved that issue by writing [a script to benchmark kirby commits](https://github.com/rubytogether/kirby/blob/main/bin/bench) using the fantastic benchmarking tool (also written in Rust) called [Hyperfine](https://github.com/sharkdp/hyperfine). After removing the overhead from Cargo, I discovered I was wildly underselling how fast the Rust log parser was.

Finally, random people on the internet made a bunch of suggestions after my original post. Most of the suggestions were not super clear wins based on benchmarking, but when all of them were combined the overall result was definitely faster. The two biggest changes were [using CoW strings with Serde](https://github.com/rubytogether/kirby/pull/6) and [reducing backtracking inside the regex](https://github.com/rubytogether/kirby/pull/4).

After combining all of the suggestions, the final result was a pretty dramatic improvement. The [previous code](https://github.com/rubytogether/kirby/commit/2cabdd4cad0038d1bdbb029bf4ded689cfa4e8c2) processed the example log file in 4.001 seconds, but the [latest commit](https://github.com/rubytogether/kirby/commit/1571ff116c4920bea596186b3f1cbbb397af548e) takes just 2.875 seconds. That's a 28% improvement!

After removing the call to Cargo, and applying all of the suggested optimizations, the result is a bit more stark than it was last time:

```
   ~525 records/second/cpu in Python on Apache Spark in AWS Glue
 13,760 records/second/cpu in Ruby
353,374 records/second/cpu in Rust
```

That's a total of 673x faster than the AWS Glue script, and still 25.7x faster than a single-threaded Ruby script. (And the Ruby script is using a JSON library and a Regex library both written in C!).

I've been really impressed with the Rust community, providing not just helpful suggestions but even sending PRs with benchmarks showing the exact improvements for their changes. If you think you can improve things even more, I'd [love to hear from you](https://github.com/rubytogether/kirby/issues/new).
