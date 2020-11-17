#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	user = "arvidn"
	repo = "libtorrent"
	app = pkginfo["name"]
	last_api = "v1.2"
	last_api_ver = None
	version = []
	url = []
	json_list = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{user}/{repo}/releases", is_json=True)
	for release in json_list:
		if release["prerelease"]:
			continue
		if release["draft"]:
			continue
		version.append(release["tag_name"].lstrip("v"))
		if last_api in release["tag_name"] and last_api_ver is None:
			last_api_ver = release["tag_name"].lstrip("v")
		url.append(
			list(filter(lambda x: x["browser_download_url"].endswith("tar.gz"), release["assets"]))[0]["browser_download_url"]
		)
	final_name = f"{app}-{version[0]}.tar.gz"
	last_api_name = f"{app}-{last_api_ver}.tar.gz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version[0], artifacts=[hub.pkgtools.ebuild.Artifact(url=url[0], final_name=final_name)]
	)
	ebuild.push()
	last_api_ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=last_api_ver,
		template=app + "-last_api.tmpl",
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url[version.index(last_api_ver)], final_name=last_api_name)],
	)
	last_api_ebuild.push()


# vim: ts=4 sw=4 noet
