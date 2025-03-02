# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+)
inherit cmake flag-o-matic python-single-r1 toolchain-funcs

DESCRIPTION="C language family frontend for LLVM"
HOMEPAGE="https://llvm.org/"
SRC_URI="https://github.com/llvm/llvm-project/releases/download/llvmorg-16.0.6/llvm-project-16.0.6.src.tar.xz -> llvm-project-16.0.6.src.tar.xz"
LICENSE="Apache-2.0-with-LLVM-exceptions UoI-NCSA MIT"
SLOT="16"
KEYWORDS="*"
IUSE="debug +extra ieee-long-double +pie +static-analyzer xml llvm-libunwind
	default-compiler-rt default-libcxx default-lld
	"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
DEPEND="~sys-devel/llvm-16.0.6:16[debug=]
	static-analyzer? ( dev-lang/perl:* )
	xml? ( dev-libs/libxml2:2 )

"
BDEPEND="${PYTHON_DEPS}
	dev-util/cmake
	xml? ( virtual/pkgconfig )

"
RDEPEND="${PYTHON_DEPS}
	${DEPEND}

"
PDEPEND="sys-devel/clang-common
	~sys-devel/clang-runtime-16.0.6
	default-compiler-rt? (
	  =sys-libs/compiler-rt-${PV%_*}*
	  llvm-libunwind? ( sys-libs/llvm-libunwind )
	  !llvm-libunwind? ( sys-libs/libunwind )
	)
	default-libcxx? ( >=sys-libs/libcxx-16.0.6 )
	default-lld? ( sys-devel/lld )

"

CMAKE_BUILD_TYPE=RelWithDebInfo
LLVM_USE_TARGETS=llvm

post_src_unpack() {
	mv llvm-project-* ${S}
}

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	# create extra parent dir for relative CLANG_RESOURCE_DIR access
	#mkdir -p x/y || die
	#BUILD_DIR=${WORKDIR}/x/y/clang
	# Ensure to use llvm binary with the right version
	export PATH=${EROOT}/usr/lib/llvm/16/bin:${PATH}
	#local S=${S}/clang
	CMAKE_USE_DIR="${S}/clang"
	cmake_src_prepare
}

