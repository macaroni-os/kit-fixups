# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+ )
inherit cmake pax-utils python-any-r1 toolchain-funcs

DESCRIPTION="Low Level Virtual Machine"
HOMEPAGE="https://llvm.org/"
SRC_URI="https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.6/llvm-project-16.0.6.src.tar.xz -> llvm-project-16.0.6.src.tar.xz"
LICENSE="Apache-2.0-with-LLVM-exceptions UoI-NCSA BSD public-domain rc"
SLOT="16"
KEYWORDS="*"
IUSE="debug doc exegesis gold libedit +libffi ncurses xar xml z3 zstd binutils-plugin"
DEPEND="${RDEPEND}
	gold? ( sys-libs/binutils-libs )
	
"
BDEPEND="dev-lang/perl
	dev-util/cmake
	sys-devel/gnuconfig
	${PYTHON_DEPS}
	doc? ( $(python_gen_any_dep '
	  dev-python/recommonmark[${PYTHON_USEDEP}]
	  dev-python/sphinx[${PYTHON_USEDEP}]
	') )
	libffi? ( virtual/pkgconfig )
	
"
RDEPEND="sys-libs/zlib:=
	exegesis? ( dev-libs/libpfm:= )
	gold? ( sys-devel/binutils:*[plugins] )
	libedit? ( dev-libs/libedit:= )
	libffi? ( dev-libs/libffi:0= )
	ncurses? ( sys-libs/ncurses:0= )
	xar? ( app-arch/xar )
	xml? ( dev-libs/libxml2:2= )
	z3? ( >=sci-mathematics/z3-4.7.1:0= )
	zstd? ( app-arch/zstd:= )
	
"
PDEPEND="sys-devel/llvm-common
	gold? ( >=sys-devel/llvmgold-${SLOT} )
	
"

ALL_LLVM_TARGET_FLAGS=(
	llvm_targets_ARC
	llvm_targets_CSKY
	llvm_targets_DirectX
	llvm_targets_M68k
	llvm_targets_SPIRV
	llvm_targets_Xtensa
	llvm_targets_AArch64
	llvm_targets_AMDGPU
	llvm_targets_ARM
	llvm_targets_AVR
	llvm_targets_BPF
	llvm_targets_Hexagon
	llvm_targets_Lanai
	llvm_targets_LoongArch
	llvm_targets_Mips
	llvm_targets_MSP430
	llvm_targets_NVPTX
	llvm_targets_PowerPC
	llvm_targets_RISCV
	llvm_targets_Sparc
	llvm_targets_SystemZ
	llvm_targets_VE
	llvm_targets_WebAssembly
	llvm_targets_X86
	llvm_targets_XCore
)

IUSE+=" ${ALL_LLVM_TARGET_FLAGS[*]}"
REQUIRED_USE+=" || ( ${ALL_LLVM_TARGET_FLAGS[*]} )"

CMAKE_BUILD_TYPE=RelWithDebInfo

post_src_unpack() {
	mv llvm-project-* ${S}
}

python_check_deps() {
	use doc || return 0

	has_version -b "dev-python/recommonmark[${PYTHON_USEDEP}]" &&
	has_version -b "dev-python/sphinx[${PYTHON_USEDEP}]"
}

# Is LLVM being linked against libc++?
is_libcxx_linked() {
	local code='#include <ciso646>
#if defined(_LIBCPP_VERSION)
	HAVE_LIBCXX
#endif
'
	local out=$($(tc-getCXX) ${CXXFLAGS} ${CPPFLAGS} -x c++ -E -P - <<<"${code}") || return 1

	[[ ${out} == *HAVE_LIBCXX* ]]
}

src_prepare() {
	local S=${S}/llvm
	cmake_src_prepare
}

src_configure() {
	local ffi_cflags ffi_ldflags
	if use libffi; then
		ffi_cflags=$($(tc-getPKG_CONFIG) --cflags-only-I libffi)
		ffi_ldflags=$($(tc-getPKG_CONFIG) --libs-only-L libffi)
	fi

	local distr_components="LLVM;LTO;Remarks;llvm-config;cmake-exports;llvm-headers;LLVMDemangle;LLVMSupport;LLVMTableGen;llvm-tblgen;FileCheck;llvm-PerfectShuffle;count;not;yaml-bench;UnicodeNameMappingGenerator;bugpoint;dsymutil;llc;lli;lli-child-target;llvm-addr2line;llvm-ar;llvm-as;llvm-bcanalyzer;llvm-bitcode-strip;llvm-c-test;llvm-cat;llvm-cfi-verify;llvm-config;llvm-cov;llvm-cvtres;llvm-cxxdump;llvm-cxxfilt;llvm-cxxmap;llvm-debuginfo-analyzer;llvm-debuginfod;llvm-debuginfod-find;llvm-diff;llvm-dis;llvm-dlltool;llvm-dwarfdump;llvm-dwarfutil;llvm-dwp;llvm-exegesis;llvm-extract;llvm-gsymutil;llvm-ifs;llvm-install-name-tool;llvm-jitlink;llvm-jitlink-executor;llvm-lib;llvm-libtool-darwin;llvm-link;llvm-lipo;llvm-lto;llvm-lto2;llvm-mc;llvm-mca;llvm-ml;llvm-modextract;llvm-mt;llvm-nm;llvm-objcopy;llvm-objdump;llvm-opt-report;llvm-otool;llvm-pdbutil;llvm-profdata;llvm-profgen;llvm-ranlib;llvm-rc;llvm-readelf;llvm-readobj;llvm-reduce;llvm-remark-size-diff;llvm-remarkutil;llvm-rtdyld;llvm-sim;llvm-size;llvm-split;llvm-stress;llvm-strings;llvm-strip;llvm-symbolizer;llvm-tapi-diff;llvm-tli-checker;llvm-undname;llvm-windres;llvm-xray;obj2yaml;opt;sancov;sanstats;split-file;verify-uselistorder;yaml2obj;opt-viewer"
	if use binutils-plugin ; then
		distr_components="${distr_components};LLVMgold"
	fi

	local libdir=$(get_libdir)
	local mycmakeargs=(
		# disable appending VCS revision to the version to improve
		# direct cache hit ratio
		-DLLVM_APPEND_VC_REV=OFF
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr/lib/llvm/${SLOT}"
		-DLLVM_LIBDIR_SUFFIX=${libdir#lib}

		-DBUILD_SHARED_LIBS=OFF
		-DLLVM_BUILD_LLVM_DYLIB=ON
		-DLLVM_LINK_LLVM_DYLIB=ON
		-DLLVM_DISTRIBUTION_COMPONENTS=${distr_components}

		# cheap hack: LLVM combines both anyway, and the only difference
		# is that the former list is explicitly verified at cmake time
		-DLLVM_TARGETS_TO_BUILD=""
		-DLLVM_EXPERIMENTAL_TARGETS_TO_BUILD="${LLVM_TARGETS// /;}"
		-DLLVM_INCLUDE_BENCHMARKS=OFF
		-DLLVM_INCLUDE_TESTS=OFF
		-DLLVM_BUILD_TESTS=OFF

		-DLLVM_ENABLE_FFI=$(usex libffi)
		-DLLVM_ENABLE_LIBEDIT=$(usex libedit)
		-DLLVM_ENABLE_TERMINFO=$(usex ncurses)
		-DLLVM_ENABLE_LIBXML2=$(usex xml)
		-DLLVM_ENABLE_ASSERTIONS=$(usex debug)
		-DLLVM_ENABLE_LIBPFM=$(usex exegesis)
		-DLLVM_ENABLE_EH=ON
		-DLLVM_ENABLE_RTTI=ON
		-DLLVM_ENABLE_ZLIB=ON
		-DLLVM_ENABLE_Z3_SOLVER=$(usex z3)
		-DLLVM_ENABLE_ZSTD=$(usex zstd)

		-DLLVM_HOST_TRIPLE="${CHOST}"

		-DFFI_INCLUDE_DIR="${ffi_cflags#-I}"
		-DFFI_LIBRARY_DIR="${ffi_ldflags#-L}"
		# used only for llvm-objdump tool
		-DLLVM_HAVE_LIBXAR=$(usex xar 1 0)

		-DPython3_EXECUTABLE="${PYTHON}"

		# disable OCaml bindings (now in dev-ml/llvm-ocaml)
		-DOCAMLFIND=NO
	)

	if is_libcxx_linked; then
		# Smart hack: alter version suffix -> SOVERSION when linking
		# against libc++. This way we won't end up mixing LLVM libc++
		# libraries with libstdc++ clang, and the other way around.
		mycmakeargs+=(
			-DLLVM_VERSION_SUFFIX="libcxx"
			-DLLVM_ENABLE_LIBCXX=ON
		)
	fi

	# Documentation could be built from users manually.
	mycmakeargs+=(
		-DLLVM_BUILD_DOCS=OFF
		-DLLVM_ENABLE_OCAMLDOC=OFF
		-DLLVM_ENABLE_SPHINX=OFF
		-DLLVM_ENABLE_DOXYGEN=OFF
		-DLLVM_INSTALL_UTILS=ON
	)
	use gold && mycmakeargs+=(
		-DLLVM_BINUTILS_INCDIR="${EPREFIX}"/usr/include
	)


	# LLVM_ENABLE_ASSERTIONS=NO does not guarantee this for us, #614844
	use debug || local -x CPPFLAGS="${CPPFLAGS} -DNDEBUG"
	local S=${S}/llvm
	cmake_src_configure
}

src_compile() {
	tc-env_build cmake_build distribution

	pax-mark m "${BUILD_DIR}"/bin/llvm-rtdyld
	pax-mark m "${BUILD_DIR}"/bin/lli
	pax-mark m "${BUILD_DIR}"/bin/lli-child-target
}

src_install() {
	DESTDIR=${D} cmake_build install-distribution

	# move headers to /usr/include for wrapping
	rm -rf "${ED}"/usr/include || die
	mv "${ED}"/usr/lib/llvm/${SLOT}/include "${ED}"/usr/include || die

	LLVM_LDPATHS+=( "${EPREFIX}/usr/lib/llvm/${SLOT}/$(get_libdir)" )

	newenvd - "60llvm-${SLOT}" <<-_EOF_
		PATH="${EPREFIX}/usr/lib/llvm/${SLOT}/bin"
		# we need to duplicate it in ROOTPATH for Portage to respect...
		ROOTPATH="${EPREFIX}/usr/lib/llvm/${SLOT}/bin"
		MANPATH="${EPREFIX}/usr/lib/llvm/${SLOT}/share/man"
		LDPATH="$( IFS=:; echo "${LLVM_LDPATHS[*]}" )"
	_EOF_

	docompress "/usr/lib/llvm/${SLOT}/share/man"

	# move wrapped headers back
	mv "${ED}"/usr/include "${ED}"/usr/lib/llvm/${SLOT}/include || die
}

pkg_postinst() {
	elog "You can find additional opt-viewer utility scripts in:"
	elog "  ${EROOT}/usr/lib/llvm/${SLOT}/share/opt-viewer"
	elog "To use these scripts, you will need Python along with the following"
	elog "packages:"
	elog "  dev-python/pygments (for opt-viewer)"
	elog "  dev-python/pyyaml (for all of them)"
}

# vim: filetype=ebuild
