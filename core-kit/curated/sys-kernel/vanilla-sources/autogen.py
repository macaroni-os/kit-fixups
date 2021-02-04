#!/usr/bin/env python3
import json
import re


async def generate(hub, **pkginfo):

	# Fetch the kernel versions from api
	try:
		json_list = await hub.pkgtools.fetch.get_page(f"https://www.kernel.org/releases.json", is_json=True)
	except:
		pass

	if json_list is None:
		raise hub.pkgtools.ebuild.BreezyError("Kernel API down?")

	stable_ver = json_list["latest_stable"]["version"]

	versions = re.search("([0-9]+)\.([0-9]+)\.?([0-9]+)?", stable_ver)

	major_ver = versions.group(1)
	minor_ver = versions.group(2)
	patch_ver = versions.group(3)

	# Genertate artifacts starting with major version
	artifacts = [
		hub.pkgtools.ebuild.Artifact(
			url=f"https://mirrors.edge.kernel.org/pub/linux/kernel/v{major_ver}.x/linux-{major_ver}.{minor_ver}.tar.xz"
		),
	]

	# If its a patch release append the artifacts list with that patch
	if patch_ver is not None:
		artifacts.append(
			hub.pkgtools.ebuild.Artifact(
				url=f"https://mirrors.edge.kernel.org/pub/linux/kernel/v{major_ver}.x/patch-{major_ver}.{minor_ver}.{patch_ver}.xz"
			)
		)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo, version=stable_ver, artifacts=artifacts)

	ebuild.push()


# vim: ts=4 sw=4 noet
