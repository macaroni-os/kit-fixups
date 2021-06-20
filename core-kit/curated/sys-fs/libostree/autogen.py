#!/usr/bin/env python3


async def generate(hub, **pkginfo):

	github_user = "ostreedev"
	github_repo = "ostree"
	app = pkginfo["name"]
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True
	)
	for tag in json_list:
		version = tag["name"].replace("v", "")
		url = f"https://github.com/{github_user}/{github_repo}/releases/download/v{version}/{app}-{version}.tar.xz"
		break

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
