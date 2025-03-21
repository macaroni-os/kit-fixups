# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+)
inherit cmake python-any-r1

DESCRIPTION="The LLVM linker (link editor)"
HOMEPAGE="https://llvm.org/"
SRC_URI="https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.6/llvm-project-16.0.6.src.tar.xz -> llvm-project-16.0.6.src.tar.xz"
LICENSE="Apache-2.0-with-LLVM-exceptions UoI-NCSA"
SLOT="16"
KEYWORDS="*"
IUSE="debug"
DEPEND="${RDEPEND}
"
RDEPEND="~sys-devel/llvm-16.0.6
	sys-libs/zlib:=
	
"
S="${WORKDIR}/llvm-src/lld"
post_src_unpack() {
	mv llvm-project-* llvm-src
}
src_configure() {
	use debug || local -x CPPFLAGS="${CPPFLAGS} -DNDEBUG"
	use elibc_musl && append-ldflags -Wl,-z,stack-size=2097152
	local mycmakeargs=(
	  -DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr/lib/llvm/${SLOT}"
	  -DBUILD_SHARED_LIBS=ON
	  -DLLVM_INCLUDE_TESTS=OFF
	)
	cmake_src_configure
}


# vim: filetype=ebuild
