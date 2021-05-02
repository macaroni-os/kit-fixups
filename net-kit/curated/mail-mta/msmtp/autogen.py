#!/usr/bin/env python3

from packaging import version


async def get_latest_version(hub, url):

	tags_list = await hub.pkgtools.fetch.get_page(url, is_json=True)
	tags = sorted(
		filter(
			lambda t: t.startswith("msmtp-"),
			[t["name"] for t in tags_list]
		),
		key=lambda t: version.parse(t.lstrip("msmtp-"))
	)

	return None if not tags else tags.pop().lstrip("msmtp-")


async def generate(hub, **pkginfo):

	github_user = "marlam"
	github_repo = "msmtp-mirror"
	latest_version = await get_latest_version(
		hub,
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags"
	)

	if latest_version is None:
		raise hub.pkgtools.ebuild.BreezyError(
			f"Can't find a latest version of {pkginfo['cat']}/{pkginfo['name']}"
		)

	url = f"https://marlam.de/msmtp/releases/{pkginfo['name']}-{latest_version}.tar.xz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=latest_version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
