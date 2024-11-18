#!/usr/bin/python3

from metatools.version import generic
from bs4 import BeautifulSoup, Comment
from csv import DictReader
from io import StringIO
from collections import defaultdict

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
    csv_data = DictReader(data)

    # More than one version can be listed, which makes this a bit complex. Make a dict of release versions, with
    # sub-dict of asset type, containing a URL as a value:

    releases = {}
    for row in csv_data:
        rel_url = row['RELATIVE-URL']
        if rel_url.startswith("snapshot"):
            continue
        version = generic.parse(row['VERSION'])
        asset_type = rel_url.split('-')[1]
        if version not in releases:
            releases[version] = {}
        releases[version][asset_type] = homepage_url + rel_url

    # Get the latest release version:

    latest = sorted(releases.keys())[-1]
    artifacts = {
        "global" : hub.Artifact(url=releases[latest]['src']),
        "doc" : hub.Artifact(url=releases[latest]['doc'])
    }
    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        artifacts=artifacts,
        version=latest,
        full_version=releases[latest]['src'].split('/')[-1].split('-')[2].split('.')[0]
        )
    ebuild.push()

