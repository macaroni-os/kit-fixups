import re, logging

async def generate(hub, **pkginfo):
    github_user = "OpenVPN"
    github_repo = "openvpn"

    json_list = await hub.pkgtools.fetch.get_page(
        f"https://api.github.com/repos/{github_user}/{github_repo}/tags", is_json=True
    )

    for slot in "2.4" , "2.5" :

        for resp in json_list:
            v_find = re.findall(f"{slot}[.]\\d+", resp['name'][1:] )
            if len(v_find):
                version = v_find[0]
                
                tag_meta = await hub.pkgtools.fetch.get_page(f"https://api.github.com/repos/{github_user}/{github_repo}/git/ref/tags/v{version}", is_json=True)
                tag_info = await hub.pkgtools.fetch.get_page(tag_meta['object']['url'], is_json=True)
                commit_sha1 = tag_meta['object']['sha']

                url = f"https://github.com/{github_user}/{github_repo}/archive/{commit_sha1}.tar.gz" 
                final_name = f'{pkginfo["name"]}-{version}-{commit_sha1[:7]}.tar.gz'

                ebuild = hub.pkgtools.ebuild.BreezyBuild(
                    **pkginfo,
                    github_user=github_user,
                    github_repo=github_repo,
                    version=version,
                    commit_sha1=commit_sha1,
                    artifacts=[hub.pkgtools.ebuild.Artifact(url=url , final_name=final_name)],
                )

                ebuild.push()
                break
            else:
                continue
