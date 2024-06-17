# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit meson

EGIT_REPO_URI="https://anongit.freedesktop.org/git/pixman.git"
DESCRIPTION="Low-level pixel manipulation routines"
SLOT="0"
KEYWORDS="*"
IUSE="cpu_flags_x86_mmxext cpu_flags_x86_sse2 cpu_flags_x86_ssse3 cpu_flags_ppc_altivec cpu_flags_arm_neon cpu_flags_arm_iwmmxt loongson2f"
SRC_URI="https://www.x.org/releases/individual/lib/pixman-0.43.4.tar.xz"


src_configure() {
	local emesonargs=(
    		$(meson_feature cpu_flags_x86_mmxext mmx)
    		$(meson_feature cpu_flags_x86_sse2 sse2)
    		$(meson_feature cpu_flags_x86_ssse3 ssse3)
    		$(meson_feature cpu_flags_ppc_altivec vmx)
    		$(meson_feature cpu_flags_arm_neon neon)
    		$(meson_feature cpu_flags_arm_iwmmxt iwmmxt)
    		$(meson_feature loongson2f loongson-mmi)
    		-Ddemos=disabled
    		-Dgtk=disabled
    		-Dlibpng=disabled
    	)
	meson_src_configure
}

