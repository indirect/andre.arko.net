+++
title = 'Variable outputs from jj to a fixed length zsh array'
date = 2025-06-19T14:43:22-07:00
+++

While working on my shell prompt for [jj](https://jj-vcs.github.io/jj/latest/), which will get a much longer post on its own shortly, I ran into a fascinating mismatch between different programs’ ideas of “empty”.

To set the context, I’m trying to print out the change ID and the commit ID, which have two parts each. The “prefix”, which is the shortest unambiguous value that will match, and the “rest”, which is the other letters needed to reach the minimum length. (In this case 4 characters).

	jj log -T 'separate(" ",
	  change_id.shortest(4).prefix(),
	  change_id.shortest(4).rest(),
	  commit_id.shortest(4).prefix(),
	  commit_id.shortest(4).rest()
	)'

In jj, the `separate()` function prints each argument, delimited by a string. So that’s a list of four possible values, and the output looks something like `z yxv a bcd`. But what if the shortest unambiguous name is four characters? Then you get `zyxw a bcd`, or `x yxv abcd`. Unfortunately, `separate()` skips empty arguments entirely, so there’s nothing to indicate which value is missing.

My genius plan (which consisted of assigning the output string to a zsh array) is now completely ruined—any time there are only 3 values, they are assigned to the wrong array indexes. After a few frustrating minutes, I had the evil genius idea of giving jj a sentinel value to print instead if the ID value was an empty string.

	jj log -T 'separate(" ",
	  change_id.shortest(4).prefix(),
	  coalesce(change_id.shortest(4).rest(), "\0"),
	  commit_id.shortest(4).prefix(),
	  coalesce(commit_id.shortest(4).rest(), "\0")
	)'

Shockingly, that worked! It turns out jj thinks a null byte is _not_ empty, and so it prints `zyxw <null> a bcd`, including separators around the null. Unfortunately, that doesn’t work for zsh, which ignores nulls and treats multiple spaces as a single space for the purposes of splitting strings, so the array was still getting the wrong values.

One more tweak, using `#` as the separator, and the stars suddenly aligned: zsh split the string into four values, but ignored the null, and put an empty string into the array instead.

	$ IFS="#" local change=($(jj log -n 1 -T 'separate("#",
	    change_id.shortest(4).prefix(), coalesce(change_id.shortest(4).rest(), "\0"),
	    commit_id.shortest(4).prefix(),
	    coalesce(commit_id.shortest(4).rest(), "\0")
	  )'))

And with that, the jj output of `zyxw#<null>#a#bcd` was successfully transformed into the zsh array of `"zyxw", "", "a", "bcd"`.

	$ print -l -- $change
	zyxw
	
	a
	bcd

Phew.
