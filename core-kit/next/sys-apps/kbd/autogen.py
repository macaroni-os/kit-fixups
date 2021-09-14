#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	user = "legionus"
	repo = pkginfo["name"]
	releases = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{user}/{repo}/releases", is_json=True)
	version = None
	for release in releases:
		if release["prerelease"] or release["draft"]:
			continue
		version = release["tag_name"].lstrip("v")
		break
	url = f"https://github.com/{user}/{repo}/archive/refs/tags/v{version}.tar.gz"
	src_artifact = hub.pkgtools.ebuild.Artifact(url=url, final_name=f"kbd-{version}.tar.gz")
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=user,
		github_repo=repo,
		artifacts=[src_artifact],
	)
	ebuild.push()

# vim: sw=4 ts=4 noet
