#!/usr/bin/env python3

from packaging import version

async def generate(hub, **pkginfo):
	github_user = "mongodb"
	github_repo = "mongo-tools"
	github_url = f"https://api.github.com/repos/{github_user}/{github_repo}/tags?per_page=100"
	json_list = await hub.pkgtools.fetch.get_page(github_url, is_json=True) \
		+ await hub.pkgtools.fetch.get_page(github_url+"&page=2", is_json=True) \
		+ await hub.pkgtools.fetch.get_page(github_url+"&page=3", is_json=True) \
		+ await hub.pkgtools.fetch.get_page(github_url+"&page=4", is_json=True)

	json_list = sorted(json_list, key=lambda x: version.parse(x["name"]), reverse=True)
	for tag in json_list:
		ver = tag["name"]
		if "-rc" in ver:
			continue
		break
	url = f'https://github.com/{github_user}/{github_repo}/archive/{ver}.tar.gz'
	
	final_name = f'{pkginfo["name"]}-{ver}.tar.gz'
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=github_user,
		github_repo=github_repo,
		version=ver,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
