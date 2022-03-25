#!/usr/bin/env python3

from packaging.version import Version

async def generate(hub, **pkginfo):
    gitlab_user = pkginfo.get('gitlab_user')
    gitlab_repo = pkginfo.get('gitlab_repo') or pkginfo.get('name')
    project_path = f"{gitlab_user}%2F{gitlab_repo}"

    tag_data = await hub.pkgtools.fetch.get_page(
        f"https://gitlab.com/api/v4/projects/{project_path}/repository/tags",
        is_json=True,
    )

    tags = [Version(tag["name"].lstrip("v")) for tag in tag_data]
    tags = [tag for tag in tags if tag.major < pkginfo.get("version_limit")]

    latest_version = max(tags)

    source_name = f"{gitlab_repo}-{latest_version}.tar.xz"

    source_url = f"https://downloads.sourceforge.net/project/{gitlab_user}/Production/{gitlab_user}-{latest_version}.tar.xz"

    source_artifact = hub.pkgtools.ebuild.Artifact(url=source_url)

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=latest_version,
        artifacts=[source_artifact],
    )
    ebuild.push()

