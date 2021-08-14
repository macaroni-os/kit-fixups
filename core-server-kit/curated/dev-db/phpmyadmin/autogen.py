#!/usr/bin/env python3


async def generate(hub, **pkginfo):
    package_name = "phpMyAdmin"
    json_latest = await hub.pkgtools.fetch.get_page(
        f"https://www.phpmyadmin.net/home_page/version.json", is_json=True
    )
    if "version" not in json_latest:
        raise hub.pkgtools.ebuild.BreezyError(f"Can't find a suitable release of {package_name}")
    last_stable_version = json_latest["version"]
    final_name = f"{package_name}-{last_stable_version}-all-languages.tar.xz"
    url = f"https://files.phpmyadmin.net/{package_name}/{last_stable_version}/{final_name}"
    ebuild = hub.pkgtools.ebuild.BreezyBuild(
        **pkginfo,
        version=last_stable_version,
        artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
    )
    ebuild.push()
