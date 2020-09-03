#!/usr/bin/env python3

import json


async def generate(hub, **pkginfo):
	GITHUB_USER = "saghul"
	GITHUB_REPO = "aiodns"
	GITHUB_COMMIT = "d653c5c8fb475e3ea7fd06792d97a56ad974710d"
	GITHUB_DATE = "2019.12.12"
	json_data = await hub.pkgtools.fetch.get_page(f'https://pypi.org/pypi/{pkginfo["name"]}/json')
	json_dict = json.loads(json_data)
	version = json_dict["info"]["version"]
	if version == "2.0.0":
		# If latest version is 2.0.0, use GitHub tag instead as it has fixes:
		artifact = hub.pkgtools.ebuild.Artifact(
			url=f"https://www.github.com/{GITHUB_USER}/{GITHUB_REPO}/tarball/{GITHUB_COMMIT}",
			final_name=f"{pkginfo['name']}-{GITHUB_COMMIT}.tar.gz",
		)
		version = f"2.0.0.{GITHUB_DATE}"
	else:
		# Something newer? Cool! Use it!
		GITHUB_COMMIT = None
		for art_dict in json_dict["releases"][version]:
			if art_dict["packagetype"] == "sdist":
				artifact = hub.pkgtools.ebuild.Artifact(url=art_dict["url"])
				break
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		GITHUB_COMMIT=GITHUB_COMMIT,
		GITHUB_REPO=GITHUB_REPO,
		GITHUB_USER=GITHUB_USER,
		python_compat="python3_{6,7,8} pypy3",
		artifacts=[artifact],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
