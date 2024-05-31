#!/usr/bin/env python3

from metatools.version import generic

def get_release(releases_data):
        releases = list(filter(lambda x: x['prerelease'] is False and "beta" not in x['tag_name'], releases_data))
        return None if not releases else sorted(releases, key=lambda x: generic.parse(x['tag_name'])).pop()

async def generate(hub, **pkginfo):
	github_user = "3MFConsortium"
	github_repo = pkginfo['name']
	
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)

	latest_release = get_release(json_list)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {github_repo}")
	version = latest_release['tag_name'].lstrip("v")
	url = f"https://github.com/{github_user}/{github_repo}/archive/refs/tags/v{version}.tar.gz"
	final_name = f"{github_repo}-{version}.tar.gz"
	src_artifact = hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[src_artifact]
	)
	ebuild.push()
