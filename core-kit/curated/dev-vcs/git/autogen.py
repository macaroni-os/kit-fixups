#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):
	kernel_org = "https://www.kernel.org/pub/software/scm/git"
	html_data = await hub.pkgtools.fetch.get_page("https://git-scm.com/downloads/linux")
	latest = re.search(f'<a href="{kernel_org}/git-([0-9.]*)\.tar.gz', html_data)
	version = latest.group(1)
	src_artifact = hub.pkgtools.ebuild.Artifact(url=f"{kernel_org}/git-{version}.tar.xz")
	artifacts = [
		src_artifact,
		hub.pkgtools.ebuild.Artifact(url=f"{kernel_org}/git-manpages-{version}.tar.xz"),
	]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo, version=version, artifacts=artifacts)
	ebuild.push()


# vim: ts=4 sw=4 noet
