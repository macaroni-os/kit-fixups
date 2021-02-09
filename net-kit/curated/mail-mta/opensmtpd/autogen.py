#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):

	github_user = "OpenSMTPD"
	github_repo = "OpenSMTPD"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)

	for rel in json_list:
		if rel["draft"] != False or rel["prerelease"] != False:
			continue

		version = rel["tag_name"].lstrip("v")
		final_name = f"opensmtpd-{version}.tar.gz"
		url = f"https://www.opensmtpd.org/archives/{final_name}"
		break

	# last "p" needs to be separated by "_"
	version = re.sub("(p\d+)$", r"_\1", version)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
