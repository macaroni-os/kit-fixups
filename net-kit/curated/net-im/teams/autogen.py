#!/usr/bin/env python3


async def generate(hub, **pkginfo):
	text_data = await hub.pkgtools.fetch.get_page(
		"https://packages.microsoft.com/repos/ms-teams/dists/stable/main/binary-amd64/Packages"
	)
	text_list = text_data.split("\n")
	version = None

	found = {}

	for text in text_list:
		line_els = text.split()
		for item in ["Version", "Source"]:
			l_item = item.lower()
			if l_item not in found:
				if not len(line_els):
					cointinue
				elif line_els[0] == item+":":
					found[l_item] = " ".join(line_els[1:])
		if len(found.keys()) == 2:
			break

	if len(found.keys()) != 2:
		raise hub.pkgotools.ebuild.BreezyError("Could not find element(s) in Packages file.")

	pkginfo.update(found)

	pkg_file = f"{pkginfo['source']}_{pkginfo['version']}_amd64.deb"
	url = f"https://packages.microsoft.com/repos/ms-teams/pool/main/t/{pkginfo['source']}/{pkg_file}"
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
	)
	ebuild.push()


# vim: ts=4 sw=4 noet
