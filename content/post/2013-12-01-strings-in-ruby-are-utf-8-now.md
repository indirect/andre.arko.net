---
date: "2013-12-01T00:00:00Z"
title: Strings in Ruby are UTF-8 now… right?
---
Ruby strings! In Ruby 1.8, Strings were (basically) just arrays of bytes with some extra methods, but Ruby 1.9 added explicit encoding support. Now every string knows how it is encoded! This fixes all of our issues with non-ASCII characters, right? Maybe? Hopefully? Possibly?

Nope. :(

Behold, as narrated by [The String Type Is Broken](http://mortoray.com/2013/11/27/the-string-type-is-broken), exactly how many ways Ruby completely fails to comprehend UTF-8 strings.

First, special characters that have to be handled in a way that is aware of how they work. 100% fail.

```ruby
"noël".encoding # => UTF-8
"noël".reverse == "lëon" # => false
"noël"[0..2] == "noë" # => false
"noël".length == 4 # => false
```

Perhaps unsurprisingly, Ruby is able to handle emoji correctly. So that's good! I gather that handling multibyte characters as characters was one of the focuses of Ruby's encoding support. Of course, handling these incorrectly probably requires UTF-16 strings, and Ruby doesn't have those at all. So maybe it's just accidentally correct.

```ruby
"😸😾".encoding # => UTF-8
"😸😾".length == 2 # => true
"😸😾"[1..1] == "😾" # => true
"😸😾".reverse == "😾😸" # => true
```

Finally, composition in the form of ligatures isn't handled at all. Bummer.

```ruby
"baﬄe".encoding # => UTF-8
"baﬄe".upcase == "BAFFLE" # => false
```

😢

To totally upgrade your 😢 into a full on 😭, though, just check out the way that [the Elixir language handles unicode strings](https://github.com/elixir-lang/elixir/blob/d95a7d1a58bddcbbfec62a17c16a53dc1d6a3543/lib/elixir/test/elixir/string_test.exs#L18-L29). I mean, I understand that Erlang is only 5 years older than Ruby is, but I sure wish we had added support for unicode when we added support for strings to claim they are unicode.