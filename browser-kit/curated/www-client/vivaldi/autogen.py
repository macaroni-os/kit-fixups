#!/usr/bin/env python3

import asyncio
import json
import re
from lxml import html


arches = {
	"amd64": {"json_key": "deb64", "arch": "amd64"},
	"armhf": {"json_key": "arm32", "arch": "arm"},
	"arm64": {"json_key": "arm64", "arch": "arm64"},
}

base_download_url = "https://downloads.vivaldi.com"

def parse_versions(versions_script):
	# Extract and clean up JSON part
	json_part = versions_script.split("=", 1)[-1].strip()
	if json_part.endswith(";"):
		json_part = json_part[:-1]
	return json.loads(json_part)


async def generate_stable(hub, **pkginfo):
	download_url = f"{base_download_url}/stable"
	versions_script_url = "https://vivaldi.com/wp-content/vivaldi-versions.js"

	versions_script = await hub.pkgtools.fetch.get_page(versions_script_url)

	versions = parse_versions(versions_script)
	version = versions["vivaldi_version_number"]

	artifacts = {}
	for arch_data in arches.values():
		arch = arch_data["arch"]
		json_key = arch_data["json_key"]

		version_key = f"vivaldi_version_{json_key}"
		target_filename = versions[version_key]

		artifact = hub.pkgtools.ebuild.Artifact(url=f"{download_url}/{target_filename}")
		artifacts[arch] = artifact

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=artifacts,
	)
	ebuild.push()


async def generate_snapshot(hub, **pkginfo):
	download_url = f"{base_download_url}/snapshot"
	snapshot_blog_url = "https://vivaldi.com/blog/desktop/snapshots"
	latest_blog_xpath = "//div[contains(@class, 'download-vivaldi-sidebar')]/a[contains(text(), 'Snapshot')]"

	deb_url_regex = re.compile(
		f"({download_url}/vivaldi-snapshot_([\d.]+)-(?:\d)_(.*).deb)"
	)

	snapshot_blog = await hub.pkgtools.fetch.get_page(snapshot_blog_url)
	snapshot_blog_tree = html.fromstring(snapshot_blog)

	latest_blog_post_link = snapshot_blog_tree.xpath(latest_blog_xpath)[0].get("href")

	latest_blog_post = await hub.pkgtools.fetch.get_page(latest_blog_post_link)
	latest_blog_post_tree = html.fromstring(latest_blog_post)

	download_links = [
		str(tag.get("href")) for tag in latest_blog_post_tree.xpath("//a")
	]

	link_matches = [deb_url_regex.match(url) for url in download_links]
	link_matches = [link_match.groups() for link_match in link_matches if link_match]

	artifacts = {}

	for url, version, arch_key in link_matches:
		arch_data = arches[arch_key]
		arch = arch_data["arch"]

		artifacts[arch] = hub.pkgtools.ebuild.Artifact(url=url)
		latest_version = version

	snapshot_pkginfo = {
		**pkginfo,
		"name": "vivaldi-snapshot",
		"snapshot": True,
	}

	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**snapshot_pkginfo,
		version=version,
		artifacts=artifacts,
		template="vivaldi.tmpl",
	)
	ebuild.push()


async def generate(hub, **pkginfo):
	await asyncio.gather(
		generate_stable(hub, **pkginfo),
		generate_snapshot(hub, **pkginfo),
	)


# vim: ts=4 sw=4 noet

