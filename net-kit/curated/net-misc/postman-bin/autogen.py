#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):
	src_url = "https://dl.pstmn.io/download/latest/linux64"
	filename_pattern = re.compile("Postman-linux-x64-(.*).tar.gz")
	src_filename = await hub.pkgtools.fetch.get_response_filename(src_url)
	version = filename_pattern.match(src_filename).group(1)
	final_name = f"{pkginfo['name']}-{version}.tar.gz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=src_url, final_name=final_name)],
	)
	ebuild.push()
