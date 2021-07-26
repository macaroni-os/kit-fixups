#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	github_user = "NVIDIA"
	github_repo = "nvidia-docker"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)
	latest_release = None
	for release in json_list:
		for key in ["prerelease", "draft"]:
			if release[key] is True:
				continue
		latest_release = release
		break
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {github_repo}")
	tag = latest_release["tag_name"]
	version = tag.lstrip("v")
	src_artifact = hub.pkgtools.ebuild.Artifact(
		url=f"https://github.com/{github_user}/{github_repo}/archive/{tag}.tar.gz",
		final_name=f"{github_repo}-{version}.tar.gz",
	)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, github_user=github_user, github_repo=github_repo, artifacts=[src_artifact]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
