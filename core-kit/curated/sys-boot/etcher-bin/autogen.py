#!/usr/bin/env python3

from packaging import version


def get_release(releases_data):
	stable_releases = list(filter(lambda x: x["prerelease"] is False and x["draft"] is False, releases_data))
	releases = list(release for release in stable_releases for assets in release["assets"] if "_amd64.deb" in assets["name"])
	return None if not releases else sorted(releases, key=lambda x: version.parse(x["tag_name"])).pop()


async def generate(hub, **pkginfo):
	user = "balena-io"
	name = pkginfo["name"]
	repo = name.rstrip("-bin")
	releases_data = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/releases", is_json=True
	)
	latest_release = get_release(releases_data)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {repo}")
	version = latest_release["tag_name"]
	ebuild_version = version.lstrip("v")
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=ebuild_version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(
				url=f"https://github.com/balena-io/{repo}/releases/download/{version}/balena-{repo}-electron_{ebuild_version}_amd64.deb",
				final_name=f"{name}-{ebuild_version}.deb",
			)
		],
	)
	ebuild.push()
