#!/usr/bin/env python3

import json
import re


async def generate(hub, **pkginfo):
	app = pkginfo["name"]
	ck_patches = None
	json_list = await hub.pkgtools.fetch.get_page(f"https://www.kernel.org/releases.json", is_json=True)
	version = json_list["latest_stable"]["version"]

	versions = re.search("([0-9]+)\.([0-9]+)\.([0-9]+)", version)

	major_ver = versions.group(1)
	minor_ver = versions.group(2)
	patch_ver = versions.group(3)

	# Download the ck archive html to parse for possible versions
	try:
		ck_patches = await hub.pkgtools.fetch.get_page(
			f"http://ck.kolivas.org/patches/5.0/{major_ver}.{minor_ver}/", is_json=False
		)
	except:
		pass

	# No versions at all, bail
	if ck_patches is None:
		raise hub.pkgtools.ebuild.BreezyError("Can't find a suitable release of ck patchset.")

	# There might be ck1 and ck2 available for a major, so we always want the last version
	matches = re.finditer(f"{major_ver}.{minor_ver}-ck([0-9])", ck_patches)
	for matchNum, match in enumerate(matches, start=1):
		for groupNum in range(0, len(match.groups())):
			groupNum = groupNum + 1
			ck_version = match.group(groupNum)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		ck_extraversion=ck_version,
		branch_id=f"{major_ver}.{minor_ver}",
		artifacts=[
			hub.pkgtools.ebuild.Artifact(
				url=f"http://ck.kolivas.org/patches/5.0/{major_ver}.{minor_ver}/{major_ver}.{minor_ver}-ck{ck_version}/patch-{major_ver}.{minor_ver}-ck{ck_version}.xz"
			),
			hub.pkgtools.ebuild.Artifact(
				url=f"https://mirrors.edge.kernel.org/pub/linux/kernel/v{major_ver}.x/linux-{major_ver}.{minor_ver}.tar.xz"
			),
			hub.pkgtools.ebuild.Artifact(
				url=f"https://mirrors.edge.kernel.org/pub/linux/kernel/v{major_ver}.x/patch-{major_ver}.{minor_ver}.{patch_ver}.xz"
			),
		],
	)

	ebuild.push()


# vim: ts=4 sw=4 noet
