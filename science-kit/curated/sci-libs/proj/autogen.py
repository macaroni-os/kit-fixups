#!/usr/bin/env python3

import json


def get_release(release_data):
	releases = list(filter(lambda x: x["prerelease"] is False and x["draft"] is False, release_data))
	return None if not releases else sorted(releases, key=lambda x: x["tag_name"]).pop()


async def generate(hub, **pkginfo):
	github_user = "OSGeo"
	github_repo = "PROJ"
	release_data = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)

	latest_release = get_release(release_data)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {repo}")
	tag = latest_release["tag_name"]
	version = tag.lstrip("v")
	src_artifact = hub.pkgtools.ebuild.Artifact(
		url=f"https://github.com/{github_user}/{github_repo}/releases/download/{tag}/{pkginfo['name']}-{version}.tar.gz"
	)

	# Github only has datum info in a single 500M archive
	datum_artifact = hub.pkgtools.ebuild.Artifact(
		url=f"https://download.osgeo.org/proj/{pkginfo['name']}-datumgrid-latest.tar.gz"
	)
	europe_datum_artifact = hub.pkgtools.ebuild.Artifact(
		url=f"https://download.osgeo.org/proj/{pkginfo['name']}-datumgrid-europe-latest.tar.gz"
	)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[src_artifact, datum_artifact, europe_datum_artifact],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
