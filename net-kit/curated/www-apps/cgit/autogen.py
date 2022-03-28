#!/usr/bin/env python3

from bs4 import BeautifulSoup
import re
import os

async def generate(hub, **pkginfo):
	python_compat = "python3+"
	name = pkginfo.get('name')
	url = f"https://git.zx2c4.com/cgit/"
	html = await hub.pkgtools.fetch.get_page(url + "refs/tags", is_json=False)
	soup = BeautifulSoup(html, features="html.parser").find_all('a', href=True)

	for pkg in soup:
		if (name in pkg.contents[0] and pkg.contents[0].endswith('tar.xz')):
			latest_release = pkg.contents[0]
			break

	version = latest_release.rsplit("-")[-1].split(".tar")[0]
	artifact = hub.pkgtools.ebuild.Artifact(url=url + "snapshot/" + latest_release)

	await artifact.fetch()
	artifact.extract()

	makefile = open(
		os.path.join(artifact.extract_path, f"{name}-{version}", "Makefile")
	).read()

	git_ver = re.search("GIT_VER = ([0-9.]+)", makefile).group(1)
	git_url = f"https://www.kernel.org/pub/software/scm/git/git-{git_ver}.tar.xz"
	git_artifact = hub.pkgtools.ebuild.Artifact(url=git_url)

	artifact.cleanup()
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		python_compat=python_compat,
		git_ver=git_ver,
		artifacts=[artifact, git_artifact],
		version=version
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
