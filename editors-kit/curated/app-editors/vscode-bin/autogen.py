#!/usr/bin/env python3

import re
from pathlib import Path


async def generate_for(hub, pkg_name, release_channel, unmasked, **pkginfo):
	url_template = f"https://code.visualstudio.com/sha/download?build={release_channel}&os="
	redirect_url = await hub.pkgtools.fetch.get_url_from_redirect(url_template + "linux-deb-x64")
	deb_filename = redirect_url.split("/")[-1]
	filename_pattern = re.compile(f"^{pkg_name}_([\d.]+)-\d+_amd64\.deb$")
	version, = filename_pattern.match(deb_filename).groups()
	src_url = await hub.pkgtools.fetch.get_url_from_redirect(url_template + "linux-x64")
	artifact = hub.pkgtools.ebuild.Artifact(src_url, final_name=f"{pkginfo['name']}-{version}.tar.gz")
	await artifact.fetch()
	artifact.extract()
	unpack_path = Path(artifact.extract_path)
	src_path = next(unpack_path.iterdir())	# path to `VSCode-linux-x64`
	sh_paths = [path.relative_to(src_path) for path in src_path.rglob("*.sh")]
	so_paths = [path.relative_to(src_path) for path in src_path.rglob("*.so")]
	node_paths = [path.relative_to(src_path) for path in src_path.rglob("*.node")]
	# rg is for ctrl+shift+f
	rg = [path.relative_to(src_path) for path in src_path.rglob("rg")]
	artifact.cleanup()
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		channel=pkg_name,
		unmasked=unmasked,
		artifacts=[artifact],
		fperms_paths=sh_paths + so_paths + node_paths + rg,
		src_path_name=src_path.name,
	)
	ebuild.push()


async def generate(hub, **pkginfo):
	await generate_for(hub, "code", "stable", True, **pkginfo)
	await generate_for(hub, "code-insiders", "insider", False, **pkginfo)
