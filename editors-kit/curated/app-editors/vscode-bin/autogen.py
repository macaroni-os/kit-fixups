#!/usr/bin/env python3

import re
from pathlib import Path

async def generate(hub, **pkginfo):
	raw_html = await hub.pkgtools.fetch.get_page("https://code.visualstudio.com/updates/")
	versions = re.findall(r'(https://update\.code\.visualstudio\.com/([0-9\.]+)/linux\-x64/stable)', raw_html)
	if len(versions) != 1:
		raise hub.pkgtools.ebuild.BreezyError("vscode page was expected to have exactly one linux download link. The script needs updating")
	url, version = versions[0]
	source_artifact = hub.pkgtools.ebuild.Artifact(url=url, final_name=f'vscode-bin-{version}.tar.gz')
	unpack_path = Path(source_artifact.extract_path)
	src_path = next(unpack_path.iterdir())
	sh_paths = [so_path.relative_to(src_path) for so_path in src_path.rglob('*.sh')]
	so_paths = [so_path.relative_to(src_path) for so_path in src_path.rglob('*.so')]

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[source_artifact],
		fperms_paths=sh_paths + so_paths,
		src_path_name=src_path.name,
	)
	ebuild.push()
