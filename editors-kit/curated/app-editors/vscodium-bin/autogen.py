#!/usr/bin/env python3

from distutils.version import LooseVersion


def get_release(releases_data):
	bad_versions = ["1.55.1"]
	releases = list(filter(lambda x: x["prerelease"] is False and x["draft"] is False and x["tag_name"] not in bad_versions, releases_data))
	return None if not releases else sorted(releases, key=lambda x: LooseVersion(x["tag_name"])).pop()


async def generate(hub, **pkginfo):
	user = "VSCodium"
	name = pkginfo["name"]
	repo = name.rstrip("-bin")
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
				url=f"https://github.com/{user}/{repo}/releases/download/{version}/{user}-linux-x64-{version}.tar.gz",
				final_name=f"{name}-{version}.tar.gz",
			)
		],
	)
	ebuild.push()
