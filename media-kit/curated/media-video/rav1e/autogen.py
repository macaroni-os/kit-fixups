#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):
	github_user = "xiph"
	github_repo = pkginfo['name']
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases?per_page=100", is_json=True
	)
	for release in json_list:
		if release['prerelease']:
			continue
		if release['draft']:
			continue
		latest_release = release
		break
	version = latest_release['tag_name'].lstrip("v")
	beta_match = re.match("(.*)-beta\\.([0-9])+", version)
	if beta_match is not None:
		gp = beta_match.groups()
		version = gp[0] + "_beta" + gp[1]
	url = latest_release['tarball_url']
	final_name = f"{github_repo}-{version}.tar.gz"
	src_artifact = hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)
	artifacts = await hub.pkgtools.rust.generate_crates_from_artifact(src_artifact)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		crates=artifacts['crates'],
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[
			src_artifact,
			*artifacts['crates_artifacts'],
		],
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
