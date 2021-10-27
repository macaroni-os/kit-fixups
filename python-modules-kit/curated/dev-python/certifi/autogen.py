#!/usr/bin/env python3

async def generate(hub, **pkginfo):
	gu = "mgorny"
	gr = "certifi-shim"
	tags = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{gu}/{gr}/tags", is_json=True)
	version = tags[0]["name"].lstrip("v")
	url = tags[0]["tarball_url"]
	commit = tags[0]["commit"]["sha"]
	final_name = f"certifi-shim-{version}-{commit[:7]}.tar.gz"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		gu=gu,
		gr=gr,
		commit=commit,
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
