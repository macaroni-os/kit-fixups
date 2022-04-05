#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):
	github_user = "python"
	github_repo = "cpython"
	json_list = await hub.pkgtools.fetch.get_page(
		f"https://api.github.com/repos/{github_user}/{github_repo}/tags?per_page=100", is_json=True
#	) + await hub.pkgtools.fetch.get_page(
#		f"https://api.github.com/repos/{github_user}/{github_repo}/tags?per_page=100&page=2", is_json=True
	)

	versions = [ "2.7.18" ]
	minor = 10000
	for tag in json_list:
		v = re.match(r"v((\d+).(\d+).\d+\b)(?!-)", tag["name"])
		if v is None:
			continue

		if int(v[3]) >= int(minor):
			continue

		major, minor = v[2], v[3]
		if f"{major}.{minor}" not in ["3.7", "3.8", "3.9", "3.10"]:
			continue

		versions.append(v[1])

	for version in versions:
		shortver = "_".join(version.split(".")[0:2])
		python_url = f"https://www.python.org/ftp/python/{version}/Python-{version}.tar.xz"
		patches_url = f"https://dev.gentoo.org/~mgorny/dist/python/python-gentoo-patches-{version}.tar.xz"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			artifacts=[
				hub.pkgtools.ebuild.Artifact(url=python_url),
				hub.pkgtools.ebuild.Artifact(url=patches_url),
			],
			template=f'{pkginfo["name"]}{shortver}.tmpl',
		)
		ebuild.push()


# vim: ts=4 sw=4 noet
