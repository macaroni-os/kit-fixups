===========================
core-kit
===========================
1.2-prime branch
---------------------------

Core-kit contains the core ebuilds for Funtoo Linux. It is designed to be a part of the Funtoo Linux kits system.

The ``1.2-prime`` branch of core-kit is currently marked as *development branch*. Please use ``1.0-prime`` for
production systems, not this branch.

The ``-prime`` suffix indicates that the eventual goal is for this kit branch to reach production-quality and
enterprise-class stability. Once this is achieved, we will only incorporate bug fixes for specific issues, and security
backports. We will *not* be bumping versions of ebuilds unless absolutely necessary and we have very strong belief that
they will not negatively impact the functionality on anyone's system.

You can track the stability rating of this branch by using the ``ego kit list`` command, which will display the current
stability rating of this kit branch.

--------------------
Security Workarounds
--------------------

- ``net-dns/avahi`` has a not-yet-fixed vulnerability -- CVE-2017-6519 -- affecting versions 0.7 (latest version) and
  earlier.  Since no fix is currently available from the author, it is highly recommended that UDP multicast DNS traffic
  destined for port 5353 is blocked by a firewall, or that avahi is configured to not listen on externally-connected
  interfaces. See https://github.com/lathiat/avahi/issues/145

--------------
Security Fixes
--------------

March 17, 2018
~~~~~~~~~~~~~~

- ``sys-apps/util-linux`` has been update to 2.31.1-r1 to address CVE-2018-7738.

March 16, 2018
~~~~~~~~~~~~~~

- ``sys-apps/shadow`` has been updated to 4.5-r1 to address CVE-2018-7169.

January 13, 2018
~~~~~~~~~~~~~~~~

- ``dev-libs/libxml2`` has been updated to 2.9.7-r1 to address CVE-2017-16392, CVE-2017-16391, CVE-2017-9049 and CVE-2017-8872.

December 28, 2017
~~~~~~~~~~~~~~~~~

- ``app-admin/sudo`` has been updated to 1.8.21_p2 to address CVE-2017-1000368 (CVE-2017-1000367 was already addresssed via patch.)

December 21, 2017
~~~~~~~~~~~~~~~~~
- ``dev-libs/openssl`` has been updated to 1.0.2n to address CVE-2017-3735, CVE-2017-3736, CVE-2017-3737 and CVE-2017-3738.

December 18, 2017
~~~~~~~~~~~~~~~~~

- ``net-misc/rsync`` has been updated to 3.1.2-r1 to address CVE-2017-16548, CVE-2017-17433 and CVE-2017-17434.

Reporting Bugs
---------------

To report bugs or suggest improvements to core-kit, please use the Funtoo Linux bug tracker at https://bugs.funtoo.org.
Thank you! :)
