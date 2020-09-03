#!/usr/bin/env python3

import json
from datetime import timedelta


async def generate(hub, **pkginfo):
	python_compat = "python2_7 python3_{6,7,8}"
	patches = [
		"002_all_vim-7.3-apache-83565.patch",
		"004_all_vim-7.0-grub-splash-96155.patch",
		"005_all_vim_7.1-ada-default-compiler.patch",
		"006-vim-8.0-crosscompile.patch",
	]
	json_data = await hub.pkgtools.fetch.get_page(
		"https://api.github.com/repos/vim/vim/tags", refresh_interval=timedelta(days=7)
	)
	json_dict = json.loads(json_data)
	release = json_dict[0]
	version = release["name"][1:]  # strip 'v'
	url = f"https://github.com/vim/vim/archive/v{version}/v{version}.tar.gz"
	artifacts = [hub.pkgtools.ebuild.Artifact(url=url, final_name=f"{pkginfo['name']}-{version}.tar.gz")]
	vim = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, python_compat=python_compat, patches=patches, version=version, artifacts=artifacts
	)
	vim.push()
	vim_core = hub.pkgtools.ebuild.BreezyBuild(
		template_path=vim.template_path,
		cat=pkginfo["cat"],
		name="vim-core",
		python_compat=python_compat,
		patches=patches,
		version=version,
		artifacts=artifacts,
	)
	vim_core.push()
	gvim = hub.pkgtools.ebuild.BreezyBuild(
		template_path=vim.template_path,
		cat=pkginfo["cat"],
		name="gvim",
		python_compat=python_compat,
		patches=patches,
		version=version,
		artifacts=artifacts,
	)
	gvim.push()


# vim: ts=4 sw=4 noet
