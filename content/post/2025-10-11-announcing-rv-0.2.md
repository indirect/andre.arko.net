+++
title = 'Announcing <code>rv</code> 0.2'
slug = 'announcing-rv-0.2'
date = 2025-10-11T01:48:20-07:00
+++

With the help of many new contributors, and after many late nights wrestling with make, we are happy to (slightly belatedly) announce [the 0.2 release of rv](https://github.com/spinel-coop/rv/releases/tag/v0.2.0)!

This version dramatically expands support for Rubies, shells, and architectures.

Rubies: we have added Ruby 3.3, as well as re-compiled all Ruby 3.3 and 3.4 versions with YJIT. On Linux, YJIT increases our glibc minimum version to 2.35 or higher. That means most distro releases from 2022 or later should work, but please let us know if you run into any problems.

Shells: we have added support for bash, fish, and nushell in addition to zsh.

Architectures: we have added Ruby compiled for macOS on x86, in addition to Apple Silicon, and added Ruby compiled for Linux on ARM, in addition to x86.

Special thanks to newest member of the maintainers' team [@adamchalmers](https://github.com/adamchalmers) for improving code and tests, adding code coverage and fuzzing, heroic amounts of issue triage, and nushell support. Additional thanks are due to all the new contributors in version 0.2, including [@Thomascountz](https://github.com/Thomascountz), [@lgarron](https://github.com/lgarron), [@coezbek](https://github.com/coezbek), and [@renatolond](https://github.com/renatolond).

To upgrade, run `brew install rv`, or check the [release notes](https://github.com/spinel-coop/rv/releases/tag/v0.2.0) for other options.
