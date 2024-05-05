#!/usr/bin/env python3
import glob
import re
import os.path

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

    for version in await get_versions(pkginfo, tags_dict):
        package = f"{user}-{repo}-{version}"

        artifact = hub.pkgtools.ebuild.Artifact(
            url=f"https://gitlab.freedesktop.org/{user}/{repo}/-/archive/{repo}-{version}/{package}.tar.bz2")

        subslot = await get_subslot(artifact, package)

        ebuild = hub.pkgtools.ebuild.BreezyBuild(
            **pkginfo,
            version=version,
            gitlab_user=user,
            gitlab_repo=repo,
            subslot=subslot,
            artifacts=[artifact]
        )
        ebuild.push()

async def get_versions(pkginfo, tags_dict):
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

async def get_subslot(artifact, package):
    await artifact.fetch()
    artifact.extract()
    cmake_file = open(
        glob.glob(os.path.join(artifact.extract_path, package, "CMakeLists.txt"))[0]
    ).read()
    soversion = re.search("SOVERSION ([0-9]+)", cmake_file)
    if not soversion:
        soversion = re.search("SOVERSION_NUMBER \"([0-9]+)\"", cmake_file)
    subslot = soversion.group(1)
    artifact.cleanup()
    return subslot

# vim: ts=4 sw=4 noet
