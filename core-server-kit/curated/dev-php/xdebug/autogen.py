#!/usr/bin/env python3

import re

async def generate(hub, **pkginfo):
  github_user = "xdebug" 
  github_repo = "xdebug" 
  page=1
  version=''

  while True :

    if version == '' :
      json_list = await hub.pkgtools.fetch.get_page(
        f"https://api.github.com/repos/{github_user}/{github_repo}/tags?page={page}", is_json=True
      )
      page=page+1
    else:
      break

    for record in json_list:
      print(record)

      if re.match(r"^(\d).(\d).(\d)$",record['name']) and version == '' :
        version = record['name']
        url= record['tarball_url']
        print(version,url)

        final_name = f'{pkginfo["name"]}-{version}.tar.gz'

        ebuild = hub.pkgtools.ebuild.BreezyBuild(
          **pkginfo,
          github_user=github_user,
          github_repo=github_repo,
          version=version,
          artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
        )

        ebuild.push()


