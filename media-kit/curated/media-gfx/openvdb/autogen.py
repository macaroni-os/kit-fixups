#!/usr/bin/env python3

import re
import glob
import os
from packaging import version

async def generate(hub, **pkginfo):
	github_user = "AcademySoftwareFoundation"
	github_repo = "openvdb"
	pkginfo.update(await hub.pkgtools.github.release_gen(hub, github_user, github_repo))
	major_ver = int(pkginfo['version'].split(".")[0])
	abi_min = major_ver - 2
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=github_user,
		github_repo=github_repo,
		major_ver=major_ver,
		abi_min=abi_min
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
