#!/usr/bin/env python3

import json
import re


async def generate(hub, **pkginfo):
	app = pkginfo["name"]
	ck_patches = None
	json_list = await hub.pkgtools.fetch.get_page(f"https://www.kernel.org/releases.json", is_json=True)
	version = json_list["latest_stable"]["version"]

	# We want just the major version to check ck patch is avaiable
	output = re.search("5\.[0-9]+", version)
	if output is not None:
		major = output.group(0)

	# Download the ck archive html to parse for possible versions
	try:
		ck_patches = await hub.pkgtools.fetch.get_page(f"http://ck.kolivas.org/patches/5.0/{major}/", is_json=False)
	except:
		pass

	# No versions at all, bail
	if ck_patches is None:
		raise hub.pkgtools.ebuild.BreezyError("Can't find a suitable release of ck patchset.")

	# There might be ck1 and ck2 available for a major, so we always want the last version
	matches = re.finditer(f"{major}-ck([0-9])", ck_patches)
	for matchNum, match in enumerate(matches, start=1):
		for groupNum in range(0, len(match.groups())):
			groupNum = groupNum + 1
			ck_version = match.group(groupNum)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		ck_extraversion=ck_version,
		branch_id=major,
		src_uri=f"http://ck.kolivas.org/patches/5.0/{major}/{major}-ck{ck_version}/patch-{major}-ck{ck_version}.xz",
	)

	ebuild.push()


# vim: ts=4 sw=4 noet
