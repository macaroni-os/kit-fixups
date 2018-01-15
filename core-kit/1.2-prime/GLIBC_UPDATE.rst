===========================
glibc-2.26 update
===========================
glibc-2.26 has significant changes such as:
- old NSL library is deprecated, headers removed. Only libnsl.so.1 provided for compatibility with older binaries. Newer library version and headers are provided by net-libs/libnsl.
- lowest supported kernel is linux-3.2, means that any projects that require older kernel, supposed to not update glibc.
- old RPC support now depreacted and disabled by default. RPC now provided by net-libs/libtirpc and net-libs/rpcsvc-proto.

Due to the fact libnss_compat is removed in glibc-2.26 and ``/etc/nsswitch.conf`` installed by old glibc version containing the configuration no longer working with new glibc, users must perform manual changes before updating from glibc-2.23 to glibc-2.26.

Example of old ``/etc/nsswitch.conf``:

# cat /etc/nsswitch.conf
...
passwd:      compat
shadow:      compat
group:       compat
...


Edit the file to look like shown below.
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
