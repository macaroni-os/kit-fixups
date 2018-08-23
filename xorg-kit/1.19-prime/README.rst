===========================
xorg-kit
===========================
1.19-prime branch
---------------------------

Xorg-kit is an overlay containing all core ebuilds related to xorg for Funtoo Linux. It is designed to exist on users
systems as an overlay, providing the ability for users to control what branch of xorg-kit they are using. It is designed
to be a part of the Funtoo Linux kits system.

The ``1.19-prime`` branch of xorg-kit is the current, stable curated branch of xorg for Funtoo. By 'curated', we mean
that the overlay is a fork of a collection of ebuilds from Gentoo Linux that we have found particularly stable and will
be continuing to maintain.


The ``-prime`` suffix indicates that we consider this branch to be production-quality, enterprise class stability and
will be only incorporating bug fixes for specific issues and security backports. We will *not* be bumping versions of
ebuilds unless absolutely necessary and we have very strong belief that they will not negatively impact the
functionality on anyone's system.

Based on these policies, you should consider ``1.19-prime`` to be a reference implementation of xorg for Funtoo Linux
that you can rely on to be stable and perform consistently over an extended period of time.

--------------
Security Fixes
--------------

August 23, 2018
~~~~~~~~~~~~~~

- ``x11-libs/libX11`` has been updated to 1.6.6 to address CVE-2018-14598, CVE-2018-14599 and CVE-2018-14600.


March 29, 2018
~~~~~~~~~~~~~

- ``x11-libs/libXcursror`` has been updated to 1.1.14-r1 to address CVE-2017-16612.


March 20, 2018
~~~~~~~~~~~~

- ``x11-libs/libXfont`` has been updated to 1.5.4 to address CVE-2017-16611.

- ``x11-libs/libXfont2`` has been updated to 2.0.3 to address CVE-2017-16611.


January 4, 2018
~~~~~~~~~~~~~~~

``x11-base/xorg-server`` has been updated to 1.19.3-r2 to address CVE-2017-13721 and CVE-2017-13723.


As of November 17, 2017, all known security vulnerabilities in the ``1.19-prime`` branch have been addressed.

November 17, 2017: ``libXfont backports`` - ``x11-libs/libXfont-1.5.3`` and ``x11-libs/libXfont-2.0.2`` have been added
to address ``CVE-2017-13720`` and ``CVE-2017-13722``.

`xorg-server-1.19.5 backports`_ Adam Jackson ajax@redhat.com: "One regression fix since 1.19.4 (mea culpa), and fixes
for CVEs 2017-12176 through 2017-12187." Funtoo Linux has backported security fixes for these issues from
xorg-server-1.19.5 into xorg-server-1.19.3-r1 ebuild.

---------------
Reporting Bugs
---------------

To report bugs or suggest improvements to xorg-kit, please use the Funtoo Linux bug tracker at https://bugs.funtoo.org.
Thank you! :)

.. _xorg-server-1.19.5 backports: https://lists.x.org/archives/xorg-devel/2017-October/054871.html
