#!/usr/bin/python3

from bs4 import BeautifulSoup

GLOBAL_DEFAULTS = {}
generated_versions = dict()


async def get_version_for_release(release_name):
	tracker_data = await hub.pkgtools.fetch.get_page("https://tracker.debian.org/pkg/linux")
	tracker_soup = BeautifulSoup(tracker_data, "lxml")
	target_release = next(x for x in tracker_soup.find_all("span", class_="versions-repository") if x.text.strip()[:-1] == release_name)
	return target_release.parent.find("a").text.split("-")


async def generate(hub, **pkginfo):
	release_prefix = "deb-"
	deb_pv_base = pkginfo.get("deb_pv_base")
	deb_extraversion = pkginfo.get("deb_extraversion")
	if deb_pv_base.startswith(release_prefix):
		deb_pv_base, deb_extraversion = await get_version_for_release(deb_pv_base.lstrip(release_prefix))
	base_url = f"http://http.debian.net/debian/pool/main/l/linux"
	deb_pv = f"{deb_pv_base}-{deb_extraversion}"
	k_artifact = hub.pkgtools.ebuild.Artifact(url=f"{base_url}/linux_{deb_pv_base}.orig.tar.xz")
	p_artifact = hub.pkgtools.ebuild.Artifact(url=f"{base_url}/linux_{deb_pv}.debian.tar.xz")
	version = pkginfo["version"] = f"{deb_pv_base}_p{deb_extraversion}"
	pkginfo["deb_extraversion"] = deb_extraversion
	unmasked = pkginfo["unmasked"]
	global generated_versions
	prev_result = generated_versions.get(version, None)
	if prev_result is None or not prev_result and unmasked:
		ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo, linux_version=deb_pv_base, artifacts=[k_artifact, p_artifact])
		ebuild.push()
		generated_versions[version] = unmasked


# vim: ts=4 sw=4 noet
