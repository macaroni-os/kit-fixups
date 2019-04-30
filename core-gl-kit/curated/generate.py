#!/usr/bin/python3

from merge.extensions.xproto import XProtoStepGenerator

def add_steps(collector):
	collector.add_step(XProtoStepGenerator(template_text="""# Distributed under the terms of the GNU General Public License v2
EAPI=6

inherit multilib-minimal

DESCRIPTION="X.Org Protocol ${proto} package stub ."

KEYWORDS="*"

SLOT="0/stub"

RDEPEND="|| ({% for meta_atom in all_meta_atoms %}
	={{meta_atom}}
{%- endfor %}
)"
DEPEND="${RDEPEND}"

S="${WORKDIR}"

multilib_src_configure() { return 0; }
src_configure() { return 0; }
multilib_src_compile() { return 0; }
src_compile() { return 0; }
multilib_src_install() { return 0; }
src_install() { return 0; }
"""))

