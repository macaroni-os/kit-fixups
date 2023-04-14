#!/usr/bin/env python3

import os
from packaging import version


def get_release(releases_data):
	releases = list(filter(lambda x: x["prerelease"] is False and x["draft"] is False, releases_data))
	return None if not releases else sorted(releases, key=lambda x: version.parse(x["tag_name"])).pop()


async def generate(hub, **pkginfo):
	github_user = pkginfo["name"]
	github_repo = pkginfo["name"]

	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)
	latest_release = get_release(json_list)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {github_repo}")
	version = latest_release["tag_name"]

	final_name = f'{pkginfo["name"]}-{version}-with-submodules.tar.xz'

	my_archive, metadata = hub.Archive.find_by_name(final_name)
	if my_archive is None:
		my_archive = hub.Archive(final_name)
		my_archive.initialize()
		retval = os.system(f'( cd {my_archive.top_path}; git clone --depth 1 --branch {version} --recursive https://github.com/{github_user}/{github_repo}.git {pkginfo["name"]}-{version} )')
		if retval != 0:
			raise hub.pkgtools.ebuild.BreezyError("Unable to git clone repository.")
		my_archive.store_by_name()

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[my_archive]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
