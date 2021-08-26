#!/usr/bin/env python3

from packaging import version
import subprocess

REPO_URL = "https://thekelleys.org.uk/git/dnsmasq.git"
DOWNLOAD_URL = "http://www.thekelleys.org.uk/dnsmasq/"


def get_latest_version(hub):

	result = subprocess.run(["git", "ls-remote", "--tags", REPO_URL], capture_output=True, encoding="UTF-8")

	if result.returncode > 0:
		cmd = " ".join(result.args)
		raise hub.pkgtools.ebuild.BreezyError(f"{cmd} failed: {result.stderr}")

	tags = []
	for ref in result.stdout.split("\n"):
		bits = ref.split("\t")  # <hash><tab>refs/tags/<tag>
		if len(bits) < 2:
			continue

		rtt = bits[1].split("/")  # refs/tags/<tag>
		if len(rtt) < 3:
			continue

		if rtt[2].startswith("v") and not rtt[2].endswith("^{}"):
			v = version.parse(rtt[2])
			if v.is_prerelease or isinstance(v, version.LegacyVersion):
				continue
			tags.append(v)

	return None if not tags else sorted(tags).pop()


async def generate(hub, **pkginfo):

	latest_version = get_latest_version(hub)

	if latest_version is None:
		raise hub.pkgtools.ebuild.BreezyError(f"Can't find a latest version of {pkginfo['cat']}/{pkginfo['name']}")

	url = f"{DOWNLOAD_URL}{pkginfo['name']}-{latest_version}.tar.xz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=latest_version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url)],
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
