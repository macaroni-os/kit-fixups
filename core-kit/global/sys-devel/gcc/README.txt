The notes in this file apply to ebuilds authored by Funtoo -- those that are
not using the toolchain eclass.

The current "gold" master ebuild -- the one that contains all the most recent
changes and new ebuilds should be based upon, is:

gcc-4.9.3-r2.ebuild

== Introduction ==

This is a simplified Funtoo gcc ebuild. It has been designed to have a reduced dependency
footprint, so that libgmp, mpfr and mpc are built as part of the gcc build process and
are not external dependencies. This makes upgrading these dependencies easier and
improves upgradability of Funtoo Linux systems, and solves various thorny build issues.

Also, this gcc ebuild no longer uses toolchain.eclass which improves the maintainability
Other important notes on this ebuild:

* mudflap is enabled by default.
* lto is disabled by default.
* test is not currently supported.
* objc-gc is enabled by default when objc is enabled.
* gcj is not currently supported by this ebuild.
* graphite is not currently supported by this ebuild.
* hardened is now supported, but we have deprecated the nopie and nossp USE flags from gentoo.
