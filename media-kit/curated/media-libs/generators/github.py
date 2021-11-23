#!/usr/bin/env python3

import re

async def release_gen(hub, pkginfo, json_data):
	for release in json_data:
		if release['draft'] or release['prerelease']:
			continue
		match_obj = re.search('([0-9.]+)', release['tag_name'])
		if match_obj:
			version = match_obj.groups()[0]
		else:
			continue
		archive_name = pkginfo['tarball'].format(version=version)
		for asset in release['assets']:
			if asset['name'] == archive_name:
				return version, hub.pkgtools.ebuild.Artifact(url=asset['browser_download_url'], final_name=archive_name)

async def generate(hub, **pkginfo):
	for key in [ 'user', 'repo' ]:
		if key not in pkginfo:
			if 'github' in pkginfo and key in pkginfo['github']:
				pkginfo[f'github_{key}'] = pkginfo['github'][key]
			else:
				pkginfo[f'github_{key}'] = pkginfo['name']
	query = pkginfo['github']['query']
	if query not in [ "releases", "tags" ]:
		raise KeyError(f"{pkginfo['cat']}/{pkginfo['name']} should specify GitHub query type of 'releases' or 'tags'.")
	if query == "tags":
		raise KeyError(f"{pkginfo['cat']}/{pkginfo['name']}: tags query not implemented yet.")
	github_user = pkginfo['github_user']
	github_repo = pkginfo['github_repo']
	json_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{github_user}/{github_repo}/{query}", is_json=True)
	result = await release_gen(hub, pkginfo, json_data)
	if result is None:
		raise KeyError(f"Unable to find suitable release for {pkginfo['cat']}/{pkginfo['name']}.")
	version, artifact = result
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[artifact],
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
