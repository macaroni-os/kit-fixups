#!/usr/bin/env python3

from packaging import version

def get_release(releases_data):
	releases = list(filter(lambda x: x['name'] != "verified" and "rc" not in x['name'], releases_data))
	return None if not releases else sorted(releases, key=lambda x: version.parse(x["name"])).pop()

async def generate(hub, **pkginfo):
	github_user = "netwide-assembler"
	github_repo = pkginfo['name']
	homepage = "https://www.nasm.us"
	
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True
	)

	latest_release = get_release(json_list)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {github_repo}")
	version = latest_release['name'].lstrip("nasm-")
	
	url = f"{homepage}/pub/{github_repo}/releasebuilds/{version}/{github_repo}-{version}.tar.xz"
	#final_name = f"{github_repo}-{version}.tar.xz"
	src_artifact = hub.pkgtools.ebuild.Artifact(url=url)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		homepage = homepage,
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[src_artifact]
	)
	ebuild.push()
