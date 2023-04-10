#!/usr/bin/env python3


async def generate(hub, **pkginfo):
    github_api = "https://api.github.com/repos"
    github_repo = github_user = pkginfo["name"]
    github_contrib = f"{github_repo}_contrib"

    pkgmetadata = await hub.pkgtools.fetch.get_page(
        f"{github_api}/{github_user}/{github_repo}",
        is_json=True
    )

    description = pkgmetadata["description"]

    newpkginfo = await hub.pkgtools.github.release_gen(hub, github_user, github_repo)
    contribpkg = await hub.pkgtools.github.tag_gen(hub, github_user, github_contrib)

    artifacts = [(None, newpkginfo["artifacts"][0])]
    if newpkginfo["version"] == contribpkg["version"]:
        artifacts.append(("contrib", contribpkg["artifacts"][0]))

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        github_user=github_user,
        github_repo=github_repo,
        description=description,
        version=newpkginfo["version"],
        artifacts=dict(artifacts)
    )
    ebuild.push()
