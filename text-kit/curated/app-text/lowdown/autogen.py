#!/usr/bin/env python

import os
import re


async def generate(hub, **pkginfo):
	github_user = "kristapsdz"
	github_repo = pkginfo["name"]

	def transform_tag(tag):
		return tag.lstrip("VERSION_").replace("_", ".")

	release_info = await hub.pkgtools.github.release_gen(
		hub,
		github_user,
		github_repo,
		transform=transform_tag,
	)
	pkginfo.update(release_info)

	src_artifact = pkginfo["artifacts"][0]
	await src_artifact.ensure_fetched()
	src_artifact.extract()

	src_dir = pkginfo["src_dir"] = f"{github_user}-{github_repo}-{pkginfo['sha'][:7]}"
	src_path = os.path.join(src_artifact.extract_path, src_dir)
	makefile_path = os.path.join(src_path, "Makefile")

	with open(makefile_path, "r") as makefile:
		makefile_data = makefile.read()

	slot_pattern = re.compile("^LIBVER\s+=\s+(\d+)$", re.MULTILINE)
	(pkginfo["slot"],) = slot_pattern.search(makefile_data).groups()

	src_artifact.cleanup()

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
	)
	ebuild.push()
