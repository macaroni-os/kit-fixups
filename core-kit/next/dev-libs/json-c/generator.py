#!/usr/bin/env python3

import glob
import re
import os.path
from packaging.version import Version


async def generate(hub, **pkginfo):
	github_user = pkginfo["github"]["user"]
	github_repo = pkginfo["github"].get("repo") or pkginfo["name"]

	extra_args = {}
	if "select" in pkginfo["github"]:
		extra_args["select"] = pkginfo["github"]["select"]
		extra_args["matcher"] = hub.pkgtools.github.RegexMatcher(regex=hub.pkgtools.github.VersionMatch.GRABBY)

	newpkginfo = await hub.pkgtools.github.tag_gen(hub, github_user, github_repo, **extra_args)
	pkginfo.update(newpkginfo)

	if "select" in pkginfo["github"]:
		pkgver = Version(pkginfo["tag"].split(f"{github_user}-")[1])
		if pkgver.post:
			pkginfo["version"] = f"{pkgver.base_version}_p{pkgver.post}"
		else:
			pkginfo["version"] = pkgver

	artifact = pkginfo['artifacts'][0]
	await artifact.fetch()
	artifact.extract()

	cmake_file = open(
		glob.glob(os.path.join(artifact.extract_path, f"{github_user}-{github_repo}-*", "CMakeLists.txt"))[0]).read()
	soversion = re.search("SOVERSION ([0-9]+)", cmake_file)
	pkginfo['subslot'] = soversion.group(1)
	artifact.cleanup()

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=github_user,
		github_repo=github_repo,
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
