#!/usr/bin/env python3

from metatools.version import generic

def get_release(releases_data):
        releases = list(filter(lambda x: x['prerelease'] is False and "beta" not in x['tag_name'], releases_data))
        return None if not releases else sorted(releases, key=lambda x: generic.parse(x['tag_name'])).pop()

async def generate(hub, **pkginfo):
	github_user = "openscad"
	github_repo = pkginfo['name']
	
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)

	latest_release = get_release(json_list)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {github_repo}")
	version = latest_release['tag_name'].lstrip(f"{pkginfo['name']}-")
	for asset in latest_release['assets']:
		if not asset['name'].endswith('.src.tar.gz'):
			continue
		src_artifact = hub.pkgtools.ebuild.Artifact(url=asset['browser_download_url'], final_name=asset['name'])
		break
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[src_artifact]
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
