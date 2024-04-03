#!/usr/bin/env python3

import re
import urllib.parse
from metatools.version import generic
from bs4 import BeautifulSoup


revision = {"1.2.20.1210": "1"}


def get_release(releases_data):
	name_pattern = re.compile("(spotify-client_([\d\.]*)\..*_amd64.deb)")
	matches = [name_pattern.match(x["href"]) for x in releases_data]
	releases = sorted((x.groups() for x in matches if x), key=lambda x: generic.parse(x[1]))
	return releases.pop() if releases else None


async def generate(hub, **pkginfo):
	repo = pkginfo["name"]
	url_base = "http://repository.spotify.com/pool/non-free/s/spotify-client/"
	repo_data = await hub.pkgtools.fetch.get_page(url_base)
	repo_soup = BeautifulSoup(repo_data, "html.parser")
	latest_release = get_release(repo_soup.find_all("a", href=True))
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {repo}")
	filename, version = latest_release
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(
				url=urllib.parse.urljoin(url_base, filename),
				final_name=f"{repo}-{version}.deb",
			)
		],
		revision=revision,
	)
	ebuild.push()
