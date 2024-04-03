#!/usr/bin/env python3

from metatools.version import generic


def get_release(releases_data):
	return None if not releases_data else sorted(releases_data, key=lambda x: generic.parse(x["name"])).pop()


async def generate(hub, **pkginfo):
	removal_list = ["_flameshot"]
	user = "zsh-users"
	repo = pkginfo["name"]
	releases_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{user}/{repo}/tags", is_json=True)
	latest_release = get_release(releases_data)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {repo}")
	version = latest_release["name"]
	ebuild_version = version.lstrip("v")
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=ebuild_version,
		removal_list=removal_list,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=f"https://github.com/{user}/{repo}/archive/refs/tags/{version}.tar.gz")],
	)
	ebuild.push()