src_configure() {
	local llvm_version=$(llvm-config --version) || die
	local clang_version=$(ver_cut 1-3 "${llvm_version}")

	local distr_components="bash-autocomplete;clang-cmake-exports;clang-headers;clang-resource-headers;libclang-headers;libclang-python-bindings;aarch64-resource-headers;arm-common-resource-headers;arm-resource-headers;core-resource-headers;cuda-resource-headers;hexagon-resource-headers;hip-resource-headers;hlsl-resource-headers;mips-resource-headers;opencl-resource-headers;openmp-resource-headers;ppc-htm-resource-headers;ppc-resource-headers;riscv-resource-headers;systemz-resource-headers;utility-resource-headers;ve-resource-headers;webassembly-resource-headers;windows-resource-headers;x86-resource-headers;clang-cpp;libclang;amdgpu-arch;c-index-test;clang;clang-format;clang-offload-bundler;clang-offload-packager;clang-refactor;clang-repl;clang-rename;clang-scan-deps;diagtool;hmaptool;nvptx-arch;clang-tblgen"
	if use extra ; then
		distr_components="${distr_components};clang-apply-replacements;clang-change-namespace;clang-doc;clang-include-cleaner;clang-include-fixer;clang-move;clang-pseudo;clang-query;clang-reorder-fields;clang-tidy;clang-tidy-headers;clangd;find-all-symbols;modularize;pp-trace"
	fi
	if use static-analyzer ; then
		distr_components="${distr_components};clang-check;clang-extdef-mapping;scan-build;scan-build-py;scan-view"
	fi

	local mycmakeargs=(
		-DDEFAULT_SYSROOT=$(usex prefix-guest "" "${EPREFIX}")
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr/lib/llvm/${SLOT}"
		-DCMAKE_INSTALL_MANDIR="${EPREFIX}/usr/lib/llvm/${SLOT}/share/man"
		-DCLANG_CONFIG_FILE_SYSTEM_DIR="${EPREFIX}/etc/clang"
		# relative to bindir
		-DCLANG_RESOURCE_DIR="../../../../lib/clang/${clang_version}"
		-DCLANG_VENDOR=MacaroniOS

		-DLLVM_DISTRIBUTION_COMPONENTS=${distr_components}
		-DBUILD_SHARED_LIBS=OFF
		-DCLANG_LINK_CLANG_DYLIB=ON
		-DCLANG_INCLUDE_TESTS=OFF
		-DCLANG_PLUGIN_SUPPORT=ON

		-DLLVM_TARGETS_TO_BUILD="${LLVM_TARGETS// /;}"

		# these are not propagated reliably, so redefine them
		-DLLVM_ENABLE_EH=ON
		-DLLVM_ENABLE_RTTI=ON

		-DCMAKE_DISABLE_FIND_PACKAGE_LibXml2=$(usex !xml)
		# libgomp support fails to find headers without explicit -I
		# furthermore, it provides only syntax checking
		-DCLANG_DEFAULT_OPENMP_RUNTIME=libomp

		# disable using CUDA to autodetect GPU, just build for all
		-DCMAKE_DISABLE_FIND_PACKAGE_CUDA=ON

		# override default stdlib and rtlib
		-DCLANG_DEFAULT_CXX_STDLIB=$(usex default-libcxx libc++ "")
		-DCLANG_DEFAULT_RTLIB=$(usex default-compiler-rt compiler-rt "")
		-DCLANG_DEFAULT_LINKER=$(usex default-lld lld "")
		-DCLANG_DEFAULT_PIE_ON_LINUX=$(usex pie)
		-DCLANG_DEFAULT_UNWINDLIB=$(usex default-compiler-rt libunwind "")

		-DCLANG_ENABLE_ARCMT=$(usex static-analyzer)
		-DCLANG_ENABLE_STATIC_ANALYZER=$(usex static-analyzer)

		-DPython3_EXECUTABLE="${PYTHON}"

		-DLLVM_EXTERNAL_CLANG_TOOLS_EXTRA_SOURCE_DIR="${S}"/clang-tools-extra

		-DCLANG_INCLUDE_DOCS=OFF
		-DCLANG_TOOLS_EXTRA_INCLUDE_DOCS=OFF

		-DGCC_INSTALL_PREFIX="${EPREFIX}/usr"
	)

	if ! use elibc_musl; then
		mycmakeargs+=(
			-DPPC_LINUX_DEFAULT_IEEELONGDOUBLE=$(usex ieee-long-double)
		)
	fi

	if tc-is-cross-compiler; then
		[[ -x "/usr/bin/clang-tblgen" ]] \
			|| die "/usr/bin/clang-tblgen not found or usable"
		mycmakeargs+=(
			-DCMAKE_CROSSCOMPILING=ON
			-DCLANG_TABLEGEN=/usr/bin/clang-tblgen
		)
	fi

	# LLVM can have very high memory consumption while linking,
	# exhausting the limit on 32-bit linker executable
	use x86 && local -x LDFLAGS="${LDFLAGS} -Wl,--no-keep-memory"

	# LLVM_ENABLE_ASSERTIONS=NO does not guarantee this for us, #614844
	use debug || local -x CPPFLAGS="${CPPFLAGS} -DNDEBUG"
	cmake_src_configure
}

src_compile() {
	cmake_build distribution

	# provide a symlink for tests
	if [[ ! -L ${WORKDIR}/lib/clang ]]; then
		mkdir -p "${WORKDIR}"/lib || die
		ln -s "${BUILD_DIR}/$(get_libdir)/clang" "${WORKDIR}"/lib/clang || die
	fi
}

