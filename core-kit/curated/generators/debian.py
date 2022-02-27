#!/usr/bin/python3

import packaging.version
from bs4 import BeautifulSoup

async def get_debian_version_and_patch(hub, **pkginfo):
    pkgname = pkginfo.get("name")
    compression = pkginfo.get("compression")
    repo = pkginfo.get("repo")
    pool = f"{repo}/{pkgname[0]}/{pkgname}/"

    def get_patch_version(a):
        href = pool + a['href']
        file = href.split('/')[-1]
        if file.startswith(pkgname) and file.endswith(compression) and not file.endswith('orig.tar.gz'):
            return (packaging.version.Version(file.split('_')[1].split(".debian")[0]), href)


    html = await hub.pkgtools.fetch.get_page(pool, is_json=False)
    soup = BeautifulSoup(html, features="html.parser").find_all('a', href=True)

    # parse the version number from the html using the internal get_version() function above
    # then filter out all the None values, and convert the filtered object into a list
    tarballs = list(filter(None.__ne__, [get_patch_version(a) for a in soup]))

    return max(tarballs)


async def generate(hub, **pkginfo):
    debian, url = await get_debian_version_and_patch(hub, **pkginfo)

    print(debian)

    debian_artifact = hub.pkgtools.ebuild.Artifact(url=url)
    sourceforge_artifact = hub.pkgtools.ebuild.Artifact(url=f"https://download.sourceforge.net/infozip/{pkginfo.get('name')}{debian.major}{debian.minor}.tar.gz")

    print(debian_artifact, sourceforge_artifact)

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=f"{debian.base_version}_p{debian.post}",
        artifacts=[debian_artifact, sourceforge_artifact]
    )
    print(ebuild)
    ebuild.push()
