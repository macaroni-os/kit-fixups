#!/usr/bin.env python3
from packaging import version


def get_release(releases_data):
    releases = list(
        filter(lambda x: x["name"].startswith("snapshot") is False, releases_data)
    )
    return (
        None
        if not releases
        else sorted(releases, key=lambda x: version.parse(x["name"])).pop()
    )

async def generate(hub, **pkginfo):
    user = "ibus"
    repo = "ibus-pinyin"
    releases_data = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{user}/{repo}/tags", is_json=True)
    latest_release = get_release(releases_data)

    if latest_release is None:
        raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {name}")
    version = latest_release["name"]

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version = version,
        github_repo = repo,
        artifacts = [hub.pkgtools.ebuild.Artifact(url=f"https://api.github.com/repos/{user}/{repo}/tarball/refs/tags/{version}", final_name=f"{repo}-{version}.tar.gz")]
    )
    ebuild.push()
