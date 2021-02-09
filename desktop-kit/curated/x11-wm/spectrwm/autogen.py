#!/usr/bin/env python3

from datetime import timedelta


async def generate(hub, **pkginfo):
	github_user = "conformal"
	github_repo = "spectrwm"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases",
		is_json=True,
		refresh_interval=timedelta(days=5),
	)
	for release in json_list:
		if release["prerelease"] or release["draft"]:
			continue
		ver_list = release["tag_name"].split("_")
		version = f"{ver_list[1]}.{ver_list[2]}.{ver_list[3]}"
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
