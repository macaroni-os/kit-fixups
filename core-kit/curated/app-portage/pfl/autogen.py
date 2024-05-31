#!/usr/bin/env python3

from metatools.version import generic


def get_release(releases_data):
	releases = list(filter(lambda x: x["prerelease"] is False and x["draft"] is False, releases_data))
	return None if not releases else sorted(releases, key=lambda x: generic.parse(x["tag_name"])).pop()


async def generate(hub, **pkginfo):
	python_compat = "python3+"
	user = "portagefilelist"
	repo = "client"
	release_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{user}/{repo}/releases", is_json=True)
	latest_release = get_release(release_data)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {pkginfo['name']}")
	version = latest_release["tag_name"]
	url = latest_release["tarball_url"]
	final_name = f"{pkginfo['name']}-{version}.tar.gz"
	src_artifact = hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		python_compat=python_compat,
		github_user=user,
		github_repo=repo,
		artifacts=[src_artifact],
	)
	ebuild.push()
