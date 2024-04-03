#!/usr/bin/env python3

from metatools.version import generic


def get_release(releases_data):
	releases = list(filter(lambda x: x["prerelease"] is False and x["draft"] is False, releases_data))
	return None if not releases else sorted(releases, key=lambda x: generic.parse(x["tag_name"])).pop()


async def generate(hub, **pkginfo):
	github_user = github_repo = pkginfo["name"]
	json_list = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True)
	latest_release = get_release(json_list)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {github_repo}")
	version = latest_release["tag_name"].lstrip("v")
	jar_asset = next(x for x in latest_release["assets"] if x["name"].endswith(".jar"))["browser_download_url"]
	jar_artifact = hub.pkgtools.ebuild.Artifact(url=jar_asset)
	icon_url = "https://raw.githubusercontent.com/ATLauncher/ATLauncher/master/src/main/resources/assets/image/icon.ico"
	icon_artifact = hub.pkgtools.ebuild.Artifact(url=icon_url, final_name=f"{github_repo}.ico")
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[jar_artifact, icon_artifact]
	)
	ebuild.push()
