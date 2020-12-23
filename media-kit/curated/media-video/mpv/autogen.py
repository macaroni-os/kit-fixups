#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	python_compat = "python3+"
	github_user = "mpv-player"
	github_repo = "mpv"
	waf_version = "2.0.20"
	json_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{github_user}/{github_repo}/releases")
	json_list = json.loads(json_data)
	for release in json_list:
		if release["prerelease"] or release["draft"]:
			continue
		version = release["tag_name"].lstrip("v")
		url = release["tarball_url"]
		break
	final_name = f'{pkginfo["name"]}-{version}.tar.gz'
	waf_url = f"https://waf.io/waf-{waf_version}"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		python_compat=python_compat,
		github_user=github_user,
		github_repo=github_repo,
		waf_version=waf_version,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name),
			hub.pkgtools.ebuild.Artifact(url=waf_url),
		],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
