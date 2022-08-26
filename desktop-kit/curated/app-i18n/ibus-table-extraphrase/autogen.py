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
    user = "Madman10K"
    repo = "ibus-table-extraphrase"
    releases_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{user}/{repo}/releases", is_json=True)
    latest_release = get_release(releases_data)

    if latest_release is None:
        raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {name}")
    version = latest_release["tag_name"]
    fversion = version[1:]
    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version = fversion,
        artifacts = [hub.pkgtools.ebuild.Artifact(url=f"https://github.com/{user}/{repo}/archive/refs/tags/{version}.tar.gz", final_name=f"{repo}-{fversion}.tar.gz")]
    )
    ebuild.push()
