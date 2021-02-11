#!/usr/bin/env python3

import json
import re
import glob
import os

GITHUB_USER = "freedesktop"
GITHUB_REPO = "poppler"

# mimic the Portage package name variable for clarity in the tarball renaming
PN = GITHUB_REPO


async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{GITHUB_USER}/{GITHUB_REPO}/tags")
	tags = json.loads(json_data)
	# need this for tag matching due to tag [0] not being the current
	for tag in tags:
		if not re.match("poppler-[0-9.]+", tag["name"]):
			continue
		version = tag["name"].lstrip("poppler-")
		tarball_url = tag["tarball_url"]
		artifact = hub.pkgtools.ebuild.Artifact(tarball_url)
		break
	await artifact.fetch()
	artifact.extract()
	# needed for subslot changes in the future
	cmake_file = open(
		glob.glob(os.path.join(artifact.extract_path, f"{GITHUB_USER}-{GITHUB_REPO}-*", "CMakeLists.txt"))[0]
	).read()
	soversion = re.search("SOVERSION ([0-9]+)", cmake_file)
	subslot = soversion.group(1)
	template_args = dict(GITHUB_USER=GITHUB_USER, GITHUB_REPO=GITHUB_REPO, subslot=subslot)
	artifact.cleanup()
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=tarball_url, final_name=f"{PN}-{version}.tar.gz"),
		],
		**template_args,
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
