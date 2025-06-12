+++
title = 'utilitylimb fortunes'
date = 2025-06-12T09:28:25-07:00
+++
One of the sillier things I do with my computer is print [a horse fortune](https://mylittlehorseebooks.tumblr.com/) every time I open a new shell, printed by the even sillier CLI tool [ponysay](https://github.com/erkin/ponysay). A long time ago, I downloaded a fortune database from horsefortun.es (RIP), a website full of posts by the Twitter (RIP) account @horseebooks (RIP). More recently, I added a fortune file of posts from “weird twitter”, which added a lot of excellent variety. Most recently, I added one more, of posts by the excellent @utilitylimb. Most famous for “I can control any kind of gem with any kind of snake”, she is not only an all-time poster, she has returned to the internet after a decade long hiatus and can be found at [@utilitylimb.bsky.social](https://bsky.app/profile/utilitylimb.bsky.social). Go and follow.

Anyway, please enjoy [these Homebrew formulas](https://github.com/indirect/homebrew-tap/tree/master/Formula) for fortune files filled with good weird posts.

	brew install indirect/tap/horse_fortunes indirect/tap/weird_fortunes indirect/tap/utilitylimb_fortunes

I use them by putting this at the top of my `.zshrc`:

	fortune /opt/homebrew/share/games/fortunes/weird | ponysay -b unicode

