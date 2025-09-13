+++
title = 'Adventures in CPU contention'
slug = 'adventures-in-cpu-contention'
date = 2025-09-21T10:00:00-07:00
+++

Recently on this blog, I wrote about [in-memory filesystems in Rust](/2025/08/18/in-memory-filesystems-in-rust/), and concluded that I wasn't able to detect a difference between any form of in-memory filesystem and using a regular SSD on macOS. I also asked anyone who found a counterexample to please let me know.

Last week, [David Barsky](https://davidbarsky.com) of [ERSC](https://esrc.io) sent me an extremely compelling counter-example, and I spent several days running benchmarks to understand it better.

The top level summary is that the test suite for the [jj VCS](http://github.com/jj-vcs/jj/) exhibits an absolutely fucking huge difference between running on an SSD and running against a ramdisk. In my first reproduction attempt, I found the SSD took 239 seconds, while the ramdisk took just 37 seconds. That's bananas! How was that even possible?

It seems like the key is having so many tests that you occupy all of the CPU cores at the same time. The `cargo nextest run` command will (by default) run one test binary on every core available on the machine. Adding more cores is supposed to make tests run faster, right? Since it seemed like I was getting inconsistent results, I eventually used `hyperfine` to systematically run the entire test suite 10 times using 1 core, 2 cores, 3 cores, 4 cores, etc, all the way up to the full 32 cores I have available in my M3 Ultra testing box.

What I discovered will amaze, distress, and astound you. Probably. 
