#!/usr/bin/env python3

import re
import glob
import os

async def generate(hub, **pkginfo):
	user = "NVIDIA"
	repo = pkginfo["name"]

	src_pkginfo = await hub.pkgtools.github.release_gen(hub, user, repo)
	src_artifact =  src_pkginfo['artifacts'][0]
	await src_artifact.fetch()
	src_artifact.extract()

	modprobe_repo = "nvidia-modprobe"
	modprobe_file = open(
		glob.glob(os.path.join(src_artifact.extract_path, f"{user}-{repo}-*", "mk/nvidia-modprobe.mk"))[0]
	).read()
	modprobe_version = re.search("VERSION.*= ([0-9.]+)", modprobe_file).group(1)
	modprobe_pkginfo = await hub.pkgtools.github.tag_gen(hub, user, modprobe_repo, select=modprobe_version)
	modprobe_artifact = modprobe_pkginfo['artifacts'][0]

	elf_file = open(
		glob.glob(os.path.join(src_artifact.extract_path, f"{user}-{repo}-*", "mk/elftoolchain.mk"))[0]
	).read()
	elf_version = re.search("VERSION.*= ([0-9.]+)", elf_file).group(1)
	elf_url = f"https://sourceforge.net/projects/elftoolchain/files/Sources/elftoolchain-{elf_version}"
	elf_artifact = hub.pkgtools.ebuild.Artifact(url=f"{elf_url}/elftoolchain-{elf_version}.tar.bz2")

	src_artifact.cleanup()
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=src_pkginfo['version'],
		nv_version=modprobe_pkginfo['version'],
		elf_version=elf_version,
		github_user=user,
		github_repo=repo,
		artifacts=[src_artifact, modprobe_artifact, elf_artifact],
	)
	ebuild.push()

# vim: sw=4 ts=4 noet