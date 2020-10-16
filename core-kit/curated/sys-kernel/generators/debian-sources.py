#!/usr/bin/python3

GLOBAL_DEFAULTS = {}


async def generate(hub, **pkginfo):
	base_url = f"http://http.debian.net/debian/pool/main/l/linux"
	deb_pv = f"{pkginfo['deb_pv_base']}-{pkginfo['deb_extraversion']}"
	k_artifact = hub.pkgtools.ebuild.Artifact(url=f"{base_url}/linux_{pkginfo['deb_pv_base']}.orig.tar.xz")
	p_artifact = hub.pkgtools.ebuild.Artifact(url=f"{base_url}/linux_{deb_pv}.debian.tar.xz")
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo, artifacts=[k_artifact, p_artifact])
	ebuild.push()


# vim: ts=4 sw=4 noet
