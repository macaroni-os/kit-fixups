#!/usr/bin/env python3

from packaging.version import Version

async def generate(hub, **pkginfo):
    github_user = "CGAL"
    github_repo = pkginfo["name"]

    artifacts = {}

    newpkginfo = await hub.pkgtools.github.release_gen(hub, github_user, github_repo)
    version = Version(newpkginfo["version"])
    artifacts[''] = newpkginfo["artifacts"][0]

    download_url = f"https://github.com/CGAL/cgal/releases/download/v{version}/"
    doc_tarball = f"CGAL-{version}-doc_html.tar.xz"

    artifacts["doc"] = hub.pkgtools.ebuild.Artifact(url=download_url+doc_tarball, final_name=doc_tarball)

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=version,
        github_user=github_user,
        github_repo=github_repo,
        artifacts=artifacts,
    )
    ebuild.push()
