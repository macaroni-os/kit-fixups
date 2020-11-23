#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	python_compat = "python3+"
	github_user = "KhronosGroup"
	github_repo_l = "Vulkan-Loader"
	github_repo_h = "Vulkan-Headers"
	json_list_l = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo_l}/tags", is_json=True
	)
	json_list_h = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo_h}/tags", is_json=True
	)
	version_h = []
	url_h = []

	for tag_l in json_list_l:
		for tag_h in json_list_h:
			v = tag_h["name"].lstrip("v")
			if "-rc" in v or "sdk" in v or "windows" in v:
				continue
			version_h.append(v)
			url_h.append(tag_h["tarball_url"])
		if tag_l["name"].lstrip("v") in version_h:
			version_l = tag_l["name"].lstrip("v")
			url_l = tag_l["tarball_url"]
			break
	final_name_l = f'{pkginfo["name"]}-{version_l}.tar.gz'
	final_name_h1 = f'vulkan-headers-{version_h[0]}.tar.gz'
	final_name_h2 = f'vulkan-headers-{version_l}.tar.gz'

	ebuild_l = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version_l,
		python_compat=python_compat,
		github_user=github_user,
		github_repo=github_repo_l,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url_l, final_name=final_name_l)]
	)
	ebuild_l.push()

	ebuild_h1 = hub.pkgtools.ebuild.BreezyBuild(
		template_path=ebuild_l.template_path,
		cat="dev-util",
		name="vulkan-headers",
		version=version_h[0],
		python_compat=python_compat,
		keywords="",
		github_user=github_user,
		github_repo=github_repo_h,
		artifacts=[hub.pkgtools.ebuild.Artifact(
			url=url_h[0],final_name=final_name_h1)]
	)
	ebuild_h1.push()

	ebuild_h2 = hub.pkgtools.ebuild.BreezyBuild(
		template_path=ebuild_l.template_path,
		cat="dev-util",
		name="vulkan-headers",
		version=version_l,
		python_compat=python_compat,
		keywords="*",
		github_user=github_user,
		github_repo=github_repo_h,
		artifacts=[hub.pkgtools.ebuild.Artifact(
			url=url_h[version_h.index(version_l)],
			final_name=final_name_h2)]
	)
	ebuild_h2.push()


# vim: ts=4 sw=4 noet
