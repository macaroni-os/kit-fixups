#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	project_id = "6"
	tags_data = await hub.pkgtools.fetch.get_page(
		f"https://gitlab.nic.cz/api/v4/projects/{project_id}/repository/tags", is_json=True
	)
	version = tags_data[0]["name"].lstrip("v")
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
