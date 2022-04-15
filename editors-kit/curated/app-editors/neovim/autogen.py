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
			ver_match = re.search("NVIM v([0-9.]+)", release["body"])
			if not ver_match:
				print(release["body"])
				raise KeyError(f"Could not find suitable neovim stable version in body \"{release['body']}\"")
			version = ver_match.groups()[0]
			# NeoVim now seems to be tagging like "v{version}"
			desired_tag = f"v{version}"
		try:
			sha = next(filter(lambda tag_ent: tag_ent["name"] == desired_tag, tag_data))['commit']['sha']
		except StopIteration:
			return False
		########################################################################################################
		# GitHub does not list this URL in the release's assets list, but it is always available if there is an
		# associated tag for the release. Rather than use the tag name (which would give us a non-distinct file
		# name), we use the sha1 to grab a specific URL and use a specific final name on disk for the artifact.
		########################################################################################################

		url = f"https://github.com/neovim/neovim/archive/{sha}.tar.gz"
		final_name = f"neovim-{version}-{sha}.tar.gz"
		eb = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			stable=not nightly,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
		)
		eb.push()
		return True


async def generate(hub, **pkginfo):
	name = pkginfo["name"]
	release_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{name}/{name}/releases", is_json=True)
	tag_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{name}/{name}/tags", is_json=True)
	result = gen_ebuild(release_data, tag_data, pkginfo, nightly=False)
	if not result:
		raise hub.pkgtools.ebuild.BreezyError("Unable to generate official neovim release.")
	gen_ebuild(release_data, tag_data, pkginfo, nightly=True)

# vim: ts=4 sw=4 noet tw=120
