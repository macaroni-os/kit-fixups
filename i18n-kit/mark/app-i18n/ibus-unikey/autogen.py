#!/usr/bin.env python3
from metatools.version import generic


def get_release(releases_data):
    # Here we make an exception for this given release because it was wrongly set as a pre-release
    releases = list(
        filter(lambda x: (x["prerelease"] is False and x["draft"] is False) or x["tag_name"] == "0.7.0-beta1", releases_data)
    )
    return (
        None
        if not releases
        else sorted(releases, key=lambda x: generic.parse(x["tag_name"])).pop()
    )

async def generate(hub, **pkginfo):
    user = "vn-input"
    repo = "ibus-unikey"
    releases_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{user}/{repo}/releases", is_json=True)
    latest_release = get_release(releases_data)

    if latest_release is None:
        raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {repo}")
    tag_name = latest_release["tag_name"]
    version = latest_release["tag_name"].replace("-", "_")

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version = version,
        artifacts = [hub.pkgtools.ebuild.Artifact(url=f"https://github.com/{user}/{repo}/archive/refs/tags/{tag_name}.tar.gz", final_name=f"{repo}-{version}.tar.gz")]
    )
    ebuild.push()
