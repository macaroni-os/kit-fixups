#!/usr/bin/env python3

import json
from packaging import version

async def get_latest_tag(hub, github_user, github_repo):

	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True
	)

	tags = []
	for rel in json_list:
		v = version.parse(rel["name"])
		if v.is_prerelease or isinstance(v, version.LegacyVersion):
			continue
		tags.append(v)

	return None if not tags else str(sorted(tags).pop())

async def generate(hub, **pkginfo):

	github_user = "kilobyte"
	github_repo = pkginfo["name"]

	tag = await get_latest_tag(hub, github_user, github_repo)

	if tag is None or tag == "":
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a latest tag of {pkginfo['cat']}/{pkginfo['name']}")

	final_name = f"{pkginfo['name']}-{tag}.tar.gz"
	url = f"https://github.com/{github_user}/{github_repo}/archive/v{tag}.tar.gz"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=tag,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
