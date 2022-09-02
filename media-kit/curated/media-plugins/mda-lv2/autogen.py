#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	"""
	All the information we need from Gitlab is the domain where it's installed
	and the project ID. It's also possible, albeit not documented, access the
	project through the URL-encoded "name/repo" information in place of the number id.
	
	The URL will look like this:
	* For tags:
		https://gitlab.com/api/v4/projects/15267922/repository/tags
	* For releases:
		https://gitlab.com/api/v4/projects/15267922/releases
	
	There isn't really a point in querying tags, as the releases json contains
	all the tag names that matter, as well as all the assets associated to that release.

	If you'd like to access the API through name/repo instead of project id,
	it is possible, although I haven't found it in the documentation.  In order to
	do that, you need to url-encode the string "name/repo" and use it in place of the
	project ID.

	For example, say we have:
		gitlab_name = drobilla
		gitlab_repo = mda-lv2

	This is how we could adjust that to use in a 
		from urllib.parse import quote_plus
		name_repo=quote_plus(f"{gitlab_name}/{gitlab_repo}") # this renders "drobilla%2Fmda-lv2"
	
	And then use that in hour API request instead of the project ID:
		https://gitlab.com/api/v4/projects/drobilla%2Fmda-lv2/repository/tags
		https://gitlab.com/api/v4/projects/drobilla%2Fmda-lv2/releases

	"""
	gl_domain="gitlab.com"
	gl_id="15267922"

	tags_dict = await hub.pkgtools.fetch.get_page(
		f"https://{gl_domain}/api/v4/projects/{gl_id}/releases",
		is_json=True
	)
	version = tags_dict[0]["tag_name"].lstrip("v")
	# This repository offers "sources" assets in 4 formats: 
	# [0]="zip", [1]="tar.gz", [2]="tar.bz2", [3]="tar"

	# Ideally, we should write code to loop through the assets and
	# get the best format.  There is no guarantee that [1] will be
	# "tar.gz" for every repository or that will even be more than
	# one option of formats.
	url = tags_dict[0]["assets"]["sources"][1]["url"]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()

# vim: ts=4 sw=4 noet
