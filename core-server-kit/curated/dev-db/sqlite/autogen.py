#!/usr/bin/python3

from packaging.version import Version as Version
from bs4 import BeautifulSoup, Comment
from csv import DictReader
from io import StringIO

async def generate(hub, **pkginfo):
    homepage_url = "https://sqlite.org/"
    html = await hub.pkgtools.fetch.get_page(homepage_url + 'download.html')
    soup = BeautifulSoup(html, features="html.parser")

    # The latest release info is embedded in the webpage's html as an html comment.
    # So we search for all the comments and select the onw that has the word "Download" in it
    comment = [c.strip() for c in soup.findAll(text=lambda text:isinstance(text, Comment)) if "Download" in c][0]

    # Convert the comment into a file-like object
    data = StringIO(comment)
    # Skip the first line in the comment as it is an explainer
    next(data)
    asset_types = ['src', 'doc']

    # The rest of the comment is csv formatted string, so we find the urls' for the -src and -doc tar.gzs
    assets = [row for row in DictReader(data) if any([asset in row['RELATIVE-URL'] for asset in asset_types])]

    # Store the artifacts as a dict like: {'src': src-tarball-url, 'doc': doc-tarball-url)
    artifacts = dict((asset['RELATIVE-URL'].split('-')[1], hub.pkgtools.ebuild.Artifact(url=homepage_url + asset['RELATIVE-URL'])) for asset in assets)

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        artifacts=artifacts,
        version=assets[0]['VERSION'],
        full_version=assets[0]['RELATIVE-URL'].split('-')[2].split('.')[0]
    )
    ebuild.push()

