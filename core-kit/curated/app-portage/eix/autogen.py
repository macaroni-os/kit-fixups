#!/usr/bin/env python3


async def generate(hub, **pkginfo):

	github_user = "vaeth"
	github_repo = "eix"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)

	for rel in json_list:
		if rel["draft"] != False or rel["prerelease"] != False:
			continue

		version = rel["tag_name"].lstrip("v")
		final_name = f"eix-{version}.tar.xz"
		url = f"https://github.com/vaeth/eix/releases/download/v{version}/{final_name}"
		break

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
