#!/usr/bin/env python3

async def generate(hub, **pkginfo):
	package_lines = await hub.pkgtools.fetch.get_page("https://packages.element.io/debian/dists/default/main/binary-amd64/Packages")

	# This file lists lots of releases of signal stuff. Each section is separated by a single empty newline.
	# First, separate these sections. Each section has key/value pairs for a single release artifact:

	package_sections = package_lines.split("\n\n")
	for package_section in package_sections:
		package_lines = package_section.split("\n")
		pkg_dict = {}
		for pl in package_lines:
			colon_pos = pl.find(':')
			key = pl[:colon_pos].lower()
			val = pl[colon_pos+1:].strip()
			pkg_dict[key] = val
		# Ignore things we are not interested in:
		if pkg_dict["package"] != "element-desktop":
			continue
		if pkg_dict["architecture"] != "amd64":
			continue
		url = f"https://packages.element.io/debian/{pkg_dict['filename']}"
		a = hub.Artifact(url=url)
		try:
			# Make sure the artifact is actually uploaded:
			await a.ensure_fetched()
			# OK - we fetched it! It meets all our criteria!
		except hub.pkgtools.fetch.FetchError:
			continue
		pkginfo.update(pkg_dict)
		pkginfo["artifacts"] = [a]
		break
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo)
	ebuild.push()


# vim: ts=4 sw=4 noet
