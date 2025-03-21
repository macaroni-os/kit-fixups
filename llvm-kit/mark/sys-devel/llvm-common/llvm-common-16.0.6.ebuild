# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Common files shared between multiple slots of LLVM"
HOMEPAGE="https://llvm.org/"
SRC_URI="https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.6/llvm-project-16.0.6.src.tar.xz -> llvm-project-16.0.6.src.tar.xz"
LICENSE="Apache-2.0-with-LLVM-exceptions UoI-NCSA BSD public-domain rc"
SLOT="0"
KEYWORDS="*"
S="${WORKDIR}/llvm-src/llvm/utils/vim"
post_src_unpack() {
	mv llvm-project-* llvm-src
}
src_install() {
	insinto /usr/share/vim/vimfiles
	doins -r */
	# some users may find it useful
	newdoc README README.vim
	dodoc vimrc
}


# vim: filetype=ebuild
