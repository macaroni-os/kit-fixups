#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	github_user = "nm-l2tp"
	github_repo = "NetworkManager-l2tp"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)
	for release in json_list:
		if "prerelease" in release and release["prerelease"] is not False:
			continue
		if "draft" in release and release["draft"] is not False:
			continue
		version = release["tag_name"]
		url = release["tarball_url"]
		break
	final_name = f'{pkginfo["name"]}-{version}.tar.gz'
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=github_user,
		github_repo=github_repo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
