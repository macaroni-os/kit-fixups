#!/usr/bin/env python3

import re
from pathlib import Path


async def generate(hub, **pkginfo):
	raw_html = await hub.pkgtools.fetch.get_page("https://code.visualstudio.com/updates/")
	versions = re.findall(r"(https://update\.code\.visualstudio\.com/([0-9\.]+)/linux\-x64/stable)", raw_html)
	if len(versions) != 1:
		raise hub.pkgtools.ebuild.BreezyError(
			"vscode page was expected to have exactly one linux download link. The script needs updating"
		)
	url, version = versions[0]
	artifact = hub.pkgtools.ebuild.Artifact(url=url, final_name=f"vscode-bin-{version}.tar.gz")
	await artifact.fetch()
	artifact.extract()
	unpack_path = Path(artifact.extract_path)
	src_path = next(unpack_path.iterdir())  # path to `VSCode-linux-x64`
	sh_paths = [path.relative_to(src_path) for path in src_path.rglob("*.sh")]
	so_paths = [path.relative_to(src_path) for path in src_path.rglob("*.so")]
	node_paths = [path.relative_to(src_path) for path in src_path.rglob("*.node")]
	# rg is for ctrl+shift+f
	rg = [path.relative_to(src_path) for path in src_path.rglob("rg")]
	revision = 1 if version == "1.48.2" else 0

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		revision=revision,
		artifacts=[artifact],
		fperms_paths=sh_paths + so_paths + node_paths + rg,
		src_path_name=src_path.name,
	)
	ebuild.push()
