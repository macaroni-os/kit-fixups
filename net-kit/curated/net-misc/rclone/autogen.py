#!/usr/bin/env python3

import json
import re


async def get_gosum_artifacts(hub, github_user, github_repo, version):
	gosum_raw = await hub.pkgtools.fetch.get_page(f"https://github.com/{github_user}/{github_repo}/raw/{version}/go.sum")
	gosum_lines = gosum_raw.split("\n")
	gosum = ""
	gosum_artifacts = []
	for line in gosum_lines:
		module = line.split()
		if not len(module):
			continue
		gosum = gosum + '\t"' + module[0] + " " + module[1] + '"\n'
		module_path = re.sub("([A-Z]{1})", r"!\1", module[0]).lower()
		module_ver = module[1].split("/")
		module_ext = "zip"
		if "go.mod" in module[1]:
			module_ext = "mod"
		module_uri = module_path + "/@v/" + module_ver[0] + "." + module_ext
		module_file = re.sub("/", "%2F", module_uri)
		gosum_artifacts.append(
			hub.pkgtools.ebuild.Artifact(url="https://proxy.golang.org/" + module_uri, final_name=module_file)
		)
	return dict(gosum=gosum, gosum_artifacts=gosum_artifacts)


async def generate(hub, **pkginfo):
	github_user = "rclone"
	github_repo = "rclone"
	json_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{github_user}/{github_repo}/tags")
	json_dict = json.loads(json_data)
	version = json_dict[0]["name"]
	artifacts = await get_gosum_artifacts(hub, github_user, github_repo, version)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version[1:],  # `[1:]` slices out the 'v' char from the version
		gosum=artifacts["gosum"],
		artifacts=[
			hub.pkgtools.ebuild.Artifact(
				url=f"https://github.com/{github_user}/{github_repo}/releases/download/{version}/{github_repo}-{version}.tar.gz"
			),
			*artifacts["gosum_artifacts"],
		],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
