===========================
xorg-kit
===========================
1.17-prime branch
---------------------------

Xorg-kit is an overlay containing all core ebuilds related to xorg for Funtoo
Linux. It is designed to exist on users systems as an overlay, providing the
ability for users to control what branch of xorg-kit they are using. It is
designed to be a part of the Funtoo Linux kits system.

The ``1.17-prime`` branch of xorg-kit is the initial, stable curated branch of
xorg for Funtoo. By 'curated', we mean that the overlay is a fork of a
collection of ebuilds from Gentoo Linux that we have found particularly stable
and will be continuing to maintain. 

The ``-prime`` suffix indicates that we consider this branch to be
production-quality, enterprise class stability and will be only incorporating
bug fixes for specific issues and security backports. We will *not* be bumping
versions of ebuilds unless absolutely necessary and we have very strong belief
that they will not negatively impact the functionality on anyone's system.

Based on these policies, you should consider ``1.17-prime`` to be a reference
implementation of xorg for Funtoo Linux that you can rely on to be stable and
perform consistently over an extended period of time.

--------------
Security Fixes
--------------

`X.org October 4, 2016 Security Advisory`_ notes a number of packages that do
not perform sufficient validation of input data. The ``1.17-prime`` branch is
not using any versions of packages affected by these issues.

``CVE-2017-2624`` - `X41 D-Sec GmbH`_ found a number of security vulnerabilities
in xorg related to MIT cookies and weak entropy usage in various places. Red
Hat has declined to fix these in Red Hat Enterprise Linux as they do not impact
most users' systems based on their default configuration. Funtoo Linux has backported
fixes for these issues from xorg-server-1.19.2 and integrated them into a new
ebuild, xorg-server-1.17.4-r1.ebuild.

As of April 2, 2017, all known security vulnerabilities in the ``1.17-prime``
branch have been addressed.

`Freetype security backports`_
``CVE-2016-10244`` - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2016-10244
The parse_charstrings function in type1/t1load.c in FreeType 2 before 2.7 does not ensure that a font contains a glyph name, which allows remote attackers to cause a denial of service (heap-based buffer over-read) or possibly have unspecified other impact via a crafted file.

``CVE-2017-8105`` - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-8105
FreeType 2 before 2017-03-24 has an out-of-bounds write caused by a heap-based buffer overflow related to the t1_decoder_parse_charstrings function in psaux/t1decode.c.

``CVE-2017-8287`` - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-8287
FreeType 2 before 2017-03-26 has an out-of-bounds write caused by a heap-based buffer overflow related to the t1_builder_close_contour function in psaux/psobjs.c.
Upstream fixes backported into =media-libs/freetype-2.6.5-r1 ebuild.

---------------
Reporting Bugs
---------------

To report bugs or suggest improvements to xorg-kit, please use the Funtoo Linux
bug tracker at https://bugs.funtoo.org. Thank you! :)

.. _X41 D-Sec GmbH: https://www.x41-dsec.de/lab/advisories/x41-2017-001-xorg/
.. _X.org October 4, 2016 Security Advisory: https://www.x.org/wiki/Development/Security/Advisory-2016-10-04/


