#!/usr/bin/env python3

import re


def get_postman_url(version, arch="linux64"):
	return f"https://dl.pstmn.io/download/{version}/{arch}"


async def generate(hub, **pkginfo):
	release_notes_url="https://dl.pstmn.io/api/version/notes?channel=stable"
	release_notes = await hub.pkgtools.fetch.get_page(release_notes_url, is_json=True)
	version = release_notes["notes"][0]["version"]
	src_url = get_postman_url(f"version/{version}")
	final_name = f"{pkginfo['name']}-{version}.tar.gz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=src_url, final_name=final_name)],
	)
	ebuild.push()
