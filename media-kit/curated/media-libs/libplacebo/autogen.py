#!/usr/bin/env python3

import json
import os
from packaging.version import Version

async def generate(hub, **pkginfo):
	python_compat = "python3+"
	github_user = "haasn"
	github_repo = "libplacebo"
	# Version 5.264.0 and up requires meson-0.63, which is not supported in Funtoo yet
	version_limit = Version("5.250")
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True
	)
	for tag in json_list:
		v = Version(tag["name"].lstrip("v"))
		if v.is_prerelease or v > version_limit:
			continue
		version = v
		url = tag["tarball_url"]
		break
	final_name = f'{pkginfo["name"]}-{version}-with-submodules.tar.xz'

	my_archive, metadata = hub.Archive.find_by_name(final_name)
	if my_archive is None:
		my_archive = hub.Archive(final_name)
		await my_archive.initialize()
		retval = os.system(f"( cd {my_archive.top_path}; git clone --depth 1 --branch v{v} --recursive https://code.videolan.org/videolan/libplacebo )")
		if retval != 0:
			raise hub.pkgtools.ebuild.BreezyError("Unable to git clone repository.")
		await my_archive.store_by_name()

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		python_compat=python_compat,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[my_archive]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
