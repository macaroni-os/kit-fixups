#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):
	python_compat = "python2+"
	main_ver = (
		(await hub.pkgtools.fetch.get_page("https://download.virtualbox.org/virtualbox/LATEST.TXT")).splitlines()
	)[0]
	html = await hub.pkgtools.fetch.get_page(f"https://download.virtualbox.org/virtualbox/{main_ver}")
	match = re.search(f"VirtualBox-{main_ver}-([0-9]*)-Linux_amd64.run", html)
	svn_ver = match.group(1)
	version = f"{main_ver}.{svn_ver}"
	urlbin = f"https://download.virtualbox.org/virtualbox/{main_ver}/{match.group(0)}"
	urlext = f"https://download.virtualbox.org/virtualbox/{main_ver}/Oracle_VirtualBox_Extension_Pack-{main_ver}.vbox-extpack"
	urlsdk = f"https://download.virtualbox.org/virtualbox/{main_ver}/VirtualBoxSDK-{main_ver}-{svn_ver}.zip"
	urladd = f"https://download.virtualbox.org/virtualbox/{main_ver}/VBoxGuestAdditions_{main_ver}.iso"
	urlgst = f"https://download.virtualbox.org/virtualbox/{main_ver}/VirtualBox-{main_ver}.tar.bz2"

	bin_artifacts = [
		hub.pkgtools.ebuild.Artifact(url=urlbin),
		hub.pkgtools.ebuild.Artifact(
			url=urlext, final_name=f"Oracle_VM_VirtualBox_Extension_Pack-{main_ver}-{svn_ver}.tar.gz"
		),
		hub.pkgtools.ebuild.Artifact(url=urlsdk),
	]
	mod_artifacts = [hub.pkgtools.ebuild.Artifact(url=urlbin)]
	add_artifacts = [hub.pkgtools.ebuild.Artifact(url=urladd)]
	gst_artifacts = [hub.pkgtools.ebuild.Artifact(url=urlgst)]

	vbox_bin = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		python_compat=python_compat,
		main_ver=main_ver,
		svn_ver=svn_ver,
		version=version,
		artifacts=bin_artifacts,
	)
	vbox_bin.push()

	vbox = hub.pkgtools.ebuild.BreezyBuild(
		template_path=vbox_bin.template_path,
		cat=pkginfo["cat"],
		name="virtualbox",
		version=version,
	)
	vbox.push()

	vbox_mod = hub.pkgtools.ebuild.BreezyBuild(
		template_path=vbox_bin.template_path,
		cat=pkginfo["cat"],
		name="virtualbox-modules",
		version=main_ver,
		artifacts=mod_artifacts,
	)
	vbox_mod.push()

	vbox_add = hub.pkgtools.ebuild.BreezyBuild(
		template_path=vbox_bin.template_path,
		cat=pkginfo["cat"],
		name="virtualbox-additions",
		version=main_ver,
		artifacts=add_artifacts,
	)
	vbox_add.push()

	vbox_gst = hub.pkgtools.ebuild.BreezyBuild(
		template_path=vbox_bin.template_path,
		cat=pkginfo["cat"],
		name="virtualbox-guest-additions",
		version=main_ver,
		artifacts=gst_artifacts,
	)
	vbox_gst.push()


# vim: ts=4 sw=4 noet
