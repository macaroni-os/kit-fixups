#!/usr/bin/env python3

import re
from packaging import version


def get_release(release_data):
	releases = list(filter(lambda x: x["prerelease"] is False and x["draft"] is False, release_data))
	return None if not releases else sorted(releases, key=lambda x: version.parse(x["tag_name"])).pop()


async def generate(hub, **pkginfo):
	user = "caddyserver"
	repo = pkginfo["name"]
	json_dict = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{user}/{repo}/releases", is_json=True)
	latest_release = get_release(json_dict)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {repo}")
	tag = latest_release["tag_name"]
	version = pkginfo['version'] = tag.lstrip('v')
	pkginfo['artifacts'] = { 'main' : hub.pkgtools.ebuild.Artifact(url=f"https://github.com/{user}/{repo}/archive/{tag}.tar.gz", final_name=f"{repo}-{version}.tar.gz") }
	await hub.pkgtools.golang.add_gosum_bundle(hub, pkginfo)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo)
	ebuild.push()
