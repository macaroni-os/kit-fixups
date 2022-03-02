#!/usr/bin/env python3

import re

# We have seen a new "3.0-alpha0" tag -- so this may be changing:
v_pattern="v([0-9.]+)"

async def generate(hub, **pkginfo):
	project_id = "6"
	tags_data = await hub.pkgtools.fetch.get_page(
		f"https://gitlab.nic.cz/api/v4/projects/{project_id}/repository/tags", is_json=True
	)
	for tag in tags_data:
		match = re.match(v_pattern, tag["name"])
		if not match:
			continue
		version = match.groups()[0]
		break
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(
				url=f"https://bird.network.cz/download/bird-{version}.tar.gz",
				final_name=f"bird-{version}.tar.gz",
			)
		],
	)
	ebuild.push()
