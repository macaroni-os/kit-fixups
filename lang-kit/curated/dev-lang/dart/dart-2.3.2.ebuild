EAPI=6
PYTHON_COMPAT=( python2_7 )

inherit flag-o-matic eutils python-r1 llvm ninja-utils

# Many thanks to https://github.com/mausys for this ebuild

DESCRIPTION="Dart is a cohesive, scalable platform for building apps"
HOMEPAGE="https://www.dartlang.org/"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug"
SRC_URI="http://commondatastorage.googleapis.com/dart-archive/channels/stable/raw/${PV}/src/${P}.tar.gz"

RDEPEND=">=sys-devel/clang-5 >=sys-devel/llvm-5"

DEPEND="dev-util/gn ${RDEPEND}"

S_DART="${S}/${PN}"
BUILD_DIR="${S}/out"

llvm_check_deps() {
	has_version "sys-devel/clang:${LLVM_SLOT}"
}


src_prepare() {
	cd ${S}
	rm -R debian
	cd ${S_DART}
	rm -R buildtools
	rm -R build/linux/debian*
	epatch "${FILESDIR}/dart-2.3.2.patch"
	epatch "${FILESDIR}/dart-2.3.2-catch_entry_moves_test-fix.patch"
	default
}

src_configure() {
	python_setup
	mkdir ${BUILD_DIR}
	cd ${BUILD_DIR}
	cat <<- EOF > args.gn
		llvm_prefix = "$(get_llvm_prefix)"
		dart_debug = false
		dart_platform_bytecode = false
		dart_platform_sdk = false
		dart_runtime_mode = "develop"
		dart_snapshot_kind = "app-jit"
		dart_stripped_binary = "exe.stripped/dart"
		dart_target_arch = "x64"
		dart_use_crashpad = false
		dart_use_debian_sysroot = false
		dart_use_fallback_root_certificates = true
		dart_use_tcmalloc = true
		dart_vm_code_coverage = false
		exclude_kernel_service = false
		goma_dir = "None"
		host_cpu = "x64"
		is_asan = false
		is_clang = true
		is_debug = false
		is_msan = false
		is_product = false
		is_release = true
		is_tsan = false
		target_cpu = "x64"
		target_os = "linux"
		target_sysroot = ""
		use_goma = false
	EOF
	gn gen . --root=${S_DART} || die
}

src_compile() {
	cd ${BUILD_DIR}
	eninja most || die
}

src_install() {
	local instdir=/usr/$(get_libdir)/dart-sdk
	local bins="dart dartdevc dart2js dartdoc dartfmt pub dartanalyzer"
	insinto ${instdir}
	doins -r ${BUILD_DIR}/dart-sdk/*
	for b in ${bins} ; do
		fperms 0775 ${instdir}/bin/${b}
		dosym ${instdir}/bin/${b} /usr/bin/${b}
	done
}
