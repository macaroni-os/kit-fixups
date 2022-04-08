#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging.version import Version
import re

# NOTE: this is a simple autogen that *should* be replaceable with an autogen.yaml instead
# However, due to the formatting of the tags and releases on their GitHub repo, we need to do it manually

async def generate(hub, **pkginfo):
	github_user = github_repo = 'logrotate'
	releases = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)
	for release in releases:
		if release["prerelease"] or release["draft"]:
			continue
		version = release["tag_name"]
		url = release["tarball_url"]
		break

	artifact = hub.pkgtools.ebuild.Artifact(url=url, final_name=f"{pkginfo['name']}-{version}.tar.gz")

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[artifact],
	)
	ebuild.push()



# vim: sw=4 ts=4 noet
