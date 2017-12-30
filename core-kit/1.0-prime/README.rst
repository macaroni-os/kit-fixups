===========================
core-kit
===========================
1.0-prime branch
---------------------------

Core-kit contains the core ebuilds for Funtoo Linux. It is designed to be a part of the Funtoo Linux kits system.

The ``1.0-prime`` branch of gnome-kit is the initial, stable curated branch of core ebuilds for Funtoo. By 'curated', we
mean that the overlay is a fork of a collection of ebuilds from Gentoo Linux that we have found particularly stable and
will be continuing to maintain.

The ``-prime`` suffix indicates that we consider this branch to be production-quality, enterprise class stability and
will be only incorporating bug fixes for specific issues and security backports. We will *not* be bumping versions of
ebuilds unless absolutely necessary and we have very strong belief that they will not negatively impact the
functionality on anyone's system.

Based on these policies, you should consider ``1.0-prime`` to be a reference implementation of core packages for Funtoo
Linux that you can rely on to be stable and perform consistently over an extended period of time.

--------------
Security Fixes
--------------

December 28, 2017
~~~~~~~~~~~~~~~~~

- ``app-admin/sudo`` has been updated to 1.8.21_p2 to address CVE-2017-1000368 (CVE-2017-1000367 was already addresssed via patch.)

December 21, 2017
~~~~~~~~~~~~~~~~~
- ``dev-libs/openssl`` has been updated to 1.0.2n to address CVE-2017-3735, CVE-2017-3736, CVE-2017-3737 and CVE-2017-3738.

December 18, 2017
~~~~~~~~~~~~~~~~~

- ``net-misc/rsync`` has been udpated to 3.1.2-r1 to address CVE-2017-16548, CVE-2017-17433 and CVE-2017-17434.

September 15, 2017
~~~~~~~~~~~~~~~~~~

- ``net-wireless/bluez`` was updated to 5.44-r1 to address CVE-2017-1000250 (blueborne vulnerability.)

---------------
Reporting Bugs
---------------

To report bugs or suggest improvements to core-kit, please use the Funtoo Linux bug tracker at https://bugs.funtoo.org.
Thank you! :)
