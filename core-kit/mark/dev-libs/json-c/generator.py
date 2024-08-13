#!/usr/bin/env python3

import glob
import re
import os.path
from packaging.version import Version
from metatools.generator.transform import RegexMatcher, VersionMatch

async def generate(hub, **pkginfo):
	github_user = pkginfo["github"]["user"]
	github_repo = pkginfo["github"].get("repo") or pkginfo["name"]

	extra_args = {}
	if "select" in pkginfo["github"]:
		extra_args["select"] = pkginfo["github"]["select"]
		extra_args["matcher"] = RegexMatcher(regex=VersionMatch.GRABBY)

	newpkginfo = await hub.pkgtools.github.tag_gen(hub, github_user, github_repo, **extra_args)
	pkginfo.update(newpkginfo)

	if "select" in pkginfo["github"]:
		pkgver = Version(pkginfo["tag"].split(f"{github_user}-")[1])
		if pkgver.post:
			pkginfo["version"] = f"{pkgver.base_version}_p{pkgver.post}"
		else:
			pkginfo["version"] = pkgver

	# "subslot: True" just means that we want to subslot
	if pkginfo['subslot'] == True:

		artifact = pkginfo['artifacts'][0]
		await artifact.ensure_fetched()
		artifact.extract()

		found_cmake = glob.glob(os.path.join(artifact.extract_path, f"{github_user}-{github_repo}-*", "CMakeLists.txt"))
		if found_cmake:
			cmake_file = open(found_cmake[0]).read()
			soversion = re.search("SOVERSION\s*([0-9]+)", cmake_file)
		else:
			# For versions that use autotools instead of CMake
			found_makefile_am = glob.glob(os.path.join(artifact.extract_path, f"{github_user}-{github_repo}-*", "Makefile.am"))
			if found_makefile_am:
				makefile_am = open(found_makefile_am[0]).read()
				soversion = re.search("libjson_c_la_LDFLAGS\s*=\s*-version-info\s*([0-9]+)", makefile_am)
			else:
				soversion = None

		artifact.cleanup()


		if soversion is not None:
			pkginfo['slot'] = f'0/{soversion.group(1)}'
		else:
			hub.pkgtools.model.log.warning(f'Cannot determine the SONAME. Setting subslot to "0".')
			pkginfo['slot'] = "0/0"
	else:
		pkginfo['slot'] = "0"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=github_user,
		github_repo=github_repo,
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
