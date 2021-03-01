#!/usr/bin/env python3

from bs4 import BeautifulSoup

async def generate(hub, **pkginfo):
	html = await hub.pkgtools.fetch.get_page("https://slack.com/downloads/linux")
	url = "https://downloads.slack-edge.com/linux_releases/slack-desktop-{version}-amd64.deb"
	soup = BeautifulSoup(html, 'html.parser')
	link = soup.select_one(".page-downloads__hero__meta-text__version")
	try:
		version = None
		if link is not None:
			try:
				link_text = link.get_text()
				version = link_text.split()[-1]
			except AttributeError:
				pass
		if version is None:
			print("Using alternative HTML.")
			div = soup.select_one(".download-meta")
			div_text = div.get_text()
			div_ts = div_text.split()
			if not len(div_ts) or div_ts[0] != "Version":
				raise AttributeError()
			version = div_text.split()[1]
	except AttributeError:
		# This is how I debugged the bogus HTML:
		#with open("foo", "w") as myf:
		#	myf.write(html)
		raise hub.pkgtools.ebuild.BreezyError(f"Found unexpected something in slack-bin html.")
	url = url.format(version=version)
	ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo, version=version, artifacts=[hub.pkgtools.ebuild.Artifact(url=url)]
	)

	ebuild.push()


# vim: ts=4 sw=4 noet
