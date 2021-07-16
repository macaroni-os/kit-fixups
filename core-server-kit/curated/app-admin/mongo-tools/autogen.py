#!/usr/bin/env python3

# mongo-tools has a history of tagging releases before they are really released. So we want to look at the Web site
# to get the official release version of mongo-tools. Then we go to GitHub to get the sources, because mongo isn't
# providing an official source tarball. We assume that by the time the version is posted on the Web site, the mongo
# team has finished messing with their tags.

from bs4 import BeautifulSoup

async def get_version_from_website(hub, **pkginfo):
	html = await hub.pkgtools.fetch.get_page("https://www.mongodb.com/download-center/database-tools/releases/archive")
	for a in BeautifulSoup(html, features="html.parser").find_all('a', href=True):
		href = a['href']
		file = href.split('/')[-1]
		if file.endswith(".tgz") and file.startswith("mongodb-database-tools"):
			return file[:-4].split("-")[-1]

async def generate(hub, **pkginfo):
	github_user = "mongodb"
	github_repo = "mongo-tools"
	ver = await get_version_from_website(hub, **pkginfo)
	# Note that if we needed to get specific info on this one tag without looking through all tags, we could do:
	# tag_meta = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{github_user}/{github_repo}/git/ref/tags/{ver}", is_json=True)
	# tag_info = await hub.pkgtools.fetch.get_page(tag_meta['object']['url'], is_json=True)
	url = f"https://github.com/{github_user}/{github_repo}/archive/{ver}.tar.gz"
	final_name = f'{pkginfo["name"]}-{ver}.tar.gz'
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=github_user,
		github_repo=github_repo,
		version=ver,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
