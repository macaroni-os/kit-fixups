#!/usr/bin/env python3


async def generate(hub, **pkginfo):

	github_user = "weechat"
	github_repo = "weechat"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)

	for rel in json_list:
		version = rel["tag_name"][1:]
		if rel["draft"] == False and rel["prerelease"] == False:
			break

	final_name = f"weechat-{version}.tar.gz"
	url = f"https://weechat.org/files/src/{final_name}"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		python_compat="python3+",
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
