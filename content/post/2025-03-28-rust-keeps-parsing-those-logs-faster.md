---
date: '2025-03-28T20:56:06Z'
created_at: '2025-03-28T20:56:06Z'
updated_at: '2025-03-28T20:56:06Z'
title: Rust keeps parsing those logs faster
slug: rust-keeps-parsing-those-logs-faster
---
A few years ago, I [wrote about parsing logs 230x faster with Rust](/2018/10/25/parsing-logs-230x-faster-with-rust/), and then [followed up with some improvements](/2019/01/11/parsing-logs-faster-with-rust-continued/). Then [computers got a lot faster](/2022/03/13/parsing-logs-faster-with-rust-revisited/).

Today, I re-ran all the same benchmarks that I’ve been running since 2018, and discovered that computers in 2025 are a silly amount faster than computers from 2021.

Specifically, on a MacBook Pro with an M4 Max processor (which has 12 performance cores and 4 efficiency cores), I am now able to process 983k records/second on a single core, and 13.1M r/s on all cores. Using the original numbers from the “230x faster” blog post, this M4 Max is 3,113x faster than the original 8 Python workers in AWS Glue were.

While talking about these benchmarks with some friends, I managed to accidentally nerdsnipe someone who both [actually knows how to profile Rust code](https://github.com/rubytogether/kirby/pull/37) and has a [stupid powerful CPU](https://www.amd.com/en/products/processors/desktops/ryzen/9000-series/amd-ryzen-9-9950x.html). Once the mutexes I accidentally put around the regexes at the core of this parser were gone, it was about 55% faster than it had been before.

On top of that, they also noticed that we could [use the Rust version of zlib instead of the C version](https://github.com/rubytogether/kirby/pull/38). While that seemed like a wash on Apple CPUs, that change added another 15% speed bump on x86, which is where we run this parser in production.

In the end, it turns out on a Ryzen 9 9950X, just one core can process 1.24M r/s, and all 32 hyperthreads working together can process 22.56M r/s. For those keeping score at home, that adds up to a final result of 5,371x faster.

I truly couldn’t believe how fast it was in 2017 when my machine first processed the an entire gigabyte of logs in just 8 seconds, and today this project can process the same log file in just _800 milliseconds_. Based on that, I’m very excited about ten years from now, when I expect I’ll be able to process the same file in 80ms. 😆
