#!/usr/bin.env python3
from packaging import version


def get_release(releases_data):
    releases = list(
        filter(lambda x: x["prerelease"] is False and x["draft"] is False, releases_data)
    )
    return (
        None
        if not releases
        else sorted(releases, key=lambda x: version.parse(x["tag_name"])).pop()
    )

async def generate(hub, **pkginfo):
    user = "microcai"
    repo = "ibus-handwrite"
    releases_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{user}/{repo}/releases", is_json=True)
    latest_release = get_release(releases_data)

    if latest_release is None:
        raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {name}")

    # The repository unfortunately doesn't follow best practices in versioning and the latest tag is 3.0, which is ok but the
    # actual artifact is named with ibus-handwrite-3.0.0 so to fix this if the
    version = latest_release["tag_name"]
    fversion = version
    count = version.count(".")
    if count <= 1:
        for i in range(count):
            fversion += ".0"

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version = fversion,
        artifacts = [hub.pkgtools.ebuild.Artifact(url=f"https://github.com/{user}/{repo}/releases/download/{version}/{repo}-{fversion}.tar.bz2", final_name="{repo}-{version}.tar.bz2")]
    )
    ebuild.push()
