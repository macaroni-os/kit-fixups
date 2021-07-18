#!/usr/bin/env python3

import re


def get_release(release_data):
	releases = list(filter(lambda x: x["prerelease"] is False and x["draft"] is False, release_data))
	return None if not releases else sorted(releases, key=lambda x: x["tag_name"]).pop()


async def generate(hub, **pkginfo):
	user = "darktable-org"
	repo = pkginfo["name"]
	json_dict = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{user}/{repo}/releases", is_json=True)
	latest_release = get_release(json_dict)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {repo}")
	version = latest_release["tag_name"].lstrip("release-")
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(
				url=f"https://github.com/{user}/{repo}/releases/download/release-{version}/{repo}-{version}.tar.xz"
			)
		],
	)
	ebuild.push()
