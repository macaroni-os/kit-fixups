#!/usr/bin/env python3

from distutils.version import LooseVersion


def get_release(releases_data):
	releases = list(filter(lambda x: x["prerelease"] is False and x["draft"] is False, releases_data))
	return None if not releases else sorted(releases, key=lambda x: LooseVersion(x["tag_name"])).pop()


async def generate(hub, **pkginfo):
	user = "jgm"
	repo = pkginfo["name"].rstrip("-bin")
	releases_data = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/releases", is_json=True
	)
	latest_release = get_release(releases_data)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {repo}")
	version = latest_release["tag_name"]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(
				url=f"https://github.com/{user}/{repo}/releases/download/{version}/{repo}-{version}-linux-amd64.tar.gz"
			)
		],
	)
	ebuild.push()
