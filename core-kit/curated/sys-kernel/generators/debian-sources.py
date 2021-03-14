#!/usr/bin/python3

from bs4 import BeautifulSoup

GLOBAL_DEFAULTS = {}
generated_versions = set()


async def get_version_for_release(release_name):
	tracker_data = await hub.pkgtools.fetch.get_page("https://tracker.debian.org/pkg/linux")
	tracker_soup = BeautifulSoup(tracker_data, "lxml")
	target_release = next(x for x in tracker_soup.find_all("span", class_="versions-repository") if x.text.strip()[:-1] == release_name)
	return target_release.parent.find("a").text.split("-")


async def generate(hub, **pkginfo):
	global generated_versions

	if 'patches' not in pkginfo:
		raise hub.pkgtools.ebuild.BreezyError("No patches!")

	if pkginfo.get("name") == "debian-sources":
		release_type = "unstable"
	else:
		release_type = "stable"
	if pkginfo['version'] == 'latest':
		deb_pv_base, deb_extraversion = await get_version_for_release(release_type)
		pkginfo["version"] = f"{deb_pv_base}_p{deb_extraversion}"
	else:
		# Parse the specified version in the autogen.yaml. We expect a "_p" to specify the patchlevel. All kernel
		# packages have a patchlevel of at least 1.
		#
		# We will need to do some string manipulation to get the base version and the patchlevel separated:
		vsplit = pkginfo['version'].split(".")
		if "_p" not in vsplit[-1]:
			raise hub.pkgtools.ebuild.BreezyError(f"Please specify _p patchlevel in {pkginfo['name']} for {pkginfo['version']}")
		last_vpart, deb_extraversion = vsplit[-1].split("_p")
		vsplit[-1] = last_vpart
		deb_pv_base = '.'.join(vsplit)

	# Don't generate a version twice -- which can happen if we list a version that is also 'latest':

	deb_pv = f"{deb_pv_base}-{deb_extraversion}"
	if deb_pv in generated_versions:
		return

	base_url = f"http://http.debian.net/debian/pool/main/l/linux"

	k_artifact = hub.pkgtools.ebuild.Artifact(url=f"{base_url}/linux_{deb_pv_base}.orig.tar.xz")
	p_artifact = hub.pkgtools.ebuild.Artifact(url=f"{base_url}/linux_{deb_pv}.debian.tar.xz")

	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo,
	    deb_pv=deb_pv,
	    deb_extraversion=deb_extraversion,
		linux_version=deb_pv_base,
		artifacts=[k_artifact, p_artifact])
	ebuild.push()
	generated_versions.add(deb_pv)


# vim: ts=4 sw=4 noet
