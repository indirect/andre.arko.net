---
date: "2022-03-13T00:00:00Z"
title: Parsing logs faster with Rust, revisited
---
A few years ago, I [wrote about parsing logs 230x faster with Rust](/2018/10/25/parsing-logs-230x-faster-with-rust/), and then [followed up with some improvements](/2019/01/11/parsing-logs-faster-with-rust-continued/).

Thanks to [a contributor adding IP address deduplication](https://github.com/rubytogether/kirby/pull/20), I've had to update, build, and deploy it again. As a result, I learned some new stuff about: `rustc` inside `qemu`, Rust LTO (link-time optimization) with musl, profile-guided optimizations, and just how fast M1 Max MacBook Pros are.

### `rustc` segfaults in Docker's `qemu`

The (somewhat hacky) AWS Lambda setup I am using predates support for Rust. Instead, I tell AWS it's a Go binary, and then upload a Rust binary. Binaries running in Lambda's "Go" mode need to be compiled against [musl libc](http://musl.libc.org) (probably because Lambda's runtime is built on top of Alpine Linux, but I don't know for sure). Back in 2018, I couldn't figure out how to get Rust to cross-compile from macOS to Linux with musl, so I used a Docker image with a cross-compiler built in.

The first problem I ran into while updating the project was... not having an x86 machine anymore. My M1 Max MacBook Pro is really great, but the Docker image I was using to cross-compile only exists in x86 flavor. (Docker calls it "amd64".)

To run x86 images on the ARM-based M1 Macs, Docker ships a copy of `qemu` inside, to run the container on an emulated x86. Unfortunately, [`rustc` segfaults inside Docker's `qemu`](https://github.com/rust-lang/rust/issues/80346). With no idea how to resolve that almost-two-year-old problem, I gave up and decided to use an old Intel Mac to build the new version, at least for the time being. If I was able to get it working, I figured I could set up GitHub Actions to build it for me or something.

### Rust link-time optimization with musl

Once I had burned a day or two troubleshooting the insurmountable segfault and given up, I ran into a new problem. In 2018, a contributor [enabled LTO for a huge 25% speedup](https://github.com/rubytogether/kirby/commit/74b3d81b0827bd0674eba3ef32cf0223b5756e02). It clearly worked at the time, but it seems  the Docker-based cross-compile had stopped working [by November 2019](https://github.com/rubytogether/kirby/issues/16). As far as I can tell, the problem is exclusive to using both LTO and musl at the same time. Inside the Docker container, LTO works with glibc, and musl works without LTO... but you can't have both together.

Fortunately, Rust cross-compilation has improved a lot in the last few years. Thanks to [macos-cross-toolchains](https://github.com/messense/homebrew-macos-cross-toolchains) and [cross](https://github.com/cross-rs/cross), I was able to ditch the Docker setup entirely and compile for x86 Linux with musl directly from macOS on ARM. (Well, once I got it configured. Which required synthesizing together three separate blog posts, since there's no documentation that explained what I needed.) I'm super impressed that `cross` works so well, and not just from macOS on my laptop but also from Linux on GitHub Actions.

### Profile-guided optimizations

Finally, I learned that even the previously absurd speeds that I was getting can be soundly beaten via modern hardware and compilation techniques.

At [the beginning of 2019](/2019/01/11/parsing-logs-faster-with-rust-continued/), we had made it as far as 353,000 records/second on one CPU core. In 2022, just recompiling and running the test again on an M1 Max MacBook Pro with Rust 1.60 is already a kind of unbelievable improvement: 550,000 records/second, a 56% improvement (!). Those Apple hardware engineers really know what they're doing, apparently.

There's another new cool optimization thing that works in Rust now, though: profile-guided optimization. PGO is actually a feature of LLVM that you can enable, compile your program, run it several times to gather profile data, and then compile again while feeding LLVM the profile data that you collected. [The PGO docs from Rust](https://doc.rust-lang.org/rustc/profile-guided-optimization.html) are quite readable, and I was able to [copy and paste the example into my build script](https://github.com/rubytogether/kirby/blob/main/bin/bench#L15-L31).

With PGO online, the a single M1 core jumped up from 535,000 to 638,000 records/second, another 19% improvement, bringing the total speedup to 76% faster than before.

In terms of "how fast can one whole laptop go", I also benchmarked in multi-file, multi-core mode, maxing out the entire machine. On a 2018 Intel MacBook Pro, the fastest possible speed was 1.1 million records/second. On the 2022 M1 MacBook Pro, it was 3.2 million, and adding profile-guided optimization brought it up to 3.6 million. That's a 3.3x speedup, and I didn't even make any changes to the program. 🤯

Rust (and Apple Silicon) continues to impress.
