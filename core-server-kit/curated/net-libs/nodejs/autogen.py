#!/usr/bin/env python

from metatools.version import generic
from datetime import date


async def release_generator(hub, github_user, github_repo):
    page = 0
    while True:
        releases = await hub.pkgtools.fetch.get_page(
            f"https://api.github.com/repos/{github_user}/{github_repo}/releases?page={page}&per_page=100",
            is_json=True,
        )

        if not releases:
            break

        for release in releases:
            yield release

        page += 1


def generate_for_release(hub, release, **pkginfo):
    release_version = release["tag_name"].lstrip("v")
    tarball_url = release["tarball_url"]

    tarball_artifact = hub.pkgtools.ebuild.Artifact(
        url=tarball_url, final_name=f"{pkginfo['name']}-{release_version}.tar.gz"
    )

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=release_version,
        artifacts=[tarball_artifact],
        unmasked="unmasked" in release,
        # NOTE: First version to support Python 3+ was Node 6,
        #       use Python 2.7 for anything older.
        python_compat="python3+" if release["version"].major >= 6 else "python2_7",
    )

    ebuild.push()


async def generate(hub, **pkginfo):
    github_user = pkginfo["github_user"] = "nodejs"
    github_repo = pkginfo["github_repo"] = "node"

    latest_release_by_major = {}

    async for release in release_generator(hub, github_user, github_repo):
        release_version = release["version"] = generic.parse(release["tag_name"])

        release_major = str(release_version.major)
        latest_release = latest_release_by_major.get(release_major)

        if latest_release is None or latest_release["version"] < release_version:
            latest_release_by_major[release_major] = release

    release_schedule = await hub.pkgtools.fetch.get_page(
        f"https://raw.githubusercontent.com/{github_user}/Release/main/schedule.json",
        is_json=True,
    )

    today = date.today()
    for release_channel, schedule in release_schedule.items():
        major_version = release_channel.lstrip("v")
        release = latest_release_by_major.get(major_version)

        if release is None:
            continue

        if "lts" not in schedule:
            continue

        end_date = date.fromisoformat(schedule["end"])
        if today > end_date:
            continue

        release["unmasked"] = True

    for release in latest_release_by_major.values():
        generate_for_release(hub, release, **pkginfo)

