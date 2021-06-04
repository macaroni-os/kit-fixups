#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	user = "grwlf"
	repo = pkginfo["name"]
	tags_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{user}/{repo}/tags", is_json=True)
	latest_release = sorted(tags_data, key=lambda x: x["name"]).pop()
	version = latest_release["name"]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(
				url=f"https://github.com/{user}/{repo}/archive/{version}.tar.gz", final_name=f"{repo}-{version}.tar.gz"
			)
		],
	)
	ebuild.push()
