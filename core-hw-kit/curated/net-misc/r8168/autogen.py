#!/usr/bin/env python3

import json

GITHUB_REPO = "r8168"
GITHUB_USER = "mtorromeo"

# mimic the Portage package name variable for clarity in the tarball renaming
PN = GITHUB_REPO


async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{GITHUB_USER}/{GITHUB_REPO}/tags")
	tags = json.loads(json_data)
	# the latest tag is the first dict in the returned list of tag dicts
	version = tags[0].get("name")
	tarball_url = tags[0].get("tarball_url")
	template_args = dict(
		GITHUB_USER=GITHUB_USER,
	)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=tarball_url, final_name=f"{PN}-{version}.tgz"),
		],
		**template_args,
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
