#!/usr/bin.env python3

from packaging import version
import re


def get_release(releases_data):
	releases = list(filter(lambda x: x["prerelease"] is False and x["draft"] is False, releases_data))
	return None if not releases else sorted(releases, key=lambda x: version.parse(x["tag_name"])).pop()


async def generate(hub, **pkginfo):
	user = "SuperTux"
	repo = pkginfo["name"]
	releases_data = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/releases", is_json=True
	)
	latest_release = get_release(releases_data)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {name}")
	tag_name = latest_release["tag_name"]
	version = tag_name.lstrip("v")
	source_name = f"{user}-{tag_name}-Source"
	artifact_name = f"{source_name}.tar.gz"
	source_asset = next(asset for asset in latest_release["assets"] if asset["name"] == artifact_name)
	url = source_asset["browser_download_url"]
	final_name = f"{repo}-{version}.tar.gz"
	src_artifact = hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		source_name=source_name,
		artifacts=[src_artifact],
	)
	ebuild.push()
