#!/usr/bin/env python3

from metatools.version import generic
import re


def get_release(releases_data):
	releases = list(filter(lambda x: x["prerelease"] is False and x["draft"] is False, releases_data))
	return None if not releases else sorted(releases, key=lambda x: generic.parse(x["tag_name"])).pop()


async def generate(hub, **pkginfo):
	name = "fish-shell"
	ebuild_name = pkginfo["name"]
	releases_data = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{name}/{name}/releases", is_json=True
	)
	latest_release = get_release(releases_data)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {name}")
	version = latest_release["tag_name"]
	name_pattern = re.compile(f"({ebuild_name}-{version}\\.tar\\.[^.]+$)")
	asset_matches = [(x, name_pattern.match(x["name"])) for x in latest_release["assets"]]
	source_assets = [x for x, y in asset_matches if y]
	target_asset = source_assets.pop()
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=target_asset["browser_download_url"])],
	)
	ebuild.push()
