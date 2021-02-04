#!/usr/bin/env python3


async def generate(hub, **pkginfo):

	github_user = "tmux"
	github_repo = "tmux"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)

	for rel in json_list:
		version = rel["tag_name"]
		if rel["draft"] == False and rel["prerelease"] == False:
			break

	final_name = f"tmux-{version}.tar.gz"
	url = f"https://github.com/{github_user}/{github_repo}/releases/download/{version}/{final_name}"

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
