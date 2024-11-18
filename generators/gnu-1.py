#!/usr/bin/env python3

from metatools.generator.common import common_init
from metatools.version import generic
from bs4 import BeautifulSoup
from packaging import version
import re
from urllib.parse import urljoin, urlsplit


# This autogen has been updated to put any new GNU ebuilds in "next" KEYWORDS, if they are the latest and
# greatest but not yet enabled in 1.4-release.

def get_version_from_href(href, name, extension):
	file = href.split("/")[-1]
	return file[len(name) + 1:-len(extension)]


def sort_url_and_vstr_tuples(tuple_list):
	# Do NOT use sorted() below. We need to catch individual exceptions below:
	unsorted_list = []
	for url, v_str in tuple_list:
		try:
			# initial sanity check to skip anything more complicated than 1.2.3 ( 1.2.3-rc1, for example):
			if not re.fullmatch('[\d.]+', v_str):
				raise version.InvalidVersion(f"skipping {v_str}")
			v_obj = generic.parse(v_str)
		except version.InvalidVersion:
			continue
		unsorted_list.append((url, v_str, v_obj))
	sorted_list = sorted(unsorted_list, key=lambda tup: tup[2])
	return list(sorted_list)


async def expand_url_path(hub, pkginfo):
	if "base_url" not in pkginfo:
		base_url = f"https://ftp.gnu.org/gnu/{pkginfo['name']}/"
	else:
		base_url = pkginfo["base_url"]
	if not base_url.endswith("/"):
		base_url += "/"
	cur_url = base_url
	dir_paths = []
	if "dir_paths" in pkginfo:
		dir_paths = pkginfo["dir_paths"]
	
	for dir_path_regex in dir_paths:
		src_data = await hub.pkgtools.fetch.get_page(base_url)
		soup = BeautifulSoup(src_data, "html.parser")
		url_and_vstr_tuples = []
		for link in soup.find_all("a"):
			full_url = urljoin(cur_url, link.get("href"))
			last_pathpart = urlsplit(full_url).path.rstrip('/').split('/')[-1]
			is_match = re.fullmatch(dir_path_regex, last_pathpart)
			if is_match:
				url_and_vstr_tuples.append((full_url, is_match.groups()[0]))
			else:
				hub.pkgtools.model.log.debug(f"Skipping path part {last_pathpart}")
		sorted_list = sort_url_and_vstr_tuples(url_and_vstr_tuples)
		if not len(sorted_list):
			raise IndexError(f"Could not find subpath matching regex '{dir_path_regex}' at {base_url}")
		else:
			base_url, vstr, vobj = sorted_list[-1]
	return base_url


async def generate(hub, **pkginfo):
	common_init(hub, pkginfo)
	app = pkginfo["name"]
	extension = f".tar.{pkginfo['compression']}"

	base_url = await expand_url_path(hub, pkginfo)
	src_data = await hub.pkgtools.fetch.get_page(base_url)
	soup = BeautifulSoup(src_data, "html.parser")

	hrefs = []

	for link in soup.find_all("a"):
		href = link.get('href')
		if href.endswith('/'):
			# we are looking for files, not paths:
			continue
		else:
			full_url = urljoin(base_url, href)
			last_pathpart = urlsplit(full_url).path.rstrip('/').split('/')[-1]
			if not last_pathpart.endswith(extension):
				hub.pkgtools.model.log.debug(f"Skipping {last_pathpart} (wrong extension)")
			elif not last_pathpart.startswith(f'{app}-'):
				hub.pkgtools.model.log.debug(f"Skipping {last_pathpart} (wrong name)")
			else:
				hub.pkgtools.model.log.debug(f"Processing {last_pathpart} (potentially good!)")
				hrefs.append(full_url)

	tuple_list = map(lambda href: (href, get_version_from_href(href, app, extension)), hrefs)
	href_tuples = sort_url_and_vstr_tuples(tuple_list)

	if not len(href_tuples):
		raise hub.pkgtools.ebuild.BreezyError(f"No valid tarballs found for {app}.")
	generate = []
	if "version" not in pkginfo or pkginfo["version"] == "latest":
		generate.append({"keywords": "*", "href": href_tuples[-1][0], "version": href_tuples[-1][1]})
	else:
		found_version = list(filter(lambda tup: tup[1] == pkginfo["version"], href_tuples))
		if not len(found_version):
			raise hub.pkgtools.ebuild.BreezyError(f"Specified version {pkginfo['version']} for {app} not found.")
		elif len(found_version) > 1:
			raise hub.pkgtools.ebuild.BreezyError(f"Odd -- multiple matching versions for {app}!?")
		found_version = found_version[0]
		if found_version[1] == href_tuples[-1][1]:
			# the specified version is the latest:
			generate.append({"keywords": "*", "href": href_tuples[-1][0], "version": href_tuples[-1][1]})
		else:
			# the specified version is not the latest version:
			if "restrict" in pkginfo and pkginfo["restrict"] == "next":
				pass
			else:
				if not "version" in pkginfo:
					generate.append({"keywords": "next", "href": href_tuples[-1][0], "version": href_tuples[-1][1]})
			generate.append({"keywords": "*", "href": found_version[0], "version": found_version[1]})
	common_artifacts = pkginfo["artifacts"] if "artifacts" in pkginfo else {}
	if "artifacts" in pkginfo:
		del pkginfo["artifacts"]
	for gen in generate:
		pkginfo.update(gen)
		local_artifacts = common_artifacts.copy()
		local_artifacts["global"] = hub.Artifact(url=gen['href'])
		ebuild = hub.pkgtools.ebuild.BreezyBuild(
			**pkginfo,
			artifacts=local_artifacts
		)
		ebuild.push()

# vim: ts=4 sw=4 noet
