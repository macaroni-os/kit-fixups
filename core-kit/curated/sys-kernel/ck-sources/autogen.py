#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):

	major_ver = "5"
	artifacts = {}

	########################################
	# Find latest version 5.x of ck-sources:
	########################################

	versions = await hub.pkgtools.pages.iter_links(
		base_url=f"http://ck.kolivas.org/patches/{major_ver}.0/",
		match_fn=lambda x: x if x.startswith(major_ver) else None,
		fixup_fn=lambda x: x.rstrip("/")
	)
	latest = hub.pkgtools.pages.latest(versions)
	if latest is None:
		print("Could not find a suitable ck-sources version.")
		return
	latest_split = latest.split(".")
	minor_ver = latest_split[1]
	
	###########################################################################
	# Find latest upstream patch version 5.x.y for that kernel from kernel.org:
	###########################################################################

	patch_versions = await hub.pkgtools.pages.iter_links(
		base_url=f"https://mirrors.edge.kernel.org/pub/linux/kernel/v{major_ver}.x/",
		match_fn=lambda x: re.match(f"patch-{major_ver}\.{minor_ver}\.([0-9+]).xz", x),
		fixup_fn=lambda x: x.groups()[0]
	)
	
	###########################################################################
	# If there is an upstream patch version for that kernel, let's use it:
	###########################################################################

	patch_ver = hub.pkgtools.pages.latest(patch_versions) if patch_versions else None
	if patch_ver is not None:
		base_ver = f"{latest}.{patch_ver}"
		artifacts["korg_patch"] = hub.pkgtools.ebuild.Artifact(url=f"https://mirrors.edge.kernel.org/pub/linux/kernel/v{major_ver}.x/patch-{base_ver}.xz")
	else:
		base_ver = f"{latest}"

	###########################################################################################################
	# Now we need to find the latest _ck patch version and use it (let's map this to _p in the Funtoo version):
	###########################################################################################################

	ck_versions = await hub.pkgtools.pages.iter_links(
		base_url=f"http://ck.kolivas.org/patches/5.0/{major_ver}.{minor_ver}/",
		match_fn=lambda x: re.match(f"{major_ver}.{minor_ver}-ck([0-9]+)/", x),
		fixup_fn=lambda x: x.groups()[0]
	)
	if not ck_versions:
		raise IndexError(f"Could not find a suitable ck-sources patch version for {major_ver}.{minor_ver}.")
	ck_ver = hub.pkgtools.pages.latest(ck_versions)

	#############################################################################################
	# 5.12 with latest upstream 5.12 being 5.12.8 with ck1 released would translate to: 5.12.8_p1
	#############################################################################################

	ebuild_version = f"{base_ver}_p{ck_ver}"

	artifacts.update({
		"ck_patch": hub.pkgtools.ebuild.Artifact(url=f"http://ck.kolivas.org/patches/{major_ver}.0/{major_ver}.{minor_ver}/{major_ver}.{minor_ver}-ck{ck_ver}/patch-{major_ver}.{minor_ver}-ck{ck_ver}.xz"),
		"kernel": hub.pkgtools.ebuild.Artifact(url=f"https://mirrors.edge.kernel.org/pub/linux/kernel/v{major_ver}.x/linux-{major_ver}.{minor_ver}.tar.xz"),
	})

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		base_ver=base_ver,                     # 5.12.9
		version=ebuild_version,                # 5.12.9_p1
		ck_ver=ck_ver,                         # 1
		patch_ver=patch_ver,                   # 9
		branch_id=f"{major_ver}.{minor_ver}",  # 5.12
		artifacts=artifacts
	)

	ebuild.push()

# vim: ts=4 sw=4 noet

