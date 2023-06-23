#!/usr/bin/env python

import re


async def generate(hub, **pkginfo):

	github_user = "ON4QZ"
	github_project = "QSSTV"

	url = f"https://api.github.com/repos/{github_user}/{github_project}/branches/main"

	page = await hub.pkgtools.fetch.get_page(url, is_json=True)

	# get time part of version (for version differentiation, see https://github.com/ON4QZ/QSSTV/issues/15 )
	commit_date = re.sub(r'[TZ:\-]', '', page['commit']
						 ['commit']['author']['date'])

	# use url from response - to avoid situation when there are update between requests
	# and peek inside project to get major+minor version
	commit_sha = page['commit']['sha']

	archive_url = f"https://github.com/{github_user}/{github_project}/archive/{commit_sha}.tar.gz"

	src_artifact = hub.pkgtools.ebuild.Artifact(url=archive_url)
	await src_artifact.fetch()
	src_artifact.extract()

	majorversion = None
	minorversion = None

	data_filled = 0  # holds if nicessary information is filled

	with open(f"{src_artifact.extract_path}/{github_project}-{commit_sha}/src/appglobal.cpp") as f:
		for i in f.readlines():
			if i.startswith("const QString MAJORVERSION"):
				data_filled += 1
				majorversion = re.search(r'\"(.*)\"', i).groups()[0]
				if data_filled == 2:
					break

			elif i.startswith("const QString MINORVERSION"):
				data_filled += 1
				minorversion = re.search(r'\"(.*)\"', i).groups()[0]
				if data_filled == 2:
					break

	if data_filled != 2:
		raise hub.pkgtools.ebuild.BreezyError(
			f"Can't find version information in appglobal.cpp")

	version_string = f"{majorversion}{minorversion}.{commit_date}"

	# for nice archive file name
	artifact = hub.pkgtools.ebuild.Artifact(
		url=archive_url, final_name=f"{github_project}-{version_string}.tar.gz")

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version_string,
		artifacts=[artifact],
	)

	ebuild.push()
