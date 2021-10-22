#!/usr/bin/python3

from bs4 import BeautifulSoup
import re

release_urls = {
	"stable": "https://deb.debian.org/debian/pool/main/l/linux",
	"unstable": "https://deb.debian.org/debian/pool/main/l/linux",
	"stable-sec": "https://security.debian.org/debian-security/pool/updates/main/l/linux"
}

stability = {
	"debian-sources": "unstable",
	"debian-sources-lts": "stable"
}


def iter_upstream_release(release_name, tracker_soup):
	"""
	This simply yields available releases for a specific kernel. Two strings are returned --
	the kernel version and the debian extra_version. What gets yielded is in order from
	most recent to oldest.
	"""
	for release in tracker_soup.find_all("span", class_="versions-repository"):
		if release.text.strip()[:-1] == release_name:
			yield release.parent.find("a").text.split("-")


def gen_latest(pkginfo, all_versions_from_yaml, tracker_soup):
	"""
	This function will yield pkginfo for generating the 'latest' version of a kernel. It may yield
	more than one pkginfo, because if 'latest' is specified, the latest one may be masked in our
	regular release. We want to make sure to yield a latest version that is unmasked in our regular
	release too.

	``all_versions_from_yaml`` is included because we don't want to auto-generate 'latest' kernel
	if it is already specified in our YAML, likely with more specific instructions. So in this case,
	we will not yield it here.
	"""
	name = pkginfo.get('name')
	unmask_match = pkginfo.get("unmask_match", None)
	unmask_found = False

	# We will loop until we have (attempted) to yield a package that is 'latest unmasked' (so regular release has an
	# ebuild.)

	for result in iter_upstream_release(pkginfo['release_name'], tracker_soup):
		if result is None:
			break
		linux_version, deb_extraversion = result
		version = f"{linux_version}_p{deb_extraversion}"

		if 'unmasked' in pkginfo and not pkginfo['unmasked']:
			# go directly to jail:
			unmasked = False
		else:
			# maybe we let you see the light of day:
			unmasked = True
			if unmask_match:
				matched = re.match(unmask_match, version)
				if not matched:
					unmasked = False

		if unmasked:
			unmask_found = True

		if f"{name}-{version}" in all_versions_from_yaml:
			# We will skip this because we have a specific definition for this package in our YAML already:
			continue

		pkginfo['unmasked'] = unmasked
		pkginfo["version"] = version
		pkginfo["linux_version"] = linux_version
		pkginfo["deb_extraversion"] = deb_extraversion
		yield pkginfo

		if unmask_found:
			# We yielded a kernel that will be unmasked in our normal release, so we are done.
			break


def finalize_specific_pkginfo(pkginfo):
	"""
	We are finalizing the pkginfo for a kernel that has a version specified in the YAML. In this case, we
	expect the version to contain a '_p', specifying the patchlevel. We will use this to set linux_version and
	deb_pv_extraversion.

	:param pkginfo: pkginfo from the YAML
	:type pkginfo: dict
	:return: pkginfo, updated and ready for ``generate()``
	:rtype: dict
	"""

	vsplit = pkginfo["version"].split(".")
	if "_p" not in vsplit[-1]:
		raise hub.pkgtools.ebuild.BreezyError(f"Please specify _p patchlevel in {pkginfo['name']} for {pkginfo['version']}")
	last_vpart, pkginfo["deb_extraversion"] = vsplit[-1].split("_p")
	vsplit[-1] = last_vpart
	pkginfo["linux_version"] = ".".join(vsplit)
	return pkginfo


async def preprocess_packages(hub, pkginfo_list):
	"""
	This is a new feature being added to metatools that provides a 'hook' to look at all the YAML that will be
	passed to the ``generate()`` function so you can make modifications as needed. This is an async generator
	and should ``yield`` all pkginfo that should be actually generated. Arbitrary modifications can be made to
	the pkginfo. Anything not yielded is not generated.

	What this code is specifically doing for debian-sources is augmenting the 'pkginfo' for each YAML definition
	to include the element 'release_name', which is used to look up the proper URLs for grabbing the source code,
	and then it calls two helper functions (``finalize_latest_pkginfo`` and ``finalize_specific_pkginfo`` to 
	provide further additions to each package's ``pkginfo`` before autogen truly begins.

	:param hub: metatools hub
	:type hub: Hub
	:param pkginfo_list: a list of pkginfo dicts
	:type pkginfo_list: list
	"""
	tracker_data = await hub.pkgtools.fetch.get_page("https://tracker.debian.org/pkg/linux")
	all_versions_from_yaml = list(map(lambda l: f"{l['name']}-{l['version']}", pkginfo_list))
	
	tracker_soup = BeautifulSoup(tracker_data, "lxml")

	for pkginfo in pkginfo_list:
		name = pkginfo['name']
		if 'release_name' not in pkginfo:
			if name in stability:
				pkginfo['release_name'] = stability[name]
		
		if pkginfo["version"] == "latest":
			# This could yield more than one pkginfo. It's possible we might want to gen two 'latest' packages,
			# one for next-release and one for our releases. If we don't do this, we could end up with no unmasked
			# packages in our release if the latest would be masked!
			for pkginfo in gen_latest(pkginfo, all_versions_from_yaml, tracker_soup):
				yield pkginfo
		else:
			pkginfo = finalize_specific_pkginfo(pkginfo)
		if pkginfo is not None:
			yield pkginfo


async def generate(hub, **pkginfo):
	name = pkginfo.get('name')
	base_url = release_urls[pkginfo['release_name']]
	linux_version = pkginfo.get("linux_version")
	deb_extraversion = pkginfo.get("deb_extraversion")
	deb_pv = f"{linux_version}-{deb_extraversion}"
	k_artifact = hub.pkgtools.ebuild.Artifact(url=f"{base_url}/linux_{linux_version}.orig.tar.xz")
	p_artifact = hub.pkgtools.ebuild.Artifact(url=f"{base_url}/linux_{deb_pv}.debian.tar.xz")
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo, artifacts=[k_artifact, p_artifact])
	ebuild.push()


# vim: ts=4 sw=4 noet tw=120
