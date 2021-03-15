#!/usr/bin/python3

from bs4 import BeautifulSoup


async def get_version_for_release(release_name):
	tracker_data = await hub.pkgtools.fetch.get_page("https://tracker.debian.org/pkg/linux")
	tracker_soup = BeautifulSoup(tracker_data, "lxml")
	target_release = next(x for x in tracker_soup.find_all("span", class_="versions-repository") if x.text.strip()[:-1] == release_name)
	return target_release.parent.find("a").text.split("-")


async def finalize_latest_pkginfo(pkginfo, all_versions_from_yaml):
	"""
	We are finalizing the pkginfo for a kernel specified as 'latest'. We will need to determine the latest
	version using HTTP. If the latest version matches a specific version in the YAML, return None -- because
	we don't want to generate this version but instead should skip it and generate the one directly specified
	in the YAML. Otherwise return updated pkginfo, ready for processing by ``generate()``.

	:param pkginfo: pkginfo dictionary
	:type pkginfo: dict
	:param all_versions_from_yaml: a list of all version strings specified in the YAML
	:type all_versions_from_yaml: list
	:return: an updated pkginfo dictionary for ``generate()``, or None.
	:rtype: dict or None
	"""
	name = pkginfo.get("name")
	if name == "debian-sources":
		release_type = "unstable"
	else:
		release_type = "stable"
	linux_version, deb_extraversion = await get_version_for_release(release_type)
	version = f"{linux_version}_p{deb_extraversion}"
	if f"{name}-{version}" in all_versions_from_yaml:
		# YAML specifies the literal version -- so ignore 'latest' and use that more specific YAML instead
		return None
	unmask_match = pkginfo.get('unmask_match', None)
	if unmask_match is None or version.startswith(unmask_match):
		# Generate 'latest' version
		pkginfo['version'] = version
		pkginfo['linux_version'] = linux_version
		pkginfo['deb_extraversion'] = deb_extraversion
		return pkginfo
	else:
		# Don't generate -- we didn't see an expected unmask_match pattern:
		return None


async def finalize_specific_pkginfo(pkginfo):
	"""
	We are finalizing the pkginfo for a kernel that has a version specified in the YAML. In this case, we
	expect the version to contain a '_p', specifying the patchlevel. We will use this to set linux_version and
	deb_pv_extraversion.

	:param pkginfo: pkginfo from the YAML
	:type pkginfo: dict
	:return: pkginfo, updated and ready for ``generate()``
	:rtype: dict
	"""

	vsplit = pkginfo['version'].split(".")
	if "_p" not in vsplit[-1]:
		raise hub.pkgtools.ebuild.BreezyError(
			f"Please specify _p patchlevel in {pkginfo['name']} for {pkginfo['version']}")
	last_vpart, pkginfo['deb_extraversion'] = vsplit[-1].split("_p")
	vsplit[-1] = last_vpart
	pkginfo['linux_version'] = '.'.join(vsplit)
	return pkginfo


async def preprocess_packages(hub, pkginfo_list):
	"""
	This is a new feature being added to metatools that provides a 'hook' to look at all the YAML that will be
	passed to the ``generate()`` function so you can make modifications as needed. This is an async generator
	and should ``yield`` all pkginfo that should be actually generated. Arbitrary modifications can be made to
	the pkginfo. Anything not yielded is not generated.

	:param hub: metatools hub
	:type hub: Hub
	:param pkginfo_list: a list of pkginfo dicts
	:type pkginfo_list: list
	"""
	all_versions_from_yaml = list(map(lambda l: f"{l['name']}-{l['version']}", pkginfo_list))
	for pkginfo in pkginfo_list:
		if pkginfo['version'] == 'latest':
			pkginfo = await finalize_latest_pkginfo(pkginfo, all_versions_from_yaml)
		else:
			pkginfo = await finalize_specific_pkginfo(pkginfo)
		if pkginfo is not None:
			yield pkginfo


async def generate(hub, **pkginfo):
	base_url = f"http://http.debian.net/debian/pool/main/l/linux"

	linux_version = pkginfo.get("linux_version")
	deb_extraversion = pkginfo.get("deb_extraversion")
	deb_pv = f"{linux_version}-{deb_extraversion}"
	k_artifact = hub.pkgtools.ebuild.Artifact(url=f"{base_url}/linux_{linux_version}.orig.tar.xz")
	p_artifact = hub.pkgtools.ebuild.Artifact(url=f"{base_url}/linux_{deb_pv}.debian.tar.xz")
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo, artifacts=[k_artifact, p_artifact])
	ebuild.push()


# vim: ts=4 sw=4 noet
