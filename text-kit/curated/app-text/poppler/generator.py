#!/usr/bin/env python3
from packaging.version import Version


async def generate(hub, **pkginfo):
    user = pkginfo["name"]
    repo = pkginfo["name"]
    server = "https://gitlab.com"

    if "gitlab_user" in pkginfo:
        user = pkginfo["gitlab_user"]
    elif "gitlab" in pkginfo and "user" in pkginfo["gitlab"]:
        user = pkginfo["gitlab"]["user"]

    if "gitlab_repo" in pkginfo:
        repo = pkginfo["gitlab_repo"]
    elif "gitlab" in pkginfo and "repo" in pkginfo["gitlab"]:
        repo = pkginfo["gitlab"]["repo"]

    if "gitlab_server" in pkginfo:
        server = pkginfo["gitlab_server"]
    elif "gitlab" in pkginfo and "server" in pkginfo["gitlab"]:
        server = pkginfo["gitlab"]["server"]

    query = pkginfo["gitlab"]["query"]
    if query not in ["releases", "tags", "snapshot"]:
        raise KeyError(
            f"{pkginfo['cat']}/{pkginfo['name']} should specify GitLab query type of 'releases', 'tags' or 'snapshot'."
        )
    if query == "tags":
        project_path = f"{user}%2F{repo}"
        info_url = f"https://{server}/api/v4/projects/{project_path}/repository/tags"
    elif query == "releases":
        if "project_id" not in pkginfo["gitlab"]:
            raise KeyError("To query releases, we require a project ID defined in gitlab/project_id")
        project_id = pkginfo["gitlab"]["project_id"]
        info_url = f"https://{server}/api/v4/projects/{project_id}/releases"

    tags_dict = await hub.pkgtools.fetch.get_page(
        info_url, is_json=True
    )

    for version in get_versions(pkginfo, tags_dict):
        ebuild = hub.pkgtools.ebuild.BreezyBuild(
            **pkginfo,
            version=Version(version),
            artifacts=[hub.pkgtools.ebuild.Artifact(
                url=f"https://gitlab.freedesktop.org/{user}/{repo}/-/archive/{repo}-{version}/{user}-{repo}-{version}.tar.bz2")],
        )
        ebuild.push()

def get_versions(pkginfo, tags_dict):
    if "gitlab_versions" in pkginfo:
        package_versions = pkginfo["gitlab_versions"]
        versions = [package_version for package_version in package_versions]
    elif "gitlab" in pkginfo and "versions" in pkginfo["gitlab"]:
        package_versions = pkginfo["gitlab"]["versions"]
        versions = [package_version for package_version in package_versions]
    elif "gitlab_version" in pkginfo:
        versions = [pkginfo["gitlab_version"]]
    elif "gitlab" in pkginfo and "version" in pkginfo["gitlab"]:
        versions = [pkginfo["gitlab"]["version"]]
    else:
        versions = [tag["name"].split('-')[1] for tag in tags_dict]
    return versions

# vim: ts=4 sw=4 noet
