#!/usr/bin/env python3

from bs4 import BeautifulSoup
from metatools.version import generic
import re

async def generate(hub, **pkginfo):
    name = pkginfo.get('name')

    download_url = "https://ftp.postgresql.org/pub/source"

    # find all the supported major versions, aka slots
    supported_versions = await find_supported_versions(hub)

    for version in supported_versions:
        pkginfo_local = pkginfo.copy()
        pkginfo_local['slot'] = slot = version.major
        keywords="*"
        if slot in pkginfo['slots']:
            pkginfo_local.update(pkginfo['slots'][slot])

        artifact_url = f"{download_url}/v{version}/{name}-{version}.tar.bz2"
        artifacts = [hub.pkgtools.ebuild.Artifact(url=artifact_url)]

        ebuild = hub.pkgtools.ebuild.BreezyBuild(
            **pkginfo_local,
            artifacts=artifacts,
            version=version,
            keywords=keywords
        )
        ebuild.push()


async def find_supported_versions(hub):
    info_url = "https://www.postgresql.org/support/versioning/"

    html = await hub.pkgtools.fetch.get_page(info_url)
    table = BeautifulSoup(html, features='html.parser').findAll("tr")

    # Convert the table's header rows into keys for a dict
    keys = row_data(table.pop(0), "th")

    # Convert each row of the table into a dict, using the above keys
    data = [dict(list(zip(keys, row_data(line, "td")))) for line in table]

    return [generic.parse(item['Current minor']) for item in data if item['Supported'] == 'Yes']


def row_data(row, data_element):
    return [td.text.replace('Version', 'Slot') for td in row.findAll(data_element)]
