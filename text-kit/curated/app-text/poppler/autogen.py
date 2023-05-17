#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging.version import Version
import glob
import os.path
import re

masked_above = "23.04.0" # if required by inkscape
masked_above = None
keywords_dict = { "default" : "next" , "22.08.0" : "*", "22.04.0" : "*" }

async def generate(hub, **pkginfo):
	user = repo = pkginfo["name"]
	project_path = f"{user}%2F{repo}"
	info_url = f"https://gitlab.freedesktop.org/api/v4/projects/{project_path}/repository/tags"
	download_url = f"https://gitlab.freedesktop.org/{user}/{repo}/-/archive"

	tag_dict = await hub.pkgtools.fetch.get_page(info_url, is_json=True)
	tags = [tag["name"].split('-')[1] for tag in tag_dict]

	frozen = [ "22.04.0" ]
	fixed = True

	if masked_above and tags[0] != masked_above:
		frozen = [v for v in tags if v == masked_above]
		fixed = False

	for tag in [frozen, tags]:
		if not tag: continue

		version = tag[0]

		package = f"{user}-{repo}-{version}"

		artifact = hub.pkgtools.ebuild.Artifact(url=f"{download_url}/{repo}-{version}/{package}.tar.bz2")

		keywords = keywords_dict[version] if version in keywords_dict else keywords_dict["default"]

		# Find the soname
		await artifact.fetch()
		artifact.extract()
		cmake_file = open(
		   glob.glob(os.path.join(artifact.extract_path, f"{package}", "CMakeLists.txt"))[0]
		).read()
		soversion = re.search("SOVERSION ([0-9]+)", cmake_file)
		subslot = soversion.group(1)
		artifact.cleanup()
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			subslot=subslot,
			gitlab_user=user,
			gitlab_repo=repo,
			artifacts=[artifact],
			keywords=keywords
		)
		ebuild.push()

# vim:ts=4 sw=4 noet