src_install() {
	DESTDIR=${D} cmake_build install-distribution

	# move headers to /usr/include for wrapping & ABI mismatch checks
	# (also drop the version suffix from runtime headers)
	rm -rf "${ED}"/usr/include || die
	mv "${ED}"/usr/lib/llvm/${SLOT}/include "${ED}"/usr/include || die
	mv "${ED}"/usr/lib/llvm/${SLOT}/$(get_libdir)/clang "${ED}"/usr/include/clangrt || die
	# don't wrap clang-tidy headers, the list is too long
	# (they're fine for non-native ABI but enabling the targets is problematic)
	mv "${ED}"/usr/include/clang-tidy "${T}/" || die

	# Move runtime headers to /usr/lib/clang, where they belong
	mv "${ED}"/usr/include/clangrt "${ED}"/usr/lib/clang || die
	# move (remaining) wrapped headers back
	if use extra; then
		mv "${T}"/clang-tidy "${ED}"/usr/include/ || die
	fi
	mv "${ED}"/usr/include "${ED}"/usr/lib/llvm/${SLOT}/include || die

	# Apply CHOST and version suffix to clang tools
	# note: we use two version components here (vs 3 in runtime path)
	local llvm_version=$(llvm-config --version) || die
	local clang_version=$(ver_cut 1 "${llvm_version}")
	local clang_full_version=$(ver_cut 1-3 "${llvm_version}")
	local clang_tools=( clang clang++ clang-cl clang-cpp )
	local abi i

	# cmake gives us:
	# - clang-X
	# - clang -> clang-X
	# - clang++, clang-cl, clang-cpp -> clang
	# we want to have:
	# - clang-X
	# - clang++-X, clang-cl-X, clang-cpp-X -> clang-X
	# - clang, clang++, clang-cl, clang-cpp -> clang*-X
	# also in CHOST variant
	for i in "${clang_tools[@]:1}"; do
		rm "${ED}/usr/lib/llvm/${SLOT}/bin/${i}" || die
		dosym "clang-${clang_version}" "/usr/lib/llvm/${SLOT}/bin/${i}-${clang_version}"
		dosym "${i}-${clang_version}" "/usr/lib/llvm/${SLOT}/bin/${i}"
	done

	# now create target symlinks for all supported ABIs
	for abi in $(get_all_abis); do
		local abi_chost=$(get_abi_CHOST "${abi}")
		for i in "${clang_tools[@]}"; do
			dosym "${i}-${clang_version}" \
				"/usr/lib/llvm/${SLOT}/bin/${abi_chost}-${i}-${clang_version}"
			dosym "${abi_chost}-${i}-${clang_version}" \
				"/usr/lib/llvm/${SLOT}/bin/${abi_chost}-${i}"
		done
	done

	python_fix_shebang "${ED}"
	if use static-analyzer; then
		python_optimize "${ED}"/usr/lib/llvm/${SLOT}/share/scan-view
	fi

	docompress "/usr/lib/llvm/${SLOT}/share/man"
	# +x for some reason; TODO: investigate
	use static-analyzer && fperms a-x "/usr/lib/llvm/${SLOT}/share/man/man1/scan-build.1"
}

pkg_postinst() {
	if [[ -z ${ROOT} && -f ${EPREFIX}/usr/share/eselect/modules/compiler-shadow.eselect ]] ; then
		eselect compiler-shadow update all
	fi

	elog "You can find additional utility scripts in:"
	elog "  ${EROOT}/usr/lib/llvm/${SLOT}/share/clang"
	if use extra; then
		elog "Some of them are vim integration scripts (with instructions inside)."
		elog "The run-clang-tidy.py script requires the following additional package:"
		elog "  dev-python/pyyaml"
	fi
}

pkg_postrm() {
	if [[ -z ${ROOT} && -f ${EPREFIX}/usr/share/eselect/modules/compiler-shadow.eselect ]] ; then
		eselect compiler-shadow clean all
	fi
}

# filetype=ebuild