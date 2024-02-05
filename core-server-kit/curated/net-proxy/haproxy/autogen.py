#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	supported_branches = [
		"2.9",
		"2.8",
		"2.7",
		"2.6",
		"2.4",
	]

	for branch in supported_branches:

		url_prefix=f"http://www.haproxy.org/download/{branch}/src"

		json_data = await hub.pkgtools.fetch.get_page(
			f"{url_prefix}/releases.json", is_json=True
		)
		pv=json_data['latest_release']
		tarball=json_data["releases"][pv]["file"]
		url=f"{url_prefix}/{tarball}"

		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=pv,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
		)

		ebuild.push()


# vim: ts=4 sw=4 noet
