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

October 14, 2018
~~~~~~~~~~~~~~~~

- ``sys-process/procps`` has been updated to 3.3.12-r3 to address CVE-2018-1122, CVE-2018-1123, CVE-2018-1124, CVE-2018-1125 and CVE-2018-1126.


October 8, 2018
~~~~~~~~~~~~~~~

- ``net-misc/openssh`` has been updated to 7.6_p1-r2 to address CVE-2018-15473.


August 29, 2018
~~~~~~~~~~~~~~

- ``dev-libs/openssl`` has been updated to 1.0.2p to address CVE-2018-0732 and CVE-2018-0737.

August 4, 2018
~~~~~~~~~~~~~

- ``net-misc/curl``  has been updated to 7.61.0 to address CVE-2018-0500.


July 25, 2018
~~~~~~~~~~~~~

- ``sys-apps/file``  has been updated to 5.32-r1 to address CVE-2018-10360.


May 31, 2018
~~~~~~~~~~~

- ``sys-process/procps`` has been updated to 3.3.12-r2 to address CVE-2018-1122, CVE-2018-1123 and CVE-2018-1124.


May 30, 2018
~~~~~~~~~~~

- ``dev-vcs/git`` has been updated to 2.15.2 to address CVE-2018-11233 and CVE-2018-11235.

May 20, 2018
~~~~~~~~~~~~

- ``net-misc/dhcp`` has been updated to 4.3.6_p1 to address CVE-2017-3144, CVE-2018-5732 and CVE-2018-5733.


- ``net-misc/curl`` has been updated to 7.60.0 to address CVE-2018-1000005, CVE-2018-1000007, CVE-2018-1000120, CVE-2018-1000121 and CVE-2018-1000122.

May 19, 2018
~~~~~~~~~~~~

- ``net-misc/rsync``  has been updated to 3.1.3 to address CVE-2018-5764.


- ``sys-libs/ncurses`` has been updated to 6.0-r3 to address security vulnerabilites: CVE-2017-13728 to 13334, CVE-2017-10684, CVE-2017-10685, CVE-2017-16879, CVE-2017-11112, CVE-2017-11113.


March 17, 2018
~~~~~~~~~~~~~~

- ``sys-apps/util-linux`` has been updated to 2.31.1-r1 to address CVE-2018-7738.

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
