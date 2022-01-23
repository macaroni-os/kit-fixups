#!/usr/bin/env python3

import glob
import os
from datetime import datetime
import re

async def query_github_api(user, repo, query):
	return await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{user}/{repo}/{query}",
		is_json=True,
	)

def get_version(json):
	for tag in json:
		version = tag["name"].lstrip("v")
		if not re.match("[0-9.]+", version):
			continue
		url = tag["tarball_url"]
		break
	return version, url

async def generate(hub, **pkginfo):
	python_compat = "python3+"
	github_user = "KhronosGroup"
	github_repo = "SPIRV-Tools"
	json_data = await query_github_api(github_user, github_repo, "tags")
	version, url = get_version(json_data)
	final_name = f'{pkginfo["name"]}-{version}.tar.gz'
	tools_artifact = hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)

	tools_ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		python_compat=python_compat,
		github_user=github_user,
		github_repo=github_repo,
		version=version,
		artifacts=[tools_artifact],
		revision={ "2021.4" : "1" }
	)
	tools_ebuild.push()

	await tools_artifact.fetch()
	tools_artifact.extract()
	deps_file = open(
		glob.glob(os.path.join(tools_artifact.extract_path, f"{github_user}-{github_repo}-*", "DEPS"))[0]
	).readlines()

	for line in deps_file:
		if "'spirv_headers_revision':" in line:
			commit_hash = line.split("'")[-2]
	tools_artifact.cleanup()

	github_repo = "SPIRV-Headers"
	json_data = await query_github_api(github_user, github_repo, "tags")
	version, url = get_version(json_data)

	commit_data = await query_github_api(github_user, github_repo, "commits/"+commit_hash)
	commit_date = datetime.strptime(commit_data["commit"]["committer"]["date"], "%Y-%m-%dT%H:%M:%SZ")
	version += "_p" + commit_date.strftime("%Y%m%d")
	url = f"https://github.com/{github_user}/{github_repo}/archive/{commit_hash}.tar.gz"
	final_name = f'{pkginfo["name"]}-{version}.tar.gz'
	headers_ebuild = hub.pkgtools.ebuild.BreezyBuild(
		template_path=tools_ebuild.template_path,
		cat=pkginfo["cat"],
		name="spirv-headers",
		github_user=github_user,
		github_repo=github_repo,
		version=version,
		artifacts=[
			hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name),
		],
	)
	headers_ebuild.push()


# vim: ts=4 sw=4 noet
