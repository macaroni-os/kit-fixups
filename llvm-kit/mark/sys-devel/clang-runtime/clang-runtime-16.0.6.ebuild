# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Meta-ebuild for clang runtime libraries"
HOMEPAGE="https://llvm.org/"
LICENSE="metapackage"
SLOT="16"
KEYWORDS="*"
IUSE="+compiler-rt libcxx openmp +sanitize"
REQUIRED_USE="sanitize? ( compiler-rt )
"
RDEPEND="compiler-rt? (
	  ~sys-libs/compiler-rt-16.0.6:${SLOT}
	  sanitize? ( ~sys-libs/compiler-rt-sanitizers-16.0.6:${SLOT} )
	)
	libcxx? ( >=sys-libs/libcxx-16.0.6 )
	openmp? ( >=sys-libs/libomp-16.0.6 )
	
"

# vim: filetype=ebuild
