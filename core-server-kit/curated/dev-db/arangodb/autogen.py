from metatools.version import generic

async def generate(hub, **pkginfo):
    github_repo = github_user = "arangodb"

    json_list = await hub.pkgtools.fetch.get_page(
        f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True
    )

    # filter out versions that are words (e.g. "devel") and prereleases
    releases = list(filter(
        lambda v: not v.is_prerelease,
        [generic.parse(rel['name'][1:]) for rel in json_list if rel['name'][1:][0].isnumeric()]
    ))
    supported_releases = set([v.minor for v in releases])
    handled_releases = []
    for m in supported_releases:
        # get the latest release in each minor release tree
        handled_releases.append(max([v for v in releases if v.minor == m]))

    artifacts = []
    for pv in handled_releases:
        url=f"https://github.com/{github_repo}/{github_user}/archive/v{pv}.tar.gz"
        fname=f"{github_repo}-v{pv}.tar.gz"
        keywords="next"
        if pv == min(handled_releases): keywords="*"

        # 3.10 series dynamically tries to fetch 3rd party modules via git
        # this sucks because some of those modules don't have tags, and the commit hash isn't specified
        # so we'll just skip the 3.10 series and revisit after 3.8.x gets deprecated
        if pv == max(handled_releases): keywords="-*"

        ebuild = hub.pkgtools.ebuild.BreezyBuild(
            **pkginfo,
            version=pv,
            github_user=github_user,
            github_repo=github_repo,
            keywords=keywords,
            artifacts=[hub.pkgtools.ebuild.Artifact(
                url=url,
                final_name=fname,
            )],
        )
        ebuild.push()

# vim:ts=4 sw=4
