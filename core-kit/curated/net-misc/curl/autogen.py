#!/usr/bin/env python3

async def generate(hub, **pkginfo):
  github_user = "curl"
  github_repo = "curl"
  json_list = await hub.pkgtools.fetch.get_page(
    f"https://api.github.com/repos/{github_user}/{github_repo}/releases", is_json=True
  )
  
  latest = json_list[0]
  
  version = latest["name"]
  version_tag = version.replace(".","_")

  json_ref = await hub.pkgtools.fetch.get_page(
      f"https://api.github.com/repos/{github_user}/{github_repo}/git/ref/tags/{github_repo}-{version_tag}", is_json=True
  )

  commit_sha1 = json_ref['object']['sha'][:7]

  url = latest["tarball_url"]

  final_name = f'{pkginfo["name"]}-{version}.tar.gz'

  ebuild = hub.pkgtools.ebuild.BreezyBuild(
    **pkginfo,
    github_user=github_user,
    github_repo=github_repo,
    version=version,
    commit_sha1=commit_sha1,
    artifacts=[hub.pkgtools.ebuild.Artifact(url=url, final_name=final_name)],
  )

  ebuild.push()
