#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	user = "cracklib"
	repo = pkginfo["name"]
	#releases = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{user}/{repo}/releases", is_json=True)
	#version = None
	#for release in releases:
	#	if release["prerelease"] or release["draft"]:
	#		continue
	#	version = release["tag_name"].lstrip("v")
	#	break
	version="2.9.8"
	url = f"https://github.com/{user}/{repo}/releases/download/v{version}/cracklib-{version}.tar.gz"
	src_artifact = hub.pkgtools.ebuild.Artifact(url=url)
	words_artifact = hub.pkgtools.ebuild.Artifact(url="/".join(url.split("/")[:-1])+f"/cracklib-words-{version}.gz")
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=user,
		github_repo=repo,
		artifacts=[src_artifact, words_artifact],
		revision={ "2.9.7" : "2" }
	)
	ebuild.push()

# vim: sw=4 ts=4 noet
