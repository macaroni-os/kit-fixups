#!/usr/bin/env python3

from re import match

def get_latest_stable_version(releases):
	stable_versions = list(filter(lambda x: match(r"^[0-9.]+$", x), releases))
	return stable_versions[0]

async def generate(hub, **pkginfo):
	repo = pkginfo["name"]
	user = 'videolan'
	releases_data = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/tags", is_json=True
	)

	latest_release = get_latest_stable_version(list(map(lambda x: x["name"], releases_data)))
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {repo}")

		
	version = latest_release
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
