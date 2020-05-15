#!/usr/bin/env python3

import json

async def generate(hub, **pkginfo):

	json_data = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/git/git/tags")
	json_list = json.loads(json_data)
	for tag in json_list:
		v = tag['name'].lstrip('v')

		# Sanity checks:
		#
		# 1) Version 2.something.
		# 2) At least minor version 26 (2.26+) to skip LTS releases
		# 3) No release candidates.

		vsplit = v.split('.')
		if len(vsplit) != 3:
			continue
		if vsplit[0] != '2':
			continue
		try:
			minor = int(vsplit[1])
		except:
			continue
		if minor < 26:
			continue
		if "-rc" in v:
			continue
		version = v
		break

	kernel_org='https://www.kernel.org/pub/software/scm/git'
	artifacts=[
		hub.pkgtools.ebuild.Artifact(url=f'{kernel_org}/git-{version}.tar.xz'),
		hub.pkgtools.ebuild.Artifact(url=f'{kernel_org}/git-manpages-{version}.tar.xz')
	]

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=artifacts
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
