#!/usr/bin/env python3

from packaging import version


async def get_versions(hub, pkginfo):
	release_data = []
	try:
		user = pkginfo["user"]
		repo = pkginfo["repo_name"] if "repo_name" in pkginfo else pkginfo["name"]
		release_data = await hub.pkgtools.fetch.get_page(
			f"https://api.github.com/repos/{user}/{repo}/releases", is_json=True
		)
	except hub.pkgtools.fetch.FetchError:
		pass
	release_data = [x for x in release_data if not x["prerelease"] and not x["draft"]]
	release_data = [{**x, "ver": version.parse(x["tag_name"])} for x in release_data]
	release_data.sort(key=lambda x: x["ver"], reverse=True)
	pkginfo["releases"] = release_data
	return pkginfo


async def preprocess_packages(hub, pkginfo_list):
	pkginfo_list = [await get_versions(hub, x) for x in pkginfo_list]
	release_list = [x["releases"] for x in pkginfo_list]
	version_list = [set([y["ver"] for y in x]) for x in release_list if x]
	target_version = max(set.intersection(*version_list))
	target_major, target_minor, _ = target_version.release
	max_version = version.parse(f"{target_major}.{target_minor+1}.0")
	for pkginfo in pkginfo_list:
		pkginfo = {
			**pkginfo,
			"target_version": target_version,
			"max_version": max_version,
		}
		yield pkginfo


async def generate(hub, **pkginfo):
	target_version = pkginfo["target_version"]
	max_version = pkginfo["max_version"]
	artifacts = []
	if pkginfo["releases"]:
		target_release = next(x for x in pkginfo["releases"] if x["ver"] >= target_version and x["ver"] < max_version)
		target_version = target_release["ver"]
		try:
			if "assets" in target_release:
				url = next(x["browser_download_url"] for x in target_release["assets"] if x["name"].endswith(".tar.xz"))
				final_name = f"{pkginfo['name']}-{target_version}.tar.xz"
				src_artifact = hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)
				artifacts.append(src_artifact)
		except StopIteration:
			pass
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=target_version,
		artifacts=artifacts,
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
