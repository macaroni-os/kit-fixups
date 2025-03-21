# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+)
CMAKE_BUILD_TYPE=RelWithDebInfo
inherit cmake python-single-r1

DESCRIPTION="The LLVM debugger"
HOMEPAGE="https://llvm.org/"
SRC_URI="https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.6/llvm-project-16.0.6.src.tar.xz -> llvm-project-16.0.6.src.tar.xz"
LICENSE="Apache-2.0-with-LLVM-exceptions UoI-NCSA"
SLOT="16"
KEYWORDS="*"
IUSE="debug +libedit lzma ncurses +python +xml"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
DEPEND="${RDEPEND}
	
"
BDEPEND="dev-util/cmake
	python? ( dev-lang/swig )
	${PYTHON_DEPS}
	
"
RDEPEND="libedit? ( dev-libs/libedit:0= )
	lzma? ( app-arch/xz-utils:= )
	ncurses? ( sys-libs/ncurses )
	python? (
	  $(python_gen_cond_dep '
	    dev-python/six[${PYTHON_USEDEP}]
	  ')
	  ${PYTHON_DEPS}
	)
	xml? ( dev-libs/libxml2:= )
	sys-devel/clang:16
	sys-devel/llvm:16
	
"
S="${WORKDIR}/llvm-src/lldb"
post_src_unpack() {
	mv llvm-project-* llvm-src
}
pkg_setup() {
	python-single-r1_pkg_setup
}
src_configure() {
	# LLVM_ENABLE_ASSERTIONS=NO does not guarantee this for us, #614844
	use debug || local -x CPPFLAGS="${CPPFLAGS} -DNDEBUG"
	 local mycmakeargs=(
	  -DLLDB_ENABLE_CURSES=$(usex ncurses)
	  -DLLDB_ENABLE_LIBEDIT=$(usex libedit)
	  -DLLDB_ENABLE_PYTHON=$(usex python)
	  -DLLDB_ENABLE_LZMA=$(usex lzma)
	  -DLLDB_ENABLE_LIBXML2=$(usex xml)
	  -DLLDB_USE_SYSTEM_SIX=1
	  -DLLVM_ENABLE_TERMINFO=$(usex ncurses)
	  -DLLDB_INCLUDE_TESTS=OFF
	  -DCLANG_LINK_CLANG_DYLIB=ON
	  # TODO: fix upstream to detect this properly
	  -DHAVE_LIBDL=ON
	  -DHAVE_LIBPTHREAD=ON
	  # normally we'd have to set LLVM_ENABLE_TERMINFO, HAVE_TERMINFO
	  # and TERMINFO_LIBS... so just force FindCurses.cmake to use
	  # ncurses with complete library set (including autodetection
	  # of -ltinfo)
	  -DCURSES_NEED_NCURSES=ON
	  -DLLDB_EXTERNAL_CLANG_RESOURCE_DIR="${BROOT}/usr/lib/clang/16"
	  -DPython3_EXECUTABLE="${PYTHON}"
	)
	cmake_src_configure
}
src_install() {
	cmake_src_install
	find "${D}" -name '*.a' -delete || die
	use python && python_optimize
}


# vim: filetype=ebuild
