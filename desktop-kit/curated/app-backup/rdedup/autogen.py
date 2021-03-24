#!/usr/bin/env python3

from packaging import version


def get_release(releases_data):
	for release in releases_data:
		# Some of the tags have this prefix, so we need to strip it first
		release["name"] = release["name"].lstrip("rdedup-")
	return (
		None
		if not releases_data
		else sorted(releases_data, key=lambda x: version.parse(x["name"])).pop()
	)


async def generate(hub, **pkginfo):
	user = "dpc"
	repo = pkginfo["name"]
	release_data = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/tags", is_json=True
	)
	latest_release = get_release(release_data)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {repo}")
	version = latest_release["name"].lstrip("v")
	url = latest_release["tarball_url"]
	final_name = f"{repo}-{version}.tar.gz"
	src_artifact = hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)
	artifacts = await hub.pkgtools.rust.generate_crates_from_artifact(src_artifact)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		github_user=user,
		github_repo=repo,
		crates=artifacts["crates"],
		artifacts=[src_artifact, *artifacts["crates_artifacts"]],
	)
	ebuild.push()
