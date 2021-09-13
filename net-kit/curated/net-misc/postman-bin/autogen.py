#!/usr/bin/env python3

import re


def get_postman_url(version, arch="linux64"):
	return f"https://dl.pstmn.io/download/{version}/{arch}"


async def generate(hub, **pkginfo):
	latest_url = get_postman_url("latest")
	filename_pattern = re.compile("Postman-linux-x(?:86_)?64-(.*).tar.gz")
	latest_filename = await hub.pkgtools.fetch.get_response_filename(latest_url)
	version, = filename_pattern.match(latest_filename).groups()
	src_url = get_postman_url(f"version/{version}")
	final_name = f"{pkginfo['name']}-{version}.tar.gz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=src_url, final_name=final_name)],
	)
	ebuild.push()
