#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging.version import Version
import json
import re
import os


MINIMUM_STABLE_NODEJS = 12

async def generate_artifacts(hub, pkginfo, urls):
	arches = { # map upstream arch string to portage arch string
		'x86_64': 'amd64',
		'aarch64': 'arm64'
	}
	return [(
			arches[url.split('-')[-1].split('.')[0]], # Portage arch string from upstream arch string
			hub.pkgtools.ebuild.Artifact(url=url)
		) for url in urls if 'sha' not in url # filter out the sha
	]


async def get_minimum_node_version(artifact):
	# extract the contents of package.json in the src tarball
	await artifact.fetch()
	artifact.extract()
	try: # versions 6, 7
		package = os.path.join(artifact.extract_path, artifact.final_name.split(".tar.")[0], "package.json")
		package_info = json.load(open(package))
	except FileNotFoundError: # version 8
		package = os.path.join(artifact.extract_path, artifact.final_name.split("-linux")[0], "package.json")
		package_info = json.load(open(package))
	artifact.cleanup()

	version = Version(package_info["engines"]["node"])
	return { 'minimum': version.public, 'series': max(version.major, MINIMUM_STABLE_NODEJS) }


async def generate(hub, **pkginfo):
	github_user = "elastic"
	github_repo = "kibana"
	download_url = "https://www.elastic.co/downloads/past-releases"

	releases = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/releases",
		is_json=True
	)
	versions = [Version(a["tag_name"].lstrip("v")) for a in releases]
	latest = max([v for v in versions])

	# Create an ebuild for the most recent 3 major versions
	for major in [latest.major, latest.major - 1, latest.major - 2]:
		version = max([v for v in versions if v.major == major])

		# find available architecture tarballs
		download_page = f"{download_url}/kibana-{version.public.replace('.', '-')}"
		html = await hub.pkgtools.fetch.get_page(download_page)
		soup = BeautifulSoup(html, "html.parser").find_all("a", href=True)
		tarballs = [a.get('href') for a in soup if 'linux' in a.get('href')]

		artifacts = await generate_artifacts(hub, pkginfo, tarballs)

		# find the compatible node version
		node = await get_minimum_node_version(artifacts[0][1])
		print(node)

		template = f"-{major}"
		if major != 6:
			template = "-7"

		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version.public.replace('-', '_'),
			artifacts=dict(artifacts),
			nodejs=node,
		)
		#	template=pkginfo['name'] + template + ".tmpl",
		ebuild.push()

# vim: ts=4 sw=4 noet
