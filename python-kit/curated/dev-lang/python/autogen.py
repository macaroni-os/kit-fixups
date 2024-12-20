#!/usr/bin/env python3

import re


async def generate(hub, **pkginfo):
	versions = [ ]
	minor = 10000
	async for tag in hub.pkgtools.github.iter_all_tags(hub, "python", "cpython"):
		v = re.match(r"v((\d+).(\d+).\d+\b)(?!-)", tag["name"])
		if v is None:
			continue

		if int(v[3]) >= int(minor):
			continue

		major, minor = v[2], v[3]
		if f"{major}.{minor}" not in ["3.7", "3.8", "3.9", "3.10"]:
			continue

		versions.append(v[1])

	revision = {
		"3.10.4" : "1",
	}

	for version in versions:
		shortver = "_".join(version.split(".")[0:2])
		python_url = f"https://www.python.org/ftp/python/{version}/Python-{version}.tar.xz"
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			version=version,
			revision=revision,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=python_url)],
			template=f'{pkginfo["name"]}{shortver}.tmpl',
		)
		ebuild.push()


# vim: ts=4 sw=4 noet
