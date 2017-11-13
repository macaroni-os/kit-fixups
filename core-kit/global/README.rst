===========================
core-kit
===========================
1.0 and 1.1-prime branches
---------------------------

Core-kit is a stand-alone Portage repository that contains all 'core' ebuilds, such as core toolchain, userland, and
kernels. It is designed to be an integral part of the Funtoo Linux kits system.

The ``1.0-prime`` branch of core-kit is the initial, stable curated branch of xorg for Funtoo. The ``1.1-prime`` is an
updated branch. By 'curated', we mean that the overlay is a fork of a collection of ebuilds from Gentoo Linux that we
have found particularly stable and will be continuing to maintain.

``1.0-prime`` is considered to be a reference implementation of core ebuilds for Funtoo Linux that you can rely on to be
stable and perform consistently over an extended period of time. ``1.1-prime`` is still in the process of being worked
on by Funtoo developers and is not yet production-ready. You can view the current stability ratings of kits by typing
``ego kit list``.


----------------------------------------------
Security Fixes in both 1.0-prime and 1.1-prime
----------------------------------------------

November 13, 2017 - ``net-misc/wget-1.19.2`` has been added to address ``CVE-2017-13089`` and ``CVE-2017-13090``.

June 22, 2017 - The following security issues have been addressed by the addition of a new revision of glibc,
``sys-libs/glibc-2.23-r4``:

``CVE-2017-1000366``- https://nvd.nist.gov/vuln/detail/CVE-2017-1000366 "glibc contains a vulnerability that allows
specially crafted LD_LIBRARY_PATH values to manipulate the heap/stack, causing them to alias, potentially resulting in
arbitrary code execution. Please note that additional hardening changes have been made to glibc to prevent manipulation
of stack and heap memory but these issues are not directly exploitable, as such they have not been given a CVE. This
affects glibc 2.25 and earlier."

``CVE-2016-6323`` - https://nvd.nist.gov/vuln/detail/CVE-2016-6323 - "The makecontext function in the GNU C Library (aka
glibc or libc6) before 2.25 creates execution contexts incompatible with the unwinder on ARM EABI (32-bit) platforms,
which might allow context-dependent attackers to cause a denial of service (hang), as demonstrated by applications
compiled using gccgo, related to backtrace generation."

``CVE-2015-5180`` - https://sourceware.org/bugzilla/show_bug.cgi?id=18784 - "If T_UNSPEC (62321) is passed to functions
such as res_query as a record type , libresolv will dereference a NULL pointer, crashing the process.  This is a very
minor security vulnerability because it is conceivable that the RR type is supplied by an untrusted party. The expected
behavior is that libresolv sends a TYPE62321 query to the configured forwarders because it is a valid record type as far
as DNS is concerned."

---------------
Reporting Bugs
---------------

To report bugs or suggest improvements to core-kit, please use the Funtoo Linux
bug tracker at https://bugs.funtoo.org. Thank you! :)
