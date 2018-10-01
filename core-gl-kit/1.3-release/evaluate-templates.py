#!/usr/bin/python3

import os
from template import EbuildTemplate, TemplateParameterGenerator
from merge.merge_utils import getcommandoutput, runShell
import asyncio
from glob import glob
import multiprocessing
from concurrent.futures import ThreadPoolExecutor

class XProtoTemplate(EbuildTemplate):
	
	template_text = """# Distributed under the terms of the GNU General Public License v2
EAPI=6

inherit multilib-minimal

DESCRIPTION="X.Org Protocol ${proto} package stub (provided by {% master_cpv %})."

KEYWORDS="*"

SLOT="0"

RDEPEND=" || (
	={%master_cpv%}
)"
DEPEND="${RDEPEND}"

S="${WORKDIR}"

multilib_src_configure() { return 0; }
src_configure() { return 0; }
multilib_src_compile() { return 0; }
src_compile() { return 0; }
multilib_src_install() { return 0; }
src_install() { return 0; }
"""

class EbuildGenerator:
	
	class XProtoTemplateParameterGenerator(TemplateParameterGenerator):
		
		loop = asyncio.get_event_loop()
		
		async def generate(self, executor):
			futures = []
			for master_ebuild in glob(self.fixup_subpath + "/x11-base/xorg-proto/xorg-proto-*.ebuild"):
				for future in self.loop.run_in_executor(executor, self._generate, master_ebuild):
					futures.append(future)
			for result in asyncio.as_completed(futures):
				yield result
				
		def _generate(self, master_ebuild):
			master_cpv = "/".join(master_ebuild.rstrip(".ebuild").split("/")[-2:])
			runShell("(cd %s; ebuild %s clean unpack)" % ( os.path.dirname(master_ebuild), os.path.basename(master_ebuild)), abort_on_failure=True)
			meson_file = os.path.expanduser("~portage/%s/work/meson.ebuild" % master_cpv)
			status, thangs = getcommandoutput("cat meson.build | sed -n /^pcs = \[/,/^\]/ { s/',[[:space:]]*'/-/ ; s/'],//; s/.*\['// p};")
			status2, thangs2 = getcommandoutput("sed -n /^[[:space:]]*legacy_pcs = \[/,/^[[:space:]]*\]/ { s/',[[:space:]]*'/-/ ; s/'],//; s/.*\['// p};")
			out = []
			for foo in thangs.decode("utf-8").split():
				out.append({
					"master_cpv" : master_cpv,
				})
			runShell("(cd %s; ebuild %s clean)" % (os.path.dirname(master_ebuild), os.path.basename(master_ebuild)), abort_on_failure=True)
			return out
	
	
if __name__ == "__main__":
	
	master_executor = ThreadPoolExecutor(max_workers=multiprocessing.cpu_count())
	# TODO: do stuff here, use master_executor for everything...