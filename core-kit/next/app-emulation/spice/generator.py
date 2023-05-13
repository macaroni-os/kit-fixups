#!/usr/bin/env python3


async def generate(hub, **pkginfo):
    user = pkginfo['gitlab']['user']
    repo = pkginfo["name"]
    releases_url = f"{pkginfo['gitlab']['url']}/api/v4/projects/{pkginfo['gitlab']['project_id']}/releases"
    releases = await hub.pkgtools.fetch.get_page(releases_url, is_json=True)
    prefix = pkginfo['gitlab']['prefix']
    if "version" not in pkginfo or pkginfo["version"] == "latest":
        for release in releases:
            if not release['tag_name'].startswith(prefix):
                continue
            if release["upcoming_release"]:
                continue
            pkginfo["version"] = release['tag_name'][len(prefix):]
            selected_release = release
            break
    else:
        for release in releases:
            if not release['tag_name'].startswith(prefix):
                continue
            version = release['tag_name'][len(prefix):]
            if version == pkginfo["version"]:
                selected_release = release
                break

    source_url = None
    for source in release['assets']['sources']:
        if source['format'] == "tar.gz":
            source_url = source['url']

    artifact = hub.pkgtools.ebuild.Artifact(url=source_url)
    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        gitlab_user=user,
        gitlab_repo=repo,
        artifacts=[artifact],
    )
    ebuild.push()
