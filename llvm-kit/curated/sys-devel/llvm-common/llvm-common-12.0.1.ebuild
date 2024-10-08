# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit llvm.org

DESCRIPTION="Common files shared between multiple slots of LLVM"
HOMEPAGE="https://llvm.org/"

LICENSE="Apache-2.0-with-LLVM-exceptions UoI-NCSA"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="!sys-devel/llvm:0"

LLVM_COMPONENTS=( llvm/utils/vim )
llvm.org_set_globals

src_install() {
	insinto /usr/share/vim/vimfiles
	doins -r */
	# some users may find it useful
	newdoc README README.vim
	dodoc vimrc
}
