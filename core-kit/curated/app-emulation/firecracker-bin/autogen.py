#!/usr/bin/env python3

from datetime import timedelta

GITHUB_RELEASE_NAME = "Firecracker"
GITHUB_RELEASES_JSON = "https://api.github.com/repos/firecracker-microvm/firecracker/releases"
ARCH_MAP = {
	# funtoo_arch: firecracker_arch
	"amd64": "x86_64",
	"arm64": "aarch64",
}


def get_release(parsed_json):
	releases = filter(
		lambda x: x["prerelease"] is False and x["draft"] is False and x["name"].startswith(GITHUB_RELEASE_NAME),
		parsed_json,
	)
	releases = list(releases)
	if not len(releases):
		return None
	return sorted(releases, key=lambda x: x["tag_name"]).pop()


def get_artifact(hub, release, funtoo_arch):
	try:
		firecracker_arch = ARCH_MAP[funtoo_arch]
	except KeyError:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find firecracker arch for {funtoo_arch}")
	dl_asset = list(
		filter(
			lambda x: firecracker_arch in x["name"] and x["name"].endswith(".tgz"),
			release["assets"],
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
	version = release["tag_name"][1:]  # strip leading 'v'
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[
			get_artifact(hub, release, "amd64"),
			get_artifact(hub, release, "arm64"),
		],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
