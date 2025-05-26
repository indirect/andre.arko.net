---
date: "2013-03-23T00:00:00Z"
title: Adding arrays in Ruby quickly
---
So... this is quite possibly so esoteric that it's not really going to be useful, but I was curious, even if it doesn't really matter in the end, thanks to modern processor speeds. The other day as I was working on my [silly chat bot](http://github.com/indirect/daneel), I discovered that I had an array in a read-only attribute, and another array that I wanted to merge into the first array. Without a setter, it's not possible to something like `a = a + b`. As I was thinking about that, I realized that all of the `Array` addition operators create a third array to contain the result, and I didn't really want that either. So I looked up all of the `Array` operations that just add an element to the end of an existing array. The two mehtods I found are `#push` and `#<<`. I (maybe) could have also tested `a.insert(item, a.size)`, but I was trying to compare things of roughly equal complexity.

For reasons not entirely clear to me, `<<` only ever takes a single argument, so adding an entire array means looping over the array, passing each element to `<<` one at a time. Push takes more than one argument, but I wasn't sure if it would be faster to pass in a lot of arguments for push to loop over, or just look over them myself. In the end, I decided to test both ways of calling `push`, one to compare the speed of the methods themselves, and one to compare the fastest possible way to add a large number of elements to an array. The results looked like this:

```
            user       system     total       real
push *   339.270000  20.320000 359.590000 (360.085974)
push     501.850000  17.810000 519.660000 (519.570627)
<<       402.900000  16.670000 419.570000 (419.433473)
```

For those of you playing along at home, I've included the [code I used to benchmark each method](#add_arrays.rb) at the end of this post. The results weren't terribly surprising to me, but it does at least confirm that using the `<<` operator isn't the fastest way to add things to an array that already exists. It also confirms that looping over arrays in MRI's C implementation is faster than doing it ourselves in Ruby. So, in the end, it was pretty much just another way of finding out what we already knew. But it's nice to be sure, isn't it?


<p id="add_arrays.rb"></p>

``` ruby
# add_arrays.rb
require 'benchmark'

TIMES = 10_000

Benchmark.bm do |b|
  b.report("push * ") do
    TIMES.times do
      a = (1..100_000).to_a
      a.push(*(100_000..200_000).to_a)
    end
  end

  b.report("push   ") do
    TIMES.times do
      a = (1..100_000).to_a
      (100_000..200_000).each { |n| a.push n }
    end
  end

  b.report("<<     ") do
    TIMES.times do
      a = (1..100_000).to_a
      (100_000..200_000).each { |n| a << n }
    end
  end

end
```
