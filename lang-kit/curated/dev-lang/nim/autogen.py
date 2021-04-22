#!/usr/bin/env python3

from packaging import version


def get_release(releases_data):
	return None if not releases_data else sorted(releases_data, key=lambda x: version.parse(x["name"])).pop()


async def generate(hub, **pkginfo):
	user = "nim-lang"
	repo = "Nim"
	name = pkginfo["name"]
	tag_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{user}/{repo}/tags", is_json=True)
	latest_tag = get_release(tag_data)
	if latest_tag is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {repo}")
	version = latest_tag["name"].lstrip("v")
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=f"https://nim-lang.org/download/{name}-{version}.tar.xz")],
	)
	ebuild.push()
