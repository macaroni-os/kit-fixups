#!/usr/bin/env python3
from collections import defaultdict
# Please report any problems with this generator.  It is expected to work well
# for any web page serving as a directory listing.


from distutils.version import LooseVersion
import re


def get_file_values(d):
	"""
	This gets values from a dictionary/list and also handles dictionaries nested on level deep.
	For example: { "foo" : { "bar" : "oni" }} as a parameter would return [ "oni" ].
	"""
	keys = []
	if isinstance(d, list):
		for item in d:
			keys.append(item)
	else:
		for k, v in d.items():
			keys += v
	return keys


def get_file_keys(d):
	"""
	This gets the proper conditional USE keys for all files.
	"""
	file_keys = {}
	if isinstance(d, list):
		for item in d:
			file_keys[item] = 'global'
	else:
		for k, v in d.items():
			for vv in v:
				file_keys[vv] = k
	return file_keys


def files_to_artifacts(hub, pkginfo, files_l, file_keys, release):
	"""
	This converts YAML files: data to artifacts= data, respecting conditional USE.
	d is the files dictionary to convert.
	"""
	base_url = pkginfo['dir']['url']
	artifacts = {'global': []}

	for f, fn in release.items():
		if f in files_l:
			artifacts[file_keys[f]] = hub.Artifact(url=f"{base_url}{fn}")
	return artifacts


async def generate(hub, **pkginfo):
	release_data = await hub.pkgtools.fetch.get_page(
		pkginfo['dir']['url'], is_json=False
	)
	files = pkginfo['name']
	if 'files' in pkginfo['dir']:
		all_files = get_file_values(pkginfo['dir']['files'])
		# a logical OR list of files from YAML; regex satisfied if matches any.
		files += '|' + '|'.join(all_files)
	# ordered by appearance order on the page
	releases = [
		[x[3], dict(zip(['filename', 'name-ver', 'name', 'ver'], x))]
		# returns ('file-version.extension', 'file-version, 'version') triples
		for x in re.findall(
			# start searching at 'href="'
			# find exactly one instance of a file name followed by a '-'
			#   (a '.' also can be accepted instead)
			#   # TODO:  custom delimiter defined in yaml
			# then exactly one instance of a version numbering scheme
			#  - one or more integers
			#  - then zero or more instances of '.x' or '-abc_def123' etc.
			#  - allow for alphanumeric ASCII characters after first '.'
			# finally, the file extension
			f'(?<=href=")(((?:({files})?[\.|-])?(\d+(?:[\.|-][a-zA-Z0-9_]+)*)+)'
			+ (
				f"\.({re.escape(pkginfo['dir']['format'])})+"
				if 'format' in pkginfo['dir']
				else f'\.(tar\.gz|tar\.bz2|tar\.xz|zip)+'
			)
			+ ')"',
			release_data
		)
	]
	if not releases:
		raise KeyError(
			f"Unable to find a suitable version for {pkginfo['cat']}"
			+ f"/{pkginfo['name']}."
		)

	# if a specific version is requested, check that it actually exists
	if 'version' in pkginfo:
		# latest always matches
		if pkginfo['version'] == 'latest':
			pass
		elif not any(pkginfo['version'] == ver for ver, release in releases):
			raise KeyError(
				f"Requested version {pkginfo['cat']}/{pkginfo['name']}"
				+ f"-{pkginfo['version']} not found!"
			)

	# create a list of releases sorted by version
	versions_l = [
		[
			ver, {
			z['name']: z['filename']
			# iterate over the files in a version
			for q, z in releases if q == ver
		}
		]
		# restrict so that only unique versions are included
		for ver in sorted(list(set(h for h, k in releases)), key=LooseVersion)
	]

	# Highest version is assumed to be either the first or last entry.
	# Some directories listings are ordered ascending from oldest to newest,
	# some list files descending from newest to oldest. We want the newest file
	# (the first one in 'descending' listing or the last in 'ascending' ones).
	ver, release = (
		versions_l[-1]
		if 'order' in pkginfo['dir']
		   and 'asc' in pkginfo['dir']['order']
		else versions_l[0]
	)
	if not 'version' in pkginfo or (
			'version' in pkginfo and pkginfo['version'] == 'latest'
	):
		pkginfo['version'] = ver

	# if no 'files' key defined in YAML, just add 'name' to the list of files.
	files_l = []
	if 'files' in pkginfo['dir']:
		files_l = get_file_values(pkginfo['dir']['files'])
		file_keys = get_file_keys(pkginfo['dir']['files'])
	else:
		files_l.append(pkginfo['name'])
		file_keys = { pkginfo['name'] : 'global'}

	# iterate over list of files in the chosen release
	artifacts = files_to_artifacts(hub, pkginfo, files_l, file_keys, release)

	if 'additional_artifacts' in pkginfo:
		for key, url in pkginfo['additional_artifacts'].items():
			artifacts += files_to_artifacts(
				hub,
				pkginfo,
				additional_artifacts.values(),
				additional_artifacts.keys(),
				release
		)

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		artifacts=artifacts
	)
	ebuild.push()

# vim: :et sw=4 ts=4 noet
