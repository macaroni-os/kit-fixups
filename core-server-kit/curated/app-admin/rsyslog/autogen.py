#!/usr/bin/env python3

async def generate(hub, **pkginfo):
	github_user = pkginfo['name']
	github_repo = pkginfo['name']
	newpkginfo = await hub.pkgtools.github.tag_gen(hub, github_user, github_repo)
	docpkginfo = await hub.pkgtools.github.tag_gen(hub, github_user, github_repo + "-doc")

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version = newpkginfo['version'],
		github_user=github_user,
		github_repo=github_repo,
		artifacts=dict([('src', newpkginfo['artifacts'][0]), ('doc', docpkginfo['artifacts'][0])])
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
