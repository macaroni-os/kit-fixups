#!/usr/bin/env python3

import json
from datetime import timedelta

def find_release(json_dict, channel='Release'):
	releases = filter(lambda x: x['name'].startswith(f"{channel} Channel") and x['prerelease'] is False and not x['name'].endswith('-android'), json_dict)
	releases = list(releases)
	if not len(releases):
		return None
	return sorted(releases, key=lambda x: x['tag_name'])[-1]

async def generate(hub, **pkginfo):

	json_dict = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/brave/brave-browser/releases", is_json=True, refresh_interval=timedelta(days=5))

	# Try to use the latest release version, but fall back to latest nightly if none found:
	release = None
	for channel in [ 'Release', 'Beta', 'Nightly' ]:
		release = find_release(json_dict, channel=channel)
		if release:
			break

	if release is None:
		raise hub.pkgtools.ebuild.BreezyError("Can't find a suitable release of Brave.")

	version = release['tag_name'][1:] # strip leading 'v'

	url = list(filter(lambda x: x['browser_download_url'].endswith('-linux-x64.zip'), release['assets']))[0]['browser_download_url']

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=url)
		]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
