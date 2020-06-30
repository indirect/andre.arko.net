---
title: "Building Ruby on arm64 macOS"
layout: post
---
As part of my [new computer project](/2020/06/29/symbol-_ffi_prep_closure-not-found/), I've been trying to compile Ruby for arm64-darwin20 from source. The bad news is that if you don't do anything in particular, it won't work:

```
compiling closure.c
closure.c:264:14: error: implicit declaration of function 'ffi_prep_closure' is invalid in C99 [-Werror,-Wimplicit-function-declaration]
    result = ffi_prep_closure(pcl, cif, callback, (void *)self);
             ^
1 error generated.
make[2]: *** [closure.o] Error 1
make[1]: *** [ext/fiddle/all] Error 2
make: *** [build-ext] Error 2
```

The good news is that it's possible to get it to work anyway. If you use [ruby-install](https://github.com/postmodern/ruby-install), there are two steps. First, you need to [remove `libffi` from the list of packages](https://github.com/indirect/ruby-install/commit/e0079f5354bb373bbd7ce361f72ffae9deba836f). Then, you need to pass a couple of flags to the install process.

It looks like the ruby-core team is [already starting to merge explicit support for arm64](https://github.com/ruby/ruby/commit/7cb8904a12c850ee30dcd67817fa2f9dc3fee813), so hopefully it won't be long before none of the extra flags need to be passed in at all.

I've already removed the `libffi` brew package from my fork, so you can build Ruby 2.7.1 and 2.6.6 like this:

```bash
git clone https://github.com/indirect/ruby-install.git
cd ruby-install
./bin/ruby-install ruby 2.7.1 -c -- --with-arch=arm64 CFLAGS=-DUSE_FFI_CLOSURE_ALLOC=1 
./bin/ruby-install ruby 2.6.6 -c -- --with-arch=arm64 CFLAGS=-DUSE_FFI_CLOSURE_ALLOC=1 
```

Assuming you've already followed the [steps from yesterday](/2020/06/29/symbol-_ffi_prep_closure-not-found/) to fix system Ruby and Homebrew, that should be all you need!

```
$ ~/.rubies/ruby-2.7.1/bin/ruby -v
ruby 2.7.1p83 (2020-03-31 revision a0c7c23c9c) [arm64-darwin20]
$ ~/.rubies/ruby-2.6.6/bin/ruby -v 
ruby 2.6.6p146 (2020-03-31 revision 67876) [arm64-darwin20]
```
