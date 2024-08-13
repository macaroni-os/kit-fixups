
from bs4 import BeautifulSoup
import re

async def generate(hub, **pkginfo):
	download_url = "https://zlib.net"
	html = await hub.pkgtools.fetch.get_page(download_url)
	soup = BeautifulSoup(html, "html.parser").find_all("a")

	for link in soup:
		href = link['href']
		match = re.match('zlib-([0-9.]+).tar.xz$', href)
		if match:
			pkginfo['version'] = match.groups()[0]
			print(pkginfo['version'])
			tarball_url = download_url + '/' + href
			break

	pkginfo['artifacts'] = [hub.Artifact(url=tarball_url)]
	ebuild = hub.pkgtools.ebuild.BreezyBuild(**pkginfo)
	ebuild.push()


# vim: ts=4 sw=4 noet
