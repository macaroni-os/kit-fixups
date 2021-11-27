#!/usr/bin/env python3

import re

async def release_gen(hub, github_user, github_repo, release_data, tarball=None):
	for release in release_data:
		if release['draft'] or release['prerelease']:
			continue
		match_obj = re.search('([0-9.]+)', release['tag_name'])
		if match_obj:
			version = match_obj.groups()[0]
		else:
			continue
		if tarball:
			# We are looking for a specific tarball:
			archive_name = tarball.format(version=version)
			for asset in release['assets']:
				if asset['name'] == archive_name:
					return {
						"version" : version,
						"artifacts" : [hub.pkgtools.ebuild.Artifact(url=asset['browser_download_url'], final_name=archive_name)]
					}
		else:
			# We want to grab the default tarball for the associated tag:
			desired_tag = release['tag_name']
			tag_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True)
			sha = next(filter(lambda tag_ent: tag_ent["name"] == desired_tag, tag_data))['commit']['sha']

			########################################################################################################
			# GitHub does not list this URL in the release's assets list, but it is always available if there is an
			# associated tag for the release. Rather than use the tag name (which would give us a non-distinct file
			# name), we use the sha1 to grab a specific URL and use a specific final name on disk for the artifact.
			########################################################################################################

			url = f"https://github.com/{github_user}/{github_repo}/tarball/{sha}"
			return {
				"version" : version,
				"artifacts" : [hub.pkgtools.ebuild.Artifact(url=url, final_name=f'{github_repo}-{version}-{sha[:7]}.tar.gz')],
				"sha" : sha
			}

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
	result = await release_gen(hub, github_user, github_repo, json_data, tarball=pkginfo.get('tarball', None))
	if result is None:
		raise KeyError(f"Unable to find suitable release for {pkginfo['cat']}/{pkginfo['name']}.")
	# Add in our new dict elements:
	pkginfo.update(result)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo)
	ebuild.push()

# vim: ts=4 sw=4 noet
