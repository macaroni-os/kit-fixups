#!/usr/bin/env python3

async def generate(hub, **pkginfo):
	github_info = await hub.pkgtools.github.release_gen(hub, "flatpak", "flatpak", tarball="flatpak-{version}.tar.xz", sort=hub.pkgtools.github.SortMethod.VERSION)
	pkginfo.update(github_info)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo)
	ebuild.push()

# vim: ts=4 sw=4 noet
