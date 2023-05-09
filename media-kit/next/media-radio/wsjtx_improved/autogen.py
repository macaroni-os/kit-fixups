#!/usr/bin/env python3

from bs4 import BeautifulSoup
from packaging import version
import re, os, shutil

# fetch wsjtx and wsjtx_improved* as thay have virtually same requiments and have structure as same project

async def generate_classic_wsjt(hub, **pkginfo):
    """ generate "classic" wsjt """

    sourceforge_url = f"https://sourceforge.net/projects/wsjt/files"
    sourceforge_soup = BeautifulSoup(
            await hub.pkgtools.fetch.get_page(sourceforge_url), "lxml"
            )

    files_list = sourceforge_soup.find(id="files_list")
    files = (
            version_row.get("title") for version_row in files_list.tbody.find_all("tr")
            )
    files = filter(lambda x: x.startswith("wsjtx-"),files)
    versions = { version.parse(re.search(r"\d+\.\d+(\.\d+)?", file).group()): file for file in files }


    target_version = max(versions.keys())
    target_name = versions[target_version]

    src_url = f"https://downloads.sourceforge.net/wsjt/{target_name}/{target_name}.tgz"


    pkginfo["name"] = "wsjtx"
    pkginfo["template"] = "wsjtx.tmpl"

    ebuild = hub.pkgtools.ebuild.BreezyBuild(
            **pkginfo,
            version=target_version,
            artifacts=[hub.pkgtools.ebuild.Artifact(url=src_url)],
            )
    ebuild.push()


async def generate(hub, **pkginfo):
    await generate_classic_wsjt(hub,**pkginfo)

    project_name="wsjt-x-improved"


    sourceforge_url = f"https://sourceforge.net/projects/{project_name}/files"
    sourceforge_soup = BeautifulSoup(
            await hub.pkgtools.fetch.get_page(sourceforge_url), "lxml"
            )

    files_list = sourceforge_soup.find(id="files_list")
    files = (
            version_row.get("title") for version_row in files_list.tbody.find_all("tr")
            )
    files = filter(lambda x: x.startswith("WSJT-X_"), files)



    files = list(files)
    versions = { version.parse(re.search(r"\d+\.\d+(\.\d+)?", file).group()): file for file in files }



    target_version = max(versions.keys())
    target_dir = versions[target_version]

    # repeat with subprojects
    sourceforge_url = f"https://sourceforge.net/projects/{project_name}/files/{target_dir}/Source%20code/"


    sourceforge_soup = BeautifulSoup(
                await hub.pkgtools.fetch.get_page(sourceforge_url), "lxml"
    )

    files_list = sourceforge_soup.find(id="files_list")

    files = [i.span.text for i in files_list.tbody.find_all("tr",{'class' : 'file'})]

    files = filter(lambda x: x.endswith(".tgz"), files) # filter upto source

    for target_file in files:
       src_url = f"https://downloads.sourceforge.net/{project_name}/{target_dir}/Source%20code/{target_file}"


       suffix = target_file.split("_improved_");

       if len(suffix) > 1:
         suffix= "_"+ suffix[1].rstrip(".tgz").replace("+","_");
       else:
         suffix=""

       pkginfo["name"] = "wsjtx_improved" + suffix
       pkginfo["template"] = "wsjtx_improved.tmpl"

       #import pdb
       #pdb.set_trace()

       ebuild = hub.pkgtools.ebuild.BreezyBuild(
            **pkginfo,
            version=target_version,
            artifacts=[hub.pkgtools.ebuild.Artifact(url=src_url)],
            )

       # copy patch for only wsjtx executable installation
       if suffix != "":
           os.makedirs(ebuild.output_pkgdir+"/files",exist_ok=True)
           shutil.copy(os.path.dirname(__file__)+"/files/wsjtx_improved-2.6.2-install-only-wsjtx.patch",ebuild.output_pkgdir+"/files/wsjtx_improved-2.6.2-install-only-wsjtx.patch")

       ebuild.push()

