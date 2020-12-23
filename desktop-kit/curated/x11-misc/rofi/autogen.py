#!/usr/bin/env python3

import json


def get_release(releases_data):
	releases = list(filter(lambda x: x["prerelease"] is False and x["draft"] is False, releases_data))
	return None if not releases else sorted(releases, key=lambda x: x["tag_name"]).pop()


def get_source_url(latest_release):
	assets = list(filter(lambda x: ".tar.gz" in x["name"], latest_release["assets"]))
	return None if not assets else assets.pop()["browser_download_url"]


async def generate(hub, **pkginfo):
	user = "davatorium"
	repo = pkginfo["name"]
	releases_data = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/releases", is_json=True
	)
	latest_release = get_release(releases_data)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {repo}")
	version = latest_release["tag_name"]
	source_url = get_source_url(latest_release)
	if source_url is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find source URL for {repo} {version}")
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=source_url)],
	)
	ebuild.push()
