#!/usr/bin/env python3

import re
import glob
import os


async def generate(hub, **pkginfo):
	wanted_version = "10.0.26.1"
	github_user = "FFmpeg"
	github_repo = "nv-codec-headers"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True
	)
	for tag_data in json_list:
		version = tag_data["name"].lstrip("n")
		if version != wanted_version:
			continue
		url = tag_data["tarball_url"]
		break
	if version != wanted_version:
		raise hub.pkgtools.ebuild.BreezyError("Couldn't find desired version.")
	final_name = f'{pkginfo["name"]}-{version}.tar.gz'

	# Extract nvidia-drivers minimum version from README file:
	artifact = hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)
	await artifact.fetch()
	artifact.extract()
	readme = list(glob.iglob(os.path.join(artifact.extract_path, "*/README")))[0]
	with open(readme, "r") as readmefile:
		readme_str = readmefile.read()
		print(readme_str)
	drivers_minver = re.search(r"Linux: ([0-9.]+)", readme_str).group(1)
	artifact.cleanup()
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=github_user,
		github_repo=github_repo,
		drivers_minver=drivers_minver,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
