#!/usr/bin/env python3

import re


def gen_ebuild(release_data, tag_data, pkginfo, nightly=False):
	desired_tag = "nightly" if nightly else "stable"
	for release in release_data:
		if release['tag_name'] != desired_tag:
			continue
		if nightly:
			# set version to YYYYMMDD:
			version = release["published_at"].split("T")[0].replace("-","")
		else:
			# grab version from GitHub "name" field via regex:
			ver_match = re.search("([0-9.]+)", release["name"])
			if not ver_match:
				raise KeyError(f"Could not find suitable neovim stable version in name \"{release['name']}\"")
			version = ver_match.groups()[0]
		sha = next(filter(lambda tag_ent: tag_ent["name"] == desired_tag, tag_data))['commit']['sha']

		########################################################################################################
		# GitHub does not list this URL in the release's assets list, but it is always available if there is an
		# associated tag for the release. Rather than use the tag name (which would give us a non-distinct file
		# name), we use the sha1 to grab a specific URL and get a specific final name on disk for the artifact.
		########################################################################################################

		url = f"https://github.com/neovim/neovim/archive/{sha}.tar.gz"
		eb = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			stable=not nightly,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
		)
		eb.push()


async def generate(hub, **pkginfo):
	name = pkginfo["name"]
	release_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{name}/{name}/releases", is_json=True)
	tag_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{name}/{name}/tags", is_json=True)
	gen_ebuild(release_data, tag_data, pkginfo, nightly=False)
	gen_ebuild(release_data, tag_data, pkginfo, nightly=True)

# vim: ts=4 sw=4 noet tw=120
