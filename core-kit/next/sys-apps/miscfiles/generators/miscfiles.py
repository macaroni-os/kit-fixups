#!/usr/bin/env python3

import re

async def generate(hub, **pkginfo):

	if 'version' not in pkginfo or 'latest' in pkginfo['version']:
		release_data = await hub.pkgtools.fetch.get_page( pkginfo['dir']['url'], is_json=False )
		releases = re.findall(
			f'(?<=href="{pkginfo["name"]}-)\d+(?:\.\d+)+(?=\.tar\.gz"|\.tar\.bz2"|\.tar\.xz|\.zip")',
			release_data
		)

		if not releases:
			raise KeyError(f"Unable to find a suitable version for {pkginfo['cat']}-{pkginfo['name']}.")

		# Some directories listings are ordered ascending from oldest to newest,
		# some list files descending from newest to oldest. We want the newest file
		# (the first one in 'descending' listing or the last in 'ascending' ones.
		if 'order' in pkginfo['dir'] and 'asc' in pkginfo['dir']['order']:
			pkginfo['version'] = releases[-1]
		else:
			pkginfo['version'] = releases[0]

	artifacts = []

	artifacts.append(
		hub.pkgtools.ebuild.Artifact(
			url = f"{pkginfo['dir']['url']}{pkginfo['name']}-{pkginfo['version']}.{pkginfo['dir']['format']}"
		)
	)

	if 'additional_artifacts' in pkginfo:
		for url in pkginfo['additional_artifacts']:
			artifacts.append(
				hub.pkgtools.ebuild.Artifact(url)
			)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		artifacts=artifacts
	)
	ebuild.push()


# vim: sw=4 ts=4 noet
