#!/usr/bin/env python3

import re 

arches = {
	"x64": "amd64",
	"x86": "x86",
	"arm": "arm",
	"aarch64": "arm64",
	"ppc64le": "ppc64",
	"riscv64": "riscv64",

}
JDK_MAX_RELEASE = 21

def generate_bin_artifacts(hub, binaries_data, **pkginfo):
	artifacts = {}
	image_type = "jdk"
	if "jre" in pkginfo["name"]:
		image_type = "jre"
	for bin_data in binaries_data:
		if bin_data["os"] != "linux":
			continue
		if bin_data["image_type"] != image_type:
			continue
		if bin_data["architecture"] in arches:
			url = bin_data['package']['link']
			artifacts[arches[bin_data['architecture']]] = hub.pkgtools.ebuild.Artifact(url=url)
	return artifacts

async def generate(hub, **pkginfo):
	rel_url = "https://api.adoptium.net/v3/info/available_releases"
	rel_data = await hub.pkgtools.fetch.get_page(rel_url, is_json=True)

	releases = rel_data["available_lts_releases"]
	if rel_data["most_recent_feature_release"] not in releases:
		releases.append(rel_data["most_recent_feature_release"])

	for release in releases:
		if int(release) > JDK_MAX_RELEASE:
			continue
		local_pkginfo = pkginfo.copy()
		src_url = f"https://api.adoptium.net/v3/assets/feature_releases/{release}/ga"
		src_data = await hub.pkgtools.fetch.get_page(src_url, is_json=True)
		if not len(src_data):
			hub.pkgtools.model.log.error(f"Can't find openjdk release data for release {release}")
			continue
		elif "source" not in src_data[1]:
			hub.pkgtools.model.log.error(f"Can't find 'source' in release data for release {release}")
			continue
		src_artifact = src_data[1]["source"]["link"]
		src_path = src_data[1]["release_name"]
		for suffix in [ "", "-bin", "-jre-bin"]:
			local_pkginfo["name"] = pkginfo["name"] + suffix
			template = local_pkginfo["name"]
			artifacts = [hub.pkgtools.ebuild.Artifact(url=src_artifact)]
			version = src_path.lstrip("jdk-").replace("+","_p")
			if release == 8:
				version = src_path.lstrip("jdk").replace("u",".").replace("-b","_p")
				template = template + "-8"
			local_pkginfo["template"] = template + ".tmpl"
			if "-bin" in suffix:
				artifacts = generate_bin_artifacts(hub,src_data[1]["binaries"],**local_pkginfo)
			if len(artifacts) == 0:
				continue
			# FL-12236: Some openjdk versions may have a "_p7.1" version which is invalid for ebuilds.
			# This code adapts "_p7.1" to be "_p7-r1" (using revision) which should allow Portage to
			# find latest version properly and is also a proper ebuild version. "baddy" is used to
			# detect this condition:
			baddy = re.match('(.*)_p([0-9]+)[.]([0-9]+)', version)
			if baddy:
				revision = baddy.groups()[2]
				version = baddy.groups()[0] + '_p' + baddy.groups()[1]
				# src_path needs a small fixup too:
				src_path = src_path[:src_path.rfind('.')]
			else:
				revision = 0
			ebuild = hub.pkgtools.ebuild.BreezyBuild(
				**local_pkginfo,
				version=version,
				src_path=src_path,
				artifacts=artifacts,
				revision=revision
			)
			ebuild.push()


# vim: syn=python ts=4 sw=4 noet
