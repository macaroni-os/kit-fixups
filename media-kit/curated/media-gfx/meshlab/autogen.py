#!/usr/bin/env python3

from packaging.version import Version

async def generate(hub, **pkginfo):
	github_user = "cnr-isti-vclab"
	github_repo = pkginfo["name"]
	github_repo2 = "vcglib"

	newpkginfo = await hub.pkgtools.github.release_gen(hub, github_user, github_repo)
	version = Version(newpkginfo["version"])

	# now get vcglib
	libpkginfo = await hub.pkgtools.github.release_gen(hub, github_user, github_repo2, select=f"{version.major}+")



	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		github_repo2=github_repo2,
		artifacts=newpkginfo["artifacts"] + libpkginfo["artifacts"],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
