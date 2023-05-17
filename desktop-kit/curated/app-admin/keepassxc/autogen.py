#!/usr/bin/env python3

from packaging.version import Version

revision = {"2.7.5": 1}


async def generate(hub, **pkginfo):
	github_user = "keepassxreboot"
	github_repo = pkginfo["name"]

	newpkginfo = await hub.pkgtools.github.release_gen(hub, github_user, github_repo, tarball="keepassxc-{version}-src.tar.xz")
	version = Version(newpkginfo["version"])

	if version.major >= 2 and version.minor >= 7 and version.micro >= 5:
		botan = 3
	else:
		botan = 2

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		revision=revision,
		botan=botan,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=newpkginfo["artifacts"],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
