===========================
gnome-kit
===========================
3.20-prime branch
---------------------------

Gnome-kit contains the functionality of GNOME 3.20 for Funtoo Linux. It is designed to be a part of the Funtoo Linux
kits system.

The ``3.20-prime`` branch of gnome-kit is the initial, stable curated branch of xorg for Funtoo. By 'curated', we mean
that the overlay is a fork of a collection of ebuilds from Gentoo Linux that we have found particularly stable and will
be continuing to maintain.


The ``-prime`` suffix indicates that we consider this branch to be production-quality, enterprise class stability and
will be only incorporating bug fixes for specific issues and security backports. We will *not* be bumping versions of
ebuilds unless absolutely necessary and we have very strong belief that they will not negatively impact the
functionality on anyone's system.

Based on these policies, you should consider ``3.20-prime`` to be a reference implementation of GNOME for Funtoo Linux
that you can rely on to be stable and perform consistently over an extended period of time.

--------------
Security Fixes
--------------

December 18, 2017
~~~~~~~~~~~~~~~~~

- ``app-text/evince`` has been udpated to 3.20.1-r1 to address CVE-2017-1000083.
- ``dev-libs/libcroco`` has been udpated to 0.6.11-r1 to address CVE-2017-7960 and CVE-2017-7961.
- ``gnome-base/nautilus`` has been updated to 3.20.3-r1 to address CVE-2017-14604.
- ``media-gfx/shotwell`` has been updated to 0.23.7-r1 to address CVE-2017-1000024.
- ``net-libs/gtk-vnc`` has been updated to 0.6.0-r1 to address CVE-2017-5884 and CVE-2017-5885.
- ``net-libs/webkit-gtk`` has been updated to 2.16.6 to address CVE-2017-7039, CVE-2017-7018, CVE-2017-7030,
  CVE-2017-7037, CVE-2017-7034, CVE-2017-7055, CVE-2017-7056, CVE-2017-7064, CVE-2017-7061, CVE-2017-7048,
  CVE-2017-7046.
- ``www-client/epiphany`` has been udpated from 3.20.3 to 3.20.7 to address CVE-2017-1000025.
- ``x11-libs/gdk-pixbuf`` has been updated from 2.36.9 to 2.36.9 to address the following vulnerabilities:
  CVE-2017-6311, CVE-2017-6312, CVE-2017-6313, CVE-2017-6314, CVE-2017-2862, CVE-2017-2870.

---------------
Reporting Bugs
---------------

To report bugs or suggest improvements to xorg-kit, please use the Funtoo Linux bug tracker at https://bugs.funtoo.org.
Thank you! :)