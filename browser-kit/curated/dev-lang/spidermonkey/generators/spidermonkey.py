#!/usr/bin/env python3

import re

async def generate(hub, **pkginfo):

    artifacts = []

    artifacts.append(
        hub.pkgtools.ebuild.Artifact(
            url = f"{pkginfo['dir']['url']}"
        )
    )

    if 'additional_artifacts' in pkginfo:
        for url in pkginfo['additional_artifacts']:
            artifacts.append(
                hub.pkgtools.ebuild.Artifact(url)
            )

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        artifacts=artifacts
    )
    ebuild.push()


# vim: sw=4 ts=4 noet
