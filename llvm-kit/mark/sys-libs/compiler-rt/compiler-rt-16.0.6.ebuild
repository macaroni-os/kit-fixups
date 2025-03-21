# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+)
CMAKE_BUILD_TYPE=RelWithDebInfo
inherit cmake flag-o-matic python-any-r1 toolchain-funcs

DESCRIPTION="Compiler runtime library for clang (built-in part)"
HOMEPAGE="https://llvm.org/"
SRC_URI="https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.6/llvm-project-16.0.6.src.tar.xz -> llvm-project-16.0.6.src.tar.xz"
LICENSE="Apache-2.0-with-LLVM-exceptions || ( UoI-NCSA MIT )"
SLOT="16"
KEYWORDS="*"
IUSE="+clang debug"
DEPEND="sys-devel/llvm
	
"
BDEPEND="dev-util/cmake
	clang? ( sys-devel/clang )
	${PYTHON_DEPS}
	
"
S="${WORKDIR}/llvm-src"
post_src_unpack() {
	mv llvm-project-* llvm-src
}
pkg_setup() {
	python-any-r1_pkg_setup
}
src_prepare() {
	CMAKE_USE_DIR="${S}/runtimes"
	#CMAKE_USE_DIR="${S}/compiler-rt"
	local s="${WORKDIR}"
	cmake_src_prepare
}
src_configure() {
	# Ensure to use llvm binary with the right version
	export PATH=${EROOT}/usr/lib/llvm/16/bin:${PATH}
	# LLVM_ENABLE_ASSERTIONS=NO does not guarantee this for us, #614844
	use debug || local -x CPPFLAGS="${CPPFLAGS} -DNDEBUG"
	# pre-set since we need to pass it to cmake
	BUILD_DIR=${WORKDIR}/${P}_build
	if use clang; then
	  # Only do this conditionally to allow overriding with
	  # e.g. CC=clang-13 in case of breakage
	  if ! tc-is-clang ; then
	    local -x CC=${CHOST}-clang
	    local -x CXX=${CHOST}-clang++
	  fi
	  strip-unsupported-flags
	fi
	local mycmakeargs=(
	  -DLLVM_CONFIG_PATH="/usr/lib/llvm/16/bin/llvm-config"
	  -DLLVM_ENABLE_RUNTIMES="compiler-rt"
	  -DCOMPILER_RT_INSTALL_PATH="${EPREFIX}/usr/lib/clang/16"
	  -DCOMPILER_RT_INCLUDE_TESTS=OFF
	  -DCOMPILER_RT_BUILD_LIBFUZZER=OFF
	  -DCOMPILER_RT_BUILD_MEMPROF=OFF
	  -DCOMPILER_RT_BUILD_ORC=OFF
	  -DCOMPILER_RT_BUILD_PROFILE=OFF
	  -DCOMPILER_RT_BUILD_SANITIZERS=OFF
	  -DCOMPILER_RT_BUILD_XRAY=OFF
	  -DPython3_EXECUTABLE="${PYTHON}"
	  -DCAN_TARGET_${CHOST/-pc-*/}=yes
	)
	cmake_src_configure
}


# vim: filetype=ebuild
