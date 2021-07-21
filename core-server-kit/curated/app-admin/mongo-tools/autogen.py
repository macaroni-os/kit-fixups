#!/usr/bin/env python3

# mongo-tools has a history of tagging releases before they are really released. So we want to look at the Web site
# to get the official release version of mongo-tools. Then we go to GitHub to get the sources, because mongo isn't
# providing an official source tarball. We assume that by the time the version is posted on the Web site, the mongo
# team has finished messing with their tags.
#
# See: FL-8652, FL-8633

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
	
	# STEP 1: Get released version string from official Web site, because we don't want in-progress not-yet-released tags (a prior issue):
	ver = await get_version_from_website(hub, **pkginfo)
	
	# STEP 2: Look for GitHub tag with this version, and get its info. Since it's officially released, the tag sha1 shouldn't change:
	tag_meta = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{github_user}/{github_repo}/git/ref/tags/{ver}", is_json=True)
	
	# STEP 3: Now, get the *commit* sha1 from the tag, which also shouldn't change:
	tag_info = await hub.pkgtools.fetch.get_page(tag_meta['object']['url'], is_json=True)
	commit_sha1 = tag_meta['object']['sha']

	# STEP 4: Use the commit sha1 to grab the tarball, and name it with part of the SHA1 in the tarball name to avoid conflicts -- just
	#         in case we're wrong and upstream re-tags -- it will still work! :)

	url = f"https://github.com/{github_user}/{github_repo}/archive/{commit_sha1}.tar.gz"
	final_name = f'{pkginfo["name"]}-{ver}-{commit_sha1[:8]}.tar.gz'

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		github_user=github_user,
		github_repo=github_repo,
		version=ver,
		commit_sha1=commit_sha1,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
