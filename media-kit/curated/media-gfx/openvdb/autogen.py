#!/usr/bin/env python3

import re
import glob
import os
from packaging import version

async def query_github_api(user, repo, query):
	return await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/{query}",
		is_json=True,
	)

def get_release_info(releases_data):
	def prerelease(dat):
		return dat["prerelease"] or dat["draft"]
	def get_version(dat):
		return version.parse(dat["tag_name"].lstrip("v"))

	matches = [x for x in releases_data if not prerelease(x)]
	releases = sorted((x for x in matches if x), key=get_version)
	release = releases.pop() if releases else None
	ver = str(get_version(release))
	url = release["tarball_url"]
	return ver, url

async def generate(hub, **pkginfo):
	github_user = "AcademySoftwareFoundation"
	github_repo = "openvdb"
	json_data = await query_github_api(github_user, github_repo, "releases")
	ver,url = get_release_info(json_data)

	final_name = f'{pkginfo["name"]}-{ver}.tar.gz'
	artifact = hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)
	await artifact.fetch()
	artifact.extract()
	search_file = "cmake/config/OpenVDBVersions.cmake"
	cmake_file = open(
		glob.glob(os.path.join(artifact.extract_path, f"{github_user}-{github_repo}-*", search_file))[0]
	).read()
	found = re.search("\(MINIMUM_OPENVDB_ABI_VERSION ([0-9]+)", cmake_file)
	if not found:
		raise hub.pkgtools.ebuild.BreezyError(f"Could not find MINIMUM_OPENVDB_ABI_VERSION in {cmake_file} in source archive.")
	abi_min = found.group(1)
	artifact.cleanup()

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=ver,
		major_ver=ver.split(".")[0],
		github_user=github_user,
		github_repo=github_repo,
		abi_min=abi_min,
		artifacts=[artifact],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
