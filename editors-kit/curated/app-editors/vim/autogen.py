#!/usr/bin/env python3

import json
from datetime import timedelta
import re


async def generate(hub, **pkginfo):
	python_compat = "python2+"
	json_dict = await hub.pkgtools.fetch.get_page(
		"https://api.github.com/repos/vim/vim/tags", refresh_interval=timedelta(days=7), is_json=True
	)

	for tag in json_dict:
		if re.match("^v\d+\.\d+\.\d{4}$", tag["name"]):
			release=tag["name"]
			break

	if release is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Unable to find a suitable version for {pkginfo['cat']}-{pkginfo['name']}.")

	version = release[1:]  # strip 'v'
	url = f"https://github.com/vim/vim/archive/v{version}/v{version}.tar.gz"
	artifacts = [hub.pkgtools.ebuild.Artifact(url=url, final_name=f"{pkginfo['name']}-{version}.tar.gz")]

	vim_patches = [
		"vim-6.3-xorg-75816.patch",
		"vim-7.3-apache-83565.patch",
		"vim-7.0-automake-substitutions-93378.patch",
		"vim-7.0-grub-splash-96155.patch",
		"vim-7.1-ada-default-compiler.patch",
		"vim-8.2.0210-python3-shared-lib.patch"
	]

	vim = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		python_compat=python_compat,
		patches=vim_patches,
		version=version,
		artifacts=artifacts
	)
	vim.push()

	vim_core = hub.pkgtools.ebuild.BreezyBuild(
		template_path=vim.template_path,
		cat=pkginfo["cat"],
		name="vim-core",
		python_compat=python_compat,
		version=version,
		artifacts=artifacts,
	)
	vim_core.push()

	gvim = hub.pkgtools.ebuild.BreezyBuild(
		template_path=vim.template_path,
		cat=pkginfo["cat"],
		name="gvim",
		python_compat=python_compat,
		version=version,
		artifacts=artifacts,
	)
	gvim.push()


# vim: ts=4 sw=4 noet
