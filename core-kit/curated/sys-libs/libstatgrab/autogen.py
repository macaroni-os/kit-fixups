#!/usr/bin/env python3

from packaging.version import Version

async def generate(hub, **pkginfo):
    github_api = "https://api.github.com/repos"
    github_repo = github_user = pkginfo["name"]
    github_page = f"{github_api}/{github_user}/{github_repo}"

    pkgmetadata = await hub.pkgtools.fetch.get_page(github_page, is_json=True)
    description = pkgmetadata["description"]

    json_list = await hub.pkgtools.fetch.get_page(f"{github_page}/releases", is_json=True)
    stable = max([Version(rel['name'][1:].split()[1]) for rel in json_list])

    tag = f"{github_repo.upper()}_{'_'.join(stable.public.split('.'))}"

    artifacts = [hub.pkgtools.ebuild.Artifact(
        url=f"https://github.com/{github_user}/{github_repo}/archive/refs/tags/{tag}.tar.gz",
        final_name=f"{github_repo}-{stable}.tar.gz",
    )]

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=stable,
        artifacts=artifacts,
        github_user=github_user,
        github_repo=tag,
    )
    ebuild.push()

# vim:ts=4 sw=4

