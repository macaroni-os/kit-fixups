Kit-Fixups Repository
=====================

This repository holds Funtoo's custom ebuilds, profiles and fixes for branches that are necessary for maintenance
of branches during their lifespan.

These fix-ups are applied over the Gentoo repository when Funtoo's repository gets generated using the
merge-scripts [1]_. 

To Contribute
-------------

**IMPORTANT:** To contribute to kit-fixups, please submit a pull request using https://code.funtoo.org. 

For more information on how to do this, please take a look at Daniel's YouTube Channel [2]_. There are several
videos there that will guide you through the process.

How is it structured?
---------------------

The structure of the tree is `kit-fixups/<kit>/<branch>/<cat>/<pkg>/<ebuilds here>`. We call `<cat>/<pkg>` a
"catpkg" for short. So the tree structure could be described as: `kit-fixups/<kit>/<branch>/<catpkg>`.

As you can see there are directories for every kit. These directories can contain branch subdirectories
which can have the following names:

- curated
   These directories contain fixes and package ebuilds that get applied to all our kits.
- <branch_name> (eg. 1.0-prime, 3.20-prime ...)
   These directories with fixes get applied over master, but only for selected branch. Any catpkg in here will
   override a matching catpkg (if one exists) in `curated`.

Note for developers: If a kit is following master (doesn't have any branches), then it shouldn't have any branch
folders.

Thank you very much in advance.

.. [1] https://github.com/funtoo/merge-scripts
.. [2] https://www.youtube.com/channel/UCKmOY6p3c9hxv3vJMAF8vVw
