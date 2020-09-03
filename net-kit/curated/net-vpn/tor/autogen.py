#!/usr/bin/env python3

import json
from re import match


def get_latest_stable_version(releases):
	stable_versions = list(filter(lambda x: match(r"^tor-[0-9.]+$", x), releases))
	stable_versions.sort()
	return stable_versions.pop().split("tor-").pop()


async def generate(hub, **pkginfo):
	json_data = await hub.pkgtools.fetch.get_page("https://api.github.com/repos/torproject/tor/tags")
	json_dict = json.loads(json_data)
	version = get_latest_stable_version(list(map(lambda x: x["name"], json_dict)))
	url = f"https://www.torproject.org/dist/tor-{version}.tar.gz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
