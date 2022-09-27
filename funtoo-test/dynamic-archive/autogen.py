#!/usr/bin/python3

import os
import asyncio

"""
This test attempts to create a dynamic archive, which is a locally-created archive that will exist
on the CDN. Please see the following documentation to learn about this feature:

https://code.funtoo.org/bitbucket/users/drobbins/repos/funtoo-metatools/browse/docs/features/dynamic-archives.rst

It creates two archives. The first one has a special unique key that is also stored with the archive.
The second archive is identical, but doesn't use the special key, so it just has a final_name.

We would expect both archives to be created, and for the last two debug statements, we would expect:

1. The blob path to be different for each archive.
2. On successive runs of the autogen, we would want the existing archives to be found, so once
   created the blob.path should remain constant.
"""

async def generate(hub, **pkginfo):
    id_key = "abcde"
    pkginfo["version"] = "1.0"
    my_archive, metadata = hub.Archive.find_by_name(f"dynamic-archive-1.0-{id_key}.tar.xz", key={"id_key": id_key})
    if not my_archive:
        my_archive = hub.Archive(f"dynamic-archive-1.0-{id_key}.tar.xz")
        my_archive.initialize("dynamic-archive-1.0")
        with open(os.path.join(my_archive.top_path, "README"), "w") as myf:
            myf.write("HELLO")
        my_archive.store_by_name(key={"id_key" : id_key})
    my_key_archive = my_archive

    my_archive, metadata = hub.Archive.find_by_name("dynamic-archive-1.0.tar.xz")
    if not my_archive:
        my_archive = hub.Archive("dynamic-archive-1.0.tar.xz")
        my_archive.initialize("dynamic-archive-1.0")
        with open(os.path.join(my_archive.top_path, "README"), "w") as myf:
            myf.write("HELLO")
        my_archive.store_by_name()
    eb = hub.pkgtools.ebuild.BreezyBuild(**pkginfo, artifacts=[my_key_archive, my_archive])
    eb.push()

    hub.pkgtools.model.log.debug(f"    Keyed archive BLOS path: {my_key_archive.blos_object.blob.path}")
    hub.pkgtools.model.log.debug(f"Non-keyed archive BLOS path: {my_archive.blos_object.blob.path}")
    #import pdb; pdb.set_trace()
