#!/usr/bin/env python3

import glob
import re
import os.path
from packaging.version import Version


async def generate(hub, **pkginfo):
	github_user = pkginfo["github"]["user"]
	github_repo = pkginfo["github"].get("repo") or pkginfo["name"]

	extra_args = {}
	newpkginfo = await hub.pkgtools.github.tag_gen(hub, github_user, github_repo, **extra_args)
	pkginfo.update(newpkginfo)

	artifact = pkginfo['artifacts'][0]
	await artifact.fetch()
	artifact.extract()

	print(artifact.extract_path, github_user, github_repo)

	conf_file = open(
		glob.glob(os.path.join(artifact.extract_path, f"{github_user}-{github_repo}-*", "configure.ac"))[0]).read()
	soversion = re.search("LIBCRYPTSETUP_VERSION_INFO=([0-9:]+)", conf_file)
	pkginfo['subslot'] = soversion.group(1).split(':')[-1]
	artifact.cleanup()

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=github_user,
		github_repo=github_repo,
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
