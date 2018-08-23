===========================
xorg-kit
===========================
1.17-prime branch
---------------------------

Xorg-kit is an overlay containing all core ebuilds related to xorg for Funtoo Linux. It is designed to exist on users
systems as an overlay, providing the ability for users to control what branch of xorg-kit they are using. It is designed
to be a part of the Funtoo Linux kits system.

The ``1.17-prime`` branch of xorg-kit is the initial, stable curated branch of xorg for Funtoo. By 'curated', we mean
that the overlay is a fork of a collection of ebuilds from Gentoo Linux that we have found particularly stable and will
be continuing to maintain. ``1.19-prime`` is also available.


The ``-prime`` suffix indicates that we consider this branch to be production-quality, enterprise class stability and
will be only incorporating bug fixes for specific issues and security backports. We will *not* be bumping versions of
ebuilds unless absolutely necessary and we have very strong belief that they will not negatively impact the
functionality on anyone's system.

Based on these policies, you should consider ``1.17-prime`` to be a reference implementation of xorg for Funtoo Linux
that you can rely on to be stable and perform consistently over an extended period of time.

--------------
Security Fixes
--------------

August 23, 2018
~~~~~~~~~~~~~~~

- ``x11-libs/libX11`` has been updated to 1.6.6 to address CVE-2018-14598, CVE-2018-14599 and CVE-2018-14600.


March 29, 2018
~~~~~~~~~~~~~~

- ``x11-libs/libXcursror`` has been updated to 1.1.14-r1 to address CVE-2017-16612.


March 20, 2018
~~~~~~~~~~~~~

- ``x11-libs/libXfont`` has been updated to 1.5.4 to address CVE-2017-16611.

- ``x11-libs/libXfont2`` has been updated to 2.0.3 to address CVE-2017-16611.

As of November 17, 2017, all known security vulnerabilities in the ``1.17-prime`` branch have been addressed.

November 17, 2017: ``libXfont backports`` - ``x11-libs/libXfont-1.5.3`` and ``x11-libs/libXfont-2.0.2`` have been added
to address ``CVE-2017-13720`` and ``CVE-2017-13722``.

November 17, 2017: `xorg-server-1.19.5 backports`_ Adam Jackson ajax@redhat.com: "One regression fix since 1.19.4 (mea
culpa), and fixes for CVEs 2017-12176 through 2017-12187." Funtoo Linux has backported security fixes for these issues
from ``xorg-server-1.19.5`` into ``xorg-server-1.17.4-r3`` ebuild.

`X.org October 4, 2017 Security Advisory`_ The X.Org Foundation today published fixes for CVE-2017-13721 &
CVE-2017-13723 as part of the xorg-server 1.19.4 release. Funtoo Linux has backported fixes for these issues from
xorg-server-1.19.4 into xorg-server-1.17.4-r2 ebuild.

`X.org October 4, 2016 Security Advisory`_ notes a number of packages that do not perform sufficient validation of input
data. The ``1.17-prime`` branch is not using any versions of packages affected by these issues.

``CVE-2017-2624`` - `X41 D-Sec GmbH`_ found a number of security vulnerabilities in xorg related to MIT cookies and weak
entropy usage in various places. Red Hat has declined to fix these in Red Hat Enterprise Linux as they do not impact
most users' systems based on their default configuration. Funtoo Linux has backported fixes for these issues from
xorg-server-1.19.2 and integrated them into a new ebuild, xorg-server-1.17.4-r1.ebuild.

---------------------------
Freetype Security Backports
---------------------------

``CVE-2016-10244`` - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2016-10244 The parse_charstrings function in
type1/t1load.c in FreeType 2 before 2.7 does not ensure that a font contains a glyph name, which allows remote attackers
to cause a denial of service (heap-based buffer over-read) or possibly have unspecified other impact via a crafted file.

``CVE-2017-8105`` - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-8105 FreeType 2 before 2017-03-24 has an
out-of-bounds write caused by a heap-based buffer overflow related to the t1_decoder_parse_charstrings function in
psaux/t1decode.c.

``CVE-2017-8287`` - https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-8287 FreeType 2 before 2017-03-26 has an
out-of-bounds write caused by a heap-based buffer overflow related to the t1_builder_close_contour function in
psaux/psobjs.c. Upstream fixes backported into =media-libs/freetype-2.6.5-r1 ebuild.

Additionally, ``CVE-2016-10328`` and ``CVE-2017-7864`` have been addressed by a freetype-2.6.5 upgrade to
freetype-2.6.5-r1.

---------------
Reporting Bugs
---------------

To report bugs or suggest improvements to xorg-kit, please use the Funtoo Linux bug tracker at https://bugs.funtoo.org.
Thank you! :)

.. _X41 D-Sec GmbH: https://www.x41-dsec.de/lab/advisories/x41-2017-001-xorg/
.. _X.org October 4, 2016 Security Advisory: https://www.x.org/wiki/Development/Security/Advisory-2016-10-04/
.. _X.org October 4, 2017 Security Advisory: https://lists.x.org/archives/xorg-announce/2017-October/002809.html
.. _xorg-server-1.19.5 backports: https://lists.x.org/archives/xorg-announce/2017-October/002814.html


