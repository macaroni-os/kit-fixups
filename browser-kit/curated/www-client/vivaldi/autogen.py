#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):
	html_page = await hub.pkgtools.fetch.get_page("https://vivaldi.com/download/")
	match = re.search(r"https://downloads.vivaldi.com/stable/vivaldi-stable_([0-9.-]*)_amd64.deb", html_page)
	url = match.group(0)  # the entire match
	version = match.group(1)  # the first group
	version = version.replace("-", "_p")  # convert deb version string to funtoo-compatible.

	artifacts = [
		hub.pkgtools.ebuild.Artifact(url=url, final_name=f"vivaldi-{version}-amd64.deb"),
		hub.pkgtools.ebuild.Artifact(url=url.replace("amd64", "arm64"), final_name=f"vivaldi-{version}-arm64.deb"),
		hub.pkgtools.ebuild.Artifact(url=url.replace("amd64", "armhf"), final_name=f"vivaldi-{version}-armhf.deb"),
		hub.pkgtools.ebuild.Artifact(url=url.replace("amd64", "i386"), final_name=f"vivaldi-{version}-i386.deb"),
	]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo, version=version, artifacts=artifacts)
	ebuild.push()


# vim: ts=4 sw=4 noet
