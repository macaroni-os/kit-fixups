The notes in this file apply to ebuilds authored by Funtoo -- those that are
not using the toolchain eclass.

The current "gold" master ebuild -- the one that contains all the most recent
changes and new ebuilds should be based upon, is:

gcc-7.3.1-r2.ebuild
...but this will be refactored and changing soon.

== Introduction ==

This is a simplified Funtoo gcc ebuild. It has been designed to have a reduced dependency
footprint, so that libgmp, mpfr and mpc are built as part of the gcc build process and
are not external dependencies. This makes upgrading these dependencies easier and
improves upgradability of Funtoo Linux systems, and solves various thorny build issues.

Also, this gcc ebuild no longer uses toolchain.eclass which improves the maintainability
Other important notes on this ebuild:

* mudflap is enabled by default.
* lto is enabled by default.
* test is now supported and encouraged.
* objc-gc is enabled by USE flag 'objc-gc'.
* graphite is supported by this ebuild.
* hardened is supported, but we use 'link_now', 'pie' & 'ssp' USE flags to control those features directly.
* go support is not tested and may be removed in the future (breaks when pulling libffi on multilib.)
