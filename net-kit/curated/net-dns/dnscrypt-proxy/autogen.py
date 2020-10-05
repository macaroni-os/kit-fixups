#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	github_user = "DNSCrypt"
	github_repo = "dnscrypt-proxy"
	json_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{github_user}/{github_repo}/releases")
	json_list = json.loads(json_data)
	for release in json_list:
		if release["prerelease"] or release["draft"]:
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
