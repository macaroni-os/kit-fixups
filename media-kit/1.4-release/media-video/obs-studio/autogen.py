#!/usr/bin/env python3

import json
from re import match

async def get_plugin_info(user, repo, select='^\d+\.\d+\.\d+$'):
	module_info={}
	tags = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/tags",
		is_json = True
	)

#	res=httpx.get(f"https://api.github.com/repos/{user}/{repo}/tags")
#	tags = json.loads(res.content)

	selected = None
	for tag in tags:
		selected = (
			tag['name'] 
				if match(select, tag['name']) != None 
			else None
		)
		if selected:
			version = selected
			url = tag['tarball_url']
			break
	if selected is None:
		module_info = None
		raise KeyError(f"Unable to find suitable release/tag for {repo}.")
	else:
		module_info['user'] = user
		module_info['repo'] = repo
		module_info['select'] = select
		module_info['version'] = version
		module_info['url'] = url
		module_info['final_name']=f"{repo}-{version}.tar.gz"
		module_info['atifact'] = hub.pkgtools.ebuild.Artifact(url=url)
	return module_info


async def generate(hub, **pkginfo):
	github_user = "obsproject"
	github_repo = "obs-studio"
	artifacts = []

	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
	)
	for release in json_list:
		if "draft" in release and release["draft"] is not False:
			continue
		if "prerelease" in release and release["prerelease"] is not False:
			continue
		version = release["tag_name"]
		url = release["tarball_url"]
		break
	final_name = f'{pkginfo["name"]}-{version}.tar.gz'
	artifacts.append( hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name) )

	cef_dir = "cef_binary_4280_linux64"
	cef_url = f"https://cdn-fastly.obsproject.com/downloads/{cef_dir}.tar.bz2"
	artifacts.append( hub.pkgtools.ebuild.Artifact(url=cef_url) )

	# The Browser repo has version tags and release assets. Let's get the latest ones.

	plugins = []
	for plugin in ['obs-browser','obs-websocket','obs-amd-encoder']:
		plugins.append( await get_plugin_info(github_user, plugin) )

	for plugin in plugins:
		artifacts.append(
			hub.pkgtools.ebuild.Artifact(
				url=plugin['url'], 
				final_name=plugin['final_name']
			)
		)

	fixed_version="27.2.4"
	print (f"The latest version is {version}, but currently it won't build.\nVersion is fixed to {fixed_version}")
	version=fixed_version

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=github_user,
		github_repo=github_repo,
		version=version,
		cef_dir=cef_dir,
		plugins=plugins,
		artifacts=artifacts,
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
