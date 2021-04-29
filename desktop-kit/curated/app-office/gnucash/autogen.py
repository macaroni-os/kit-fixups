#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	github_user = "Gnucash"
	github_repo = "gnucash"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)
	for release in json_list:
		if release["prerelease"] or release["draft"]:
			continue
		version = release["tag_name"]
		url = release["html_url"]
		for asset in release["assets"]:
			if asset["content_type"] == "application/gzip":
				url = asset["browser_download_url"]
				break
		break
	final_name = f'{pkginfo["name"]}-{version}.tar.gz'
	if version == "4.5":
		pkginfo["revision"] = 1
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=github_user,
		github_repo=github_repo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
