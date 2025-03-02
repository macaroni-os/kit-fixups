# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+)
CMAKE_BUILD_TYPE=RelWithDebInfo
SANITIZER_FLAGS=( asan dfsan lsan msan hwasan tsan ubsan safestack cfi scudo shadowcallstack gwp-asan )
inherit cmake flag-o-matic python-any-r1 toolchain-funcs

DESCRIPTION="Compiler runtime libraries for clang (sanitizers & xray)"
HOMEPAGE="https://llvm.org/"
SRC_URI="https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.6/llvm-project-16.0.6.src.tar.xz -> llvm-project-16.0.6.src.tar.xz"
LICENSE="Apache-2.0-with-LLVM-exceptions || ( UoI-NCSA MIT )"
SLOT="16"
KEYWORDS="*"
IUSE="+clang debug elibc_glibc +libfuzzer +memprof +orc +profile +xray ${SANITIZER_FLAGS[@]/#/+}"
REQUIRED_USE="|| ( ${SANITIZER_FLAGS[*]} libfuzzer orc profile xray )
"
DEPEND="sys-devel/llvm
	
"
BDEPEND="dev-util/cmake
	clang? ( sys-devel/clang )
	elibc_glibc? ( net-libs/libtirpc )
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
	sed -i -e 's:-Werror::' compiler-rt/lib/tsan/go/buildgo.sh || die
	local flag
	for flag in "${SANITIZER_FLAGS[@]}"; do
	  if ! use "${flag}"; then
	    local cmake_flag=${flag/-/_}
	    sed -i -e "/COMPILER_RT_HAS_${cmake_flag^^}/s:TRUE:FALSE:" \
	      compiler-rt/cmake/config-ix.cmake || die
	  fi
	done
	# bug #926330
	sed -i -e '/-Wthread-safety/d' compiler-rt/CMakeLists.txt \
	  compiler-rt/cmake/config-ix.cmake || die
	# TODO: fix these tests to be skipped upstream
	if use asan && ! use profile; then
	  rm compiler-rt/test/asan/TestCases/asan_and_llvm_coverage_test.cpp || die
	fi
	if use ubsan && ! use cfi; then
	  > compiler-rt/test/cfi/CMakeLists.txt || die
	fi
	if has_version -b ">=sys-libs/glibc-2.37"; then
	  # known failures with glibc-2.37
	  # https://github.com/llvm/llvm-project/issues/60678
	  rm compiler-rt/test/dfsan/custom.cpp || die
	  rm compiler-rt/test/dfsan/release_shadow_space.c || die
	fi
	CMAKE_USE_DIR="${S}/runtimes"
	local s="${WORKDIR}"
	cmake_src_prepare
}
src_configure() {
	# Ensure to use llvm binary with the right version
	export PATH=${EROOT}/usr/lib/llvm/16/bin:${PATH}
	# LLVM_ENABLE_ASSERTIONS=NO does not guarantee this for us, #614844
	use debug || local -x CPPFLAGS="${CPPFLAGS} -DNDEBUG"
	# pre-set since we need to pass it to cmake
	BUILD_DIR=${WORKDIR}/compiler-rt_build
	local extra_cflags=""
	if use clang; then
	  extra_cflags="-I/usr/lib/clang/16/include/"
	  export CPPFLAGS="-I/usr/lib/clang/16/include/"
	  local -x CC=${CHOST}-clang
	  local -x CXX=${CHOST}-clang++
	  strip-unsupported-flags
	fi
	local flag want_sanitizer=OFF
	for flag in "${SANITIZER_FLAGS[@]}"; do
	  if use "${flag}"; then
	    want_sanitizer=ON
	    break
	  fi
	done
	local mycmakeargs=(
	  -DLLVM_CONFIG_PATH="/usr/lib/llvm/16/bin/llvm-config"
	  -DLLVM_ENABLE_RUNTIMES="compiler-rt"
	  -DCOMPILER_RT_INSTALL_PATH="${EPREFIX}/usr/lib/clang/16"
	  -DCOMPILER_RT_OUTPUT_DIR="${BUILD_DIR}/lib/clang/16"
	  -DCOMPILER_RT_INCLUDE_TESTS=OFF
	  -DCOMPILER_RT_BUILD_BUILTINS=OFF
	  -DCOMPILER_RT_BUILD_CRT=OFF
	  -DCOMPILER_RT_COMMON_CFLAGS="${extra_cflags}"
	  -DCOMPILER_RT_CXX_CFLAGS="${extra_cflags}"
	  -DCMAKE_CXX_FLAGS="${extra_cflags}"
	  -DLIBCXX_ADDITIONAL_COMPILE_FLAGS="${extra_cflags}"
	  -DCOMPILER_RT_BUILD_LIBFUZZER=$(usex libfuzzer)
	  -DCOMPILER_RT_BUILD_MEMPROF=$(usex memprof)
	  -DCOMPILER_RT_BUILD_ORC=$(usex orc)
	  -DCOMPILER_RT_BUILD_PROFILE=$(usex profile)
	  -DCOMPILER_RT_BUILD_SANITIZERS="${want_sanitizer}"
	  -DCOMPILER_RT_BUILD_XRAY=$(usex xray)
	  -DPython3_EXECUTABLE="${PYTHON}"
	  -DCAN_TARGET_${CHOST/-pc-*/}=yes
	)
	cmake_src_configure
}


# vim: filetype=ebuild
