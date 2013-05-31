---
title: Illegal anonymous lifetime
layout: post
---
So I’ve been playing with [Rust](http://rust-lang.org) lately. It’s pretty fun, in a “let’s learn about four types of pointers” kind of way.

I managed to work my way through [Rust for Rubyists](http://www.rustforrubyists.com), [the Rust language tutorial](http://static.rust-lang.org/doc/tutorial.html), [What I Learnt So Far](http://www.darkcoding.net/software/rust-what-i-learnt-so-far), and big chunks of the [Reference Guide](http://static.rust-lang.org/doc/rust.html), [core docs](http://doc.rust-lang.org/doc/core/index.html), and [stdlib docs](http://doc.rust-lang.org/doc/std/index.html). (If you’re interested in Rust, that turns out to be a pretty decent order for starting out.)

I wound up having to compile Rust from the `incoming` branch so that all the functions that I wanted to use would be available, but it turns out that telling homebrew to compile from a branch other than `master` just requires a single additional hash argument supplied during `brew edit rust`.

```diff
-  head 'https://github.com/mozilla/rust.git'
+  head 'https://github.com/mozilla/rust.git', :branch => "incoming"
```

Anyway, this blog post is about anonymous lifetimes, so I should probably get to that. If you’re just starting off, and you think you’d like to create your own traits, chances are high that you wrote something like this:

```rust
trait MyTrait {
  fn do_stuff(&self) -> ();
}
```

Then you tried to write an implementation, and it probably looked like this:

```rust
impl MyTrait for &str {
  fn do_stuff(&self) -> () { () };
}
```

Turns out that that isn’t possible. Bummer. The reason it’s not possible is pretty interesting, though. When you try to compile that implementation, rustc will give you a very specific error, namely`Illegal anonymous lifetime: anonymous lifetimes are not permitted here`. I eventually found the [borrowed pointer tutorial](http://static.rust-lang.org/doc/tutorial-borrowed-ptr.html) to explain what that error actually means.

Anonymous lifetimes are what rustc calls borrowed pointers (like `&str`) that will be valid for an indeterminate amount of time. Since rustc has no idea how long that pointer will need to be valid, it may or may not be garbage collected, go out of scope, get invalidated by an assignment, or anything else that would result in a dangling pointer. Rust doesn’t let you compile code that it knows could allow a dangling pointer, so it errors out there.

I naively thought that might mean I need to write two separate implementations, one for `~str` and one for `@str`, but that turns out to also be no good. Even if you write both of those implementations, when you try to call the method on your `str` object, you’ll get the error `` type `&str` does not implement any method in scope named `do_stuff` ``. And then I was back where I started two paragraphs ago, trying to implement for `&str`, with an anonymous lifetime error.

The fix is surprisingly simple. All you have to do is tell rustc how long the borrowed pointer will need to last. The easiest way to do that is to say that the borrowed pointer will need to last for the same amount of time as the pointer to `&self`. The syntax to do that has a lot of punctuation, but isn’t too bad once you know what’s going on.

```rust
impl<'self> for MyTrait &'self str {
  fn do_stuff(&self) -> () { () }
}
```

The angle brackets apply to the `impl` keyword, and can contain lifetime declarations or types. In this case, it simply tags the lifetime of the implementation’s functions with the name “self”. Later, the pointer `&'self str` identifies the object that will be `&self` inside this implementation block as also having the lifetime named “self”.

All the pointers that have been tagged with the same name are said to have “intersecting lifetimes”. In practice, that means that Rust needs to keep pointers that are borrowed by this implementation alive for as long as the pointer to `&self` is alive.

And there you have it: in the end, rustc just needs to know how long the pointers that are being thrown around need to last, but the error messages might lead you around in a circle until you know that.