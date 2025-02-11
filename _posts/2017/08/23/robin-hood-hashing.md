---
layout: post
title: "Robin Hood Hashing"
microblog: false
guid: http://indirect-test.micro.blog/2017/08/24/robin-hood-hashing/
post_id: 4971624
date: 2017-08-24T00:00:00-0800
lastmod: 2017-08-23T16:00:00-0800
type: post
images:
- 01-backing-array.png
- 02-open-addressing.png
- 03-open-addressing-full.png
- 04-robin-hood.png
- 05-robin-hood-full.png
- 06-robin-hood-disney.jpg
photos:
- 06-robin-hood-disney.jpg
photos_with_metadata:
- url: 06-robin-hood-disney.jpg
  width: 0
  height: 0
url: /2017/08/23/robin-hood-hashing/
---
<small>This post was originally given as a presentation at [Papers We Love Too](https://www.meetup.com/papers-we-love-too/), and the [slides](https://speakerdeck.com/indirect/robin-hood-hashing-papers-we-love-sf-august-2017) are also available.</small>

<script async class="speakerdeck-embed" data-id="ba7a175e5cb543d7b09db0b2d067b64d" data-ratio="1.33333333333333" src="//speakerdeck.com/assets/embed.js"></script>

Depending on where you learned about them from, you might call them associative arrays, dictionaries, hash tables, hash maps, or just hashes. Regardless of what you call them, hashes are one of the most commonly used data structures in all of computer science, and for good reason! They are incredibly handy, because they let you use one thing to keep track of another thing.

Before we can get to the magic of robin hood hashing, and why I’m so excited about it, I’m going to explain how hash data structures can be implemented. That way we can all be on the same page for the exciting part. So: how are hash tables implemented? It may surprise you, especially if you’ve never really thought about it before, but hash tables are almost always implemented using… arrays.

### Hash tables: secretly arrays

Down at the memory level, computers read and write data based on numerical indexes. Hash tables let you use strings or even entire objects as indexes by adding two layers of indirection on top of arrays: first, applying a _hashing algorithm_ to convert the given key into a number, and second by _resolving collisions_ when two keys hash down to the same address in the array that backs the hash table. Here’s a conceptual diagram illustrating how a hash table stores data in a backing array.

> ![](01-backing-array.png)
> In this illustration, the keys “Leia”, “Han”, and “Rey” are converted into numerical indexes by the hashing function—2, 4, and 0 respectively. Then, the key and value is stored in the backing array at each index.

The name “hash table” comes from the way that all hash tables use a hashing algorithm to calculate array indexes from arbitrary keys. Hashing is an entire fascinating field of computer science all by itself, but for our purposes today we can define the kind of hashing used by a hash table and then take it as a given while we look at the Robin Hood technique.

### Hash collisions

Hashing algorithms for hash tables are generally evaluated based a single criteria: do they distribute items evenly and randomly, even when the inputs are not random? The more evenly distributed the outputs are, the less there will be collisions. A collision is when two keys hash to the same index. That’s a problem, because each index number can only hold one item.

Even though the paper is named “Robin Hood Hashing”, the technique it describes only applies to this second aspect of hash tables, resolving collisions. As the paper notes, there are two general approaches to handling collisions: chaining, and open addressing.

_Chaining_ means that every value in the hash table is the head of a linked list, and additional memory must be allocated elsewhere to store the contents of each linked list. In addition, reading and writing can become quite slow because each read and write not only has to go to a completely different location in memory, it also has to traverse the entire linked list, no matter how long it is.

_Open addressing_, on the other hand, overflows into other slots as needed. There are many techniques available for calculating the second-choice slot, the third-choice slot, and so on. For our purposes today, I’m going to use the simplest algorithm imaginable: try the next slot. This is horribly inefficient, but will make it much easier to illustrate the Robin Hood technique. Let’s look at a table that uses open addressing to store several items that hash to the same values.

> ![](02-open-addressing.png)
> In this illustration, several keys hash to the same index. As a result, several subsequent indexes have been filled by data that “overflowed” from previous indexes.

### Here’s where it gets tricky

As you can imagine, the more collisions there are, the worse everything gets—reading slows down, writing slows down, and the closer to full the backing array is, the more extra steps need to be taken for every action. Here’s an illustration of a simplified worst-case type scenario.

> ![](03-open-addressing-full.png)
> In this illustration, you can see how just two or three collisions can create a situation where data has to be stored extremely far away from the index calculated by the hash function.

The frequency of collisions can be somewhat mitigated by having an extremely good hashing function. Unfortunately, thanks to [the Birthday Paradox](https://en.wikipedia.org/wiki/Birthday_problem), collisions are still more frequent than you would expect, even with a small amount of data. As the backing array gets closer and closer to full, the number of extra steps, or _probes_, required to find any piece of data grows very fast.

### Robin Hood to the rescue

This is the exact point where Robin Hood can save us from the sheriff of Big O complexity. Without requiring calculations in advance or additional arrays to store extra data, Robin Hood Hashing provides a system that results in a maximum of O(ln _n_) probes per operation, where _n_ is the number of items stored in the hash table.

How does it do this? By stealing from the rich and giving to the poor, of course. 😆 In the context of a hash table, the rich are those items that are located very close to their hash index, and the poor items are located far away. The core technique of Robin Hood Hashing is this: when adding new items, replace any item that is closer to its index (“richer”) than the item you are adding. Then, continue adding but with the item that was just replaced. Here’s an illustration of a table filled with data using the Robin Hood Hashing technique.

> ![](04-robin-hood.png)
> In this illustration, each collision was resolved by moving the later item to the next index. The number on the right of each item indicates how far away from its originally calculated index it is.

With this technique, the same worst-case collision that we observed previously produces an extremely different outcome. Here’s what that looks like instead.

> ![](05-robin-hood-full.png)
> In this diagram, the same wost-case data from the diagram before last has been inserted into the backing array. Using the Robin Hood technique, every item is displaced by only 2 slots or less.

Stealing from the rich and giving to the poor? That’s Robin Hood all over.

![](06-robin-hood-disney.jpg)

### Further reading

The original Robin Hood paper covers several other aspects of hash table implementation techniques, including probing algorithms, handling deletions in an efficient way, and others. Over the years, both academic and hobbyist computer scientists have implemented it, experimented with it, benchmarked it, and refined it.

Here is selection of interesting pieces discussing various aspects of Robin Hood hashing and techniques for implementing it efficiently, if you’d like to learn more.

- [Robin Hood Hashing (1986 original paper)](https://cs.uwaterloo.ca/research/tr/1986/CS-86-14.pdf)
- [Robin Hood Hashing with Linear Probing paper (2005)](https://www.dmtcs.org/pdfpapers/dmAD0127.pdf)
- [Paul Khuong experimenting with hashing options (2009)](https://www.pvk.ca/Blog/numerical_experiments_in_hashing.html)
- [Paul’s follow-up and conclusions (2011)](https://www.pvk.ca/Blog/more_numerical_experiments_in_hashing.html)
- [Sebastian Sylvan saying robin hood should be the default (2013)](https://www.sebastiansylvan.com/post/robin-hood-hashing-should-be-your-default-hash-table-implementation/)
- [Sebastian following up on slowness after deletions (2013)](https://www.sebastiansylvan.com/post/more-on-robin-hood-hashing-2/)
- [Emmanuel Goossaert benchmarking in C++ (2013)](http://codecapsule.com/2013/11/11/robin-hood-hashing/)
- [Paul Kuhong again, on linear probing for performance (2013)](https://www.pvk.ca/Blog/2013/11/26/the-other-robin-hood-hashing/)
- [Emmanuel benchmarking again after tweaking deletions (2013)](http://codecapsule.com/2013/11/17/robin-hood-hashing-backward-shift-deletion/)
