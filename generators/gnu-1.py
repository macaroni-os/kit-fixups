#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging import version

# This autogen has been updated to put any new GNU ebuilds in "next" KEYWORDS, if they are the latest and
# greatest but not yet enabled in 1.4-release.

def get_version_from_href(href, name, extension):
	file = href.split("/")[-1]
	return file[len(name)+1:-len(extension)]

def filter_valid_href(href, name, extension):
	"""
	Assuming ``name`` is "gzip" and ``extension`` is ".tar.gz", this will look at ``href``, a URL or file, and
	return True if it points to a file starting with "gzip-" and ending with ".tar.gz". This is used on
	directory listings to validate that the URLs we are looking at appear to be pointing to the tarball
	we care about. This function is to be used with ``filter()``.
	"""
	if not href.endswith(extension):
		return False
	if not href.split("/")[-1].startswith(f"{name}-"):
		return False
	return True

def filter_and_sort_hrefs(hrefs, name, extension):
	"""
	Given a list of URLs or files from a directory listing (``hrefs``), this function will return a list of tuples.
	The tuples will consist of the original URL/file string, along with the extracted version, and the list will be
	sorted (from least to greatest) by version using version.parse. For example::

	  [ ( "gzip-1.0.tar.gz", "1.0" ), ( "gzip-2.0.tar.gz" , "2.0" ) ]
	
	Note that any bogus files or URLS -- those not starting with ``name`` or ending with ``extension`` -- thus pointing
	to things we don't care about -- will be removed from the output.
	"""
	valid_list = filter(lambda href: filter_valid_href(href, name, extension), hrefs)
	tuple_list = map(lambda href: (href, get_version_from_href(href, name, extension)), valid_list)
	sorted_list = sorted(tuple_list, key=lambda tup: version.parse(tup[1]))
	return list(sorted_list)

async def generate(hub, **pkginfo):
	app = pkginfo["name"]
	extension = f".tar.{pkginfo['compression']}"
	src_url = f"https://ftp.gnu.org/gnu/{app}/"
	src_data = await hub.pkgtools.fetch.get_page(src_url)
	soup = BeautifulSoup(src_data, "html.parser")

	hrefs = []

	for link in soup.find_all("a"):
		hrefs.append(link.get("href"))
	href_tuples = filter_and_sort_hrefs(hrefs, app, extension)

	if not len(href_tuples):
		raise hub.pkgtools.ebuild.BreezyError(f"No valid tarballs found for {app}.")

	generate = []
	if "version" not in pkginfo or pkginfo["version"] == "latest":
		generate.append({ "keywords" : "*", "href" : href_tuples[-1][0], "version" : href_tuples[-1][1]})
	else:
		found_version = list(filter(lambda tup: tup[1] == pkginfo["version"], href_tuples))
		if not len(found_version):
			raise hub.pkgtools.ebuild.BreezyError(f"Specified version {pkginfo['version']} for {app} not found.")
		elif len(found_version) > 1:
			raise hub.pkgtools.ebuild.BreezyError(f"Odd -- multiple matching versions for {app}!?")
		found_version = found_version[0]
		if found_version[1] == href_tuples[-1][1]:
			# the specified version is the latest:
			generate.append({ "keywords" : "*", "href" : href_tuples[-1][0], "version" : href_tuples[-1][1]})
		else:
			# the specified version is not the latest version:
			generate.append({ "keywords" : "next", "href" : href_tuples[-1][0], "version" : href_tuples[-1][1]})
			generate.append({ "keywords" : "*", "href" : found_version[0], "version" : found_version[1]})
				
	for gen in generate:
		pkginfo.update(gen)
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			artifacts=[hub.pkgtools.ebuild.Artifact(url=f"{src_url}/{gen['href']}")],
		)
		ebuild.push()


# vim: ts=4 sw=4 noet
