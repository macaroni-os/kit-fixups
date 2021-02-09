#!/usr/bin/env python3

from datetime import timedelta

GITHUB_RELEASES_JSON = "https://api.github.com/repos/irssi/irssi/releases"


def get_release(parsed_json):
	releases = filter(
		lambda x: x["prerelease"] is False and x["draft"] is False,
		parsed_json,
	)
	releases = list(releases)
	if not len(releases):
		return None
	return sorted(releases, key=lambda x: x["tag_name"]).pop()


def get_artifact(hub, dl_assets):
	artifact_name = "irssi"
	extension = "tar.xz"
	dl_asset = list(
		filter(
			lambda x: x["name"].startswith(artifact_name) and x["name"].endswith(extension),
			dl_assets,
		)
	).pop()
	return hub.pkgtools.ebuild.Artifact(url=dl_asset["browser_download_url"])


async def generate(hub, **pkginfo):
	parsed_json = await hub.pkgtools.fetch.get_page(
		GITHUB_RELEASES_JSON, is_json=True, refresh_interval=timedelta(days=5)
	)
	release = get_release(parsed_json)
	if release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {GITHUB_RELEASE_NAME}")
	version = release["tag_name"]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[get_artifact(hub, release["assets"])],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
