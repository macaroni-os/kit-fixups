#!/usr/bin/env python3

async def generate(hub, **pkginfo):
	user = "darktable-org"
	repo = pkginfo["name"]
	if pkginfo["version"] == "latest":
		releases = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{user}/{repo}/releases", is_json=True)
		for release in releases:
			if release["prerelease"] or release["draft"]:
				continue
			pkginfo["version"] = release["tag_name"].lstrip("release-")
			break
		if pkginfo["version"] == "latest":
			raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {repo}")
	version = pkginfo["version"]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(
				url=f"https://github.com/{user}/{repo}/releases/download/release-{version}/{repo}-{version}.tar.xz"
			)
		],
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
