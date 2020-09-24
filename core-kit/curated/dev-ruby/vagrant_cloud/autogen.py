#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	pkginfo["version"] = "2.0.3"
	GITHUB_USER = "hashicorp"
	GITHUB_REPO = "vagrant_cloud"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{GITHUB_USER}/{GITHUB_REPO}/tags", is_json=True
	)
	version = None
	tag_name = None
	for tag in json_list:
		tag_name = tag["name"]
		version = tag_name.lstrip("v")
		if "version" in pkginfo and version != pkginfo["version"]:
			continue
		else:
			break
	if "version" in pkginfo and version != pkginfo["version"]:
		raise hub.pkgtools.ebuild.BreezyError(f"Could not find specified version {pkginfo['version']} in JSON")
	url = f"https://github.com/{GITHUB_USER}/{GITHUB_REPO}/archive/{tag_name}.tar.gz"
	final_name = f"{GITHUB_REPO}-{version}.tar.gz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
