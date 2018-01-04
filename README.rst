Kit-Fixups Repository
=====================

This is repository of categories and packages that are "forked" from official Gentoo repository and our versions and
fix-ups are applied over the Gentoo repository when we generate our tree.

How is it structured?
---------------------

As you can see there are directories for every kit. These directories can contain subdirectories which are ment for:

   - global
      These directories contain fixes and package ebuilds that get applied to all our branches. Global fixes get
      applied to master branch from Gentoo.
   - curated
      These directories contain fixes similar to global, but are excluding master branch from Gentoo.
   - <branch_name> (eg. 1.0-prime, 3.20-prime ...)
      These directories with fixes get applied over master, but only for selected branch.

Note for developers: If a kit is following master (doesn't have any branches), then it shouldn't have any branches
   folders.

Do you want to help?
--------------------

If you want to help with packages review, and we would very much appreciate it, go to:

   http://ports.funtoo.org/stale

Here you can find hourly updated list of packages that were not review for longer period of time (currently 30 days).
You could help us search for packages that have security flaws and report them in our
`bug tracker <https://bugs.funtoo.org>`_.

Thank you very much in advance.