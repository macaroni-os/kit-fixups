#!/usr/bin/env python3

async def generate(hub, **pkginfo):
  gitlab_user = "bacula-org"
  gitlab_repo = "bacula"
  gitlab_project_id=3
  
  json_list = await hub.pkgtools.fetch.get_page(
    f"https://gitlab.bacula.org/api/v4/projects/{gitlab_project_id}/repository/tags", is_json=True
  )

  latest = json_list[0]
  version = latest["name"].split("-")[1]
  
  url = f"https://gitlab.bacula.org/bacula-community-edition/bacula-community/-/archive/Release-{version}/bacula-community-Release-{version}.tar.bz2"
  final_name = f'{gitlab_repo}-{version}.tar.bz2'
  
  ebuild = hub.pkgtools.ebuild.BreezyBuild(
		**pkginfo,
		version=version,
		artifacts=[hub.pkgtools.ebuild.Artifact(
      url=url, 
      final_name=final_name
    )],
	)
	
  ebuild.push()