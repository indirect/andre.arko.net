+++
title = 'Adventures in CPU contention'
slug = 'adventures-in-cpu-contention'
date = 2025-09-23T10:00:00-07:00
+++

Recently on this blog, I wrote about [in-memory filesystems in Rust](/2025/08/18/in-memory-filesystems-in-rust/), and concluded that I wasn't able to detect a difference between any form of in-memory filesystem and using a regular SSD on macOS. I also asked anyone who found a counterexample to please let me know.

Last week, [David Barsky](https://davidbarsky.com) of [ERSC](https://esrc.io) sent me an extremely compelling counter-example, and I spent several days running benchmarks to understand it better.

The top level summary is that the test suite for the [jj VCS](http://github.com/jj-vcs/jj/) exhibits an absolutely huge difference between running on an SSD and running against a ramdisk. In my first reproduction attempt, I found the SSD took 239 seconds, while the ramdisk took just 37 seconds. That's bananas! How was that even possible?

What I discovered will amaze, distress, and astound you. Probably.

First, the context. The jj project recently shipped a change to [always use `fdatasync()`](https://github.com/jj-vcs/jj/pull/7375) when persisting a temporary file. My understanding is that this change was made to prevent certain kinds of bad data being written.

After adding more calls to `fdatasync()`, which is a variation of `fsync()`, contributors to jj noticed that the tests ran about the same speed on linux, but dramatically slower on macOS. This eventually produced a pull request [suggesting a ramdisk for tests on macOS](https://github.com/jj-vcs/jj/pull/7493), noting that it was much faster.

This situation intrigued me—how much faster was it? And why? At the highest level, there is an explanation that makes sense to me: testing `fdatasync()` causes a huge difference between physical disks and RAM, because it breaks through the filesystem cache in memory, and forces slow disk writes before returning.

But then I actually tested the suggested change on two different machines, and what I was seeing didn’t make any sense. I had access to two different Macs for testing: one M4 Max with 16 CPU cores, and one M3 Ultra with 32 CPU cores.

When I tried SSD vs RAM on 16 cores, the difference was huge. When I tried SSD vs RAM on 32 cores, the difference was… much smaller. That’s confusing. The `cargo nextest run` command will (by default) run one test binary on every core available on the machine. Why would running the tests on more cores make the tests slower?

Since it seemed like I was getting inconsistent results, I eventually used `hyperfine` to systematically run the entire test suite 10 times using 1 core, 2 cores, 3 cores, 4 cores, etc, all the way up to the full 32 cores in my M3 Ultra testing box.

The results I saw for using the SSD made sense, mostly. Adding more cores made the tests run faster… up to about 4 cores. Cores 5 to 32, on the other hand, don’t seem to do anything at all. From the outside, that makes it look like the APFS filesystem on the SSD has some kind of mutex or lock that really only allows 4 cores to actually run at the same time. Running similar tests on the M4 Max produced similar results—APFS on SSD seems to test faster up to about 4 cores, and then get stuck there no matter how many more cores you add.

Where things started to get weird was using tmpfs on a ramdisk. On the M4 Max things went roughly how you might expect, with each additional core decreasing the overall runtime but with diminishing returns. The full test suite on one core takes about 327 seconds, and with 16 cores takes about 37 seconds. 15 cores is just a hair slower at 38, and so on.

On the M3 Ultra, though, using a ramdisk and testing from 1 to 32 cores produced _worse_ results for every core added beyond the 12th. I’ve [created a gist with raw benchmark output](https://gist.github.com/indirect/c3d911b093ecab55dc96ebaaef7b1adb), but you can see the summary chart below.

![a chart showing SSD and ramdisk test suite times](jj-test-bench.png)

Whatever is going on with the jj test suite and the ramdisk creates so much contention that 32 cores will all run full out at 100% while taking 3x longer than 12 cores running at 100%.

That’s pretty wild! In the end, it doesn’t seem to be a story about in-memory filesystems exactly. Instead, it’s about some kind livelock contention between the running cores and some shared, limited resource. I’m not sure if that resource is memory itself, some shared CPU cache, the IO bus, or what. But it sure is dramatic.
