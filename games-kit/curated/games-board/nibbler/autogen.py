#!/usr/bin/env python3


def get_release(releases_data):
	releases = list(filter(lambda x: x["prerelease"] is False and x["draft"] is False and "-rc" not in x["tag_name"], releases_data))
	return None if not releases else releases[0]


async def generate(hub, **pkginfo):
	user = "fohristiwhirl"
	repo = pkginfo["name"]
	releases_data = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/releases", is_json=True
	)
	latest_release = get_release(releases_data)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {repo}")
	version = latest_release["tag_name"]
	ebuild_version = version.lstrip("v").rstrip("-hotfix")
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=ebuild_version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(
				url=f"https://github.com/{user}/{repo}/releases/download/{version}/nibbler-{ebuild_version}-linux.zip"
			)
		],
	)
	ebuild.push()
