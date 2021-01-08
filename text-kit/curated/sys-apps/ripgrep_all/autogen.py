#!/usr/bin/env python3

import toml


def get_release(releases_data):
	releases = list(filter(lambda x: x["prerelease"] is False and x["draft"] is False, releases_data))
	return None if not releases else sorted(releases, key=lambda x: x["tag_name"]).pop()


async def get_crates_artifacts(hub, github_user, github_repo, crate_name, version):
	crates_raw = await hub.pkgtools.fetch.get_page(
		f"https://github.com/{github_user}/{github_repo}/raw/{version}/Cargo.lock"
	)
	crates_dict = toml.loads(crates_raw)
	crates = ""
	crates_artifacts = []
	for package in crates_dict["package"]:
		if package["name"] == crate_name:
			continue
		crates = crates + package["name"] + "-" + package["version"] + "\n"
		crates_url = "https://crates.io/api/v1/crates/" + package["name"] + "/" + package["version"] + "/download"
		crates_file = package["name"] + "-" + package["version"] + ".crate"
		crates_artifacts.append(hub.pkgtools.ebuild.Artifact(url=crates_url, final_name=crates_file))
	return dict(crates=crates, crates_artifacts=crates_artifacts)


async def generate(hub, **pkginfo):
	github_user = "phiresky"
	github_repo = "ripgrep-all"
	crate_name = pkginfo["name"]
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)
	latest_release = get_release(json_list)
	if latest_release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {github_repo}")
	version = latest_release["tag_name"]
	url = latest_release["tarball_url"]
	final_name = f'{crate_name}-{version}.tar.gz'
	artifacts = await get_crates_artifacts(hub, github_user, github_repo, crate_name, version)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version.lstrip("v"),
		crates=artifacts["crates"],
		github_user=github_user,
		github_repo=github_repo,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name), *artifacts["crates_artifacts"],],
	)
	ebuild.push()