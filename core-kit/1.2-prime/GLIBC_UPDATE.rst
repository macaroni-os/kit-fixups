===========================
glibc-2.26 update
===========================
glibc-2.26 has significant changes such as:
- old NSL library is deprecated and libnss_compat.so removed
- lowest supported kernel is linux-3.2, means that any projects that require older kernel, supposed to not update glibc.
- old RPC support now depreacted and disabled by default.

Due to fact libnss_compat is removed and ``/etc/nsswitch.conf`` has not changed since 2006, users must perform manual changes.
before updating from glibc-2.23 to glibc-2.26.

Example of old ``/etc/nsswitch.conf``:

# cat /etc/nsswitch.conf
...
passwd:      compat
shadow:      compat
group:       compat
...


Edit the file to look like below.
Example of new ``/etc/nsswitch.conf`` user need for a clean update:

# cat /etc/nsswitch.conf
...
passwd:      compat files
shadow:      compat files
group:       compat files
...

This file will be good even for glibc-2.23 and update should be smooth. After update, please, run ``etc-update`` or ``dispatch-conf`` and accept
changes for a fresh copy of ``/etc/nsswitch.conf`` installed by glibc-2.26.

Skipping the file change prior to glibc update will result in many groups, such as portage group, not recognized by system.
