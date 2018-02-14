===============================
core-kit 1.2-prime update steps
===============================

This documents the update steps to core-kit 1.2-prime from 1.0-prime.

Currently core-kit 1.2-prime is set as BETA and switching is performed by manual change of a kit branch in ``/etc/ego.conf``

# cat ``/etc/ego.conf``

[kits]

# You can set your default kits here. Unset kits will use the Funtoo default prime/master
# branch by default.

core-kit = 1.2-prime

After setting the 1.2-prime branch, running ``ego sync`` will make sync meta-repo and include updates to the core-kit ebuilds.

- Toolchain update procedure.

Following ebuild version are scheduled to update with ``1.2-prime``.

- ``gcc-6.4.0``
- ``glibc-2.26-r5``
- ``linux-headers-4.14``

Update is as simple as running ``emerge -auND @world``. After completion, due to, new ``libstdc++`` version in gcc-6, rebuilding of certain number of ebuilds required, which can be performed by ``revdep-rebuild --library 'libstdc++.so.6' -- --exclude gcc``

