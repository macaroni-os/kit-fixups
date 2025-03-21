# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="LLVMgold plugin symlink for autoloading"
HOMEPAGE="https://llvm.org/"
LICENSE="Apache-2.0-with-LLVM-exceptions UoI-NCSA BSD public-domain rc"
SLOT="16"
KEYWORDS="*"
RDEPEND="sys-devel/llvm:16[gold]
	
"
S="${WORKDIR}"
src_install() {
	dodir "/usr/${CHOST}/binutils-bin/lib/bfd-plugins"
	dosym "../../../../lib/llvm/16/$(get_libdir)/LLVMgold.so" \
	  "/usr/${CHOST}/binutils-bin/lib/bfd-plugins/LLVMgold.so"
}


# vim: filetype=ebuild
