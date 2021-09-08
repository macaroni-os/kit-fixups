#!/usr/bin/env python3

import base64
import re
from packaging import version


def get_release(releases_data):
	releases = list(filter(lambda x: x["prerelease"] is False and x["draft"] is False, releases_data))
	return None if not releases else sorted(releases, key=lambda x: version.parse(x["tag_name"])).pop()

# We need the core so version and the cpp so version
async def get_soname(hub, github_user, github_repo, tag_name):
	enc_makefile = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/contents/CMakeLists.txt?ref={tag_name}", 
		is_json=True
	)
	if not enc_makefile:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't get the required sonames from {github_repo}")
		
	# Content is base64 encoded
	makefile = base64.b64decode(enc_makefile['content']).decode()
	core_so = ""
	cpp_so = ""
	for line in makefile.splitlines():
		if line.startswith("set(gRPC_CORE_SOVERSION"):
			core_so = re.findall('"([^"]*)"', line)[0]
		if line.startswith("set(gRPC_CPP_SOVERSION"):
			cpp_so = re.findall('"([^"]*)"', line)[0]
	
	if not core_so or not cpp_so:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't get the required sonames from {github_repo}")
	# Remove any '.' before returning
	return core_so.replace(".", ""), cpp_so.replace(".", "")
	
async def generate(hub, **pkginfo):
	github_user = "grpc"
	github_repo = pkginfo["name"]
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)

	latest_release = get_release(json_list)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {github_repo}")
	version = latest_release["tag_name"].lstrip("v")
	url = latest_release["tarball_url"]
	final_name = f"{github_repo}-{version}.tar.gz"
	src_artifact = hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)
	
	core_so, cpp_so = await get_soname(hub, github_user, github_repo, latest_release['tag_name'])
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		core_so=core_so,
		cpp_so=cpp_so,
		artifacts=[src_artifact]
	)
	ebuild.push()
