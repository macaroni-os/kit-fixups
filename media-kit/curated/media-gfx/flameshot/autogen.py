#!/usr/bin/env python3

import re
from metatools.version import generic


def get_release(release_data):
	releases = list(filter(lambda x: x["prerelease"] is False and x["draft"] is False, release_data))
	return None if not releases else sorted(releases, key=lambda x: generic.parse(x["tag_name"])).pop()


async def get_translations(hub, user, repo, version):
	translations_dict = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/contents/data/translations?ref={version}", is_json=True
	)
	translations_format = "Internationalization_(.*).ts"
	translations_list = [re.search(translations_format, file_entry["name"]).group(1) for file_entry in translations_dict]
	return " ".join(translations_list)


async def generate(hub, **pkginfo):
	user = "flameshot-org"
	repo = pkginfo["name"]
	json_dict = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{user}/{repo}/releases", is_json=True)
	latest_release = get_release(json_dict)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {repo}")
	version = latest_release["tag_name"]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version.lstrip("v"),
		translations=await get_translations(hub, user, repo, version),
		artifacts=[
			hub.pkgtools.ebuild.Artifact(
				url=f"https://github.com/{user}/{repo}/archive/{version}.tar.gz", final_name=f"{repo}-{version}.tar.gz"
			)
		],
	)
	ebuild.push()
