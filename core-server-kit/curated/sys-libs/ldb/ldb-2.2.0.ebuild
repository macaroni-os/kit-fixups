# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
PYTHON_REQ_USE="threads(+)"
inherit python-single-r1 waf-utils

DESCRIPTION="LDAP-like embedded database"
HOMEPAGE="https://ldb.samba.org"
SRC_URI="https://samba.org/ftp/pub/${PN}/${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0/${PV}"
KEYWORDS="*"
IUSE="doc +ldap +lmdb python test"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
	test? ( python )"

RESTRICT="!test? ( test )"

RDEPEND="
	!elibc_FreeBSD? ( dev-libs/libbsd )
	dev-libs/popt
	>=dev-util/cmocka-1.1.3
	>=sys-libs/talloc-2.3.1
	>=sys-libs/tdb-1.4.3
	>=sys-libs/tevent-0.10.2
	ldap? ( net-nds/openldap )
	lmdb? ( >=dev-db/lmdb-0.9.16 )
	python? (
		${PYTHON_DEPS}
		sys-libs/talloc[python,${PYTHON_USEDEP}]
		sys-libs/tdb[python,${PYTHON_USEDEP}]
		sys-libs/tevent[python,${PYTHON_USEDEP}]
	)
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}
	dev-libs/libxslt
	virtual/pkgconfig
	doc? ( app-doc/doxygen )
"

WAF_BINARY="${S}/buildtools/bin/waf"

MULTILIB_WRAPPED_HEADERS=( /usr/include/pyldb.h )

PATCHES=(
	"${FILESDIR}"/${PN}-1.5.2-optional_packages.patch
	"${FILESDIR}"/${PN}-1.1.31-fix_PKGCONFIGDIR-when-python-disabled.patch
)

pkg_setup() {
	# Package fails to build with distcc
	export DISTCC_DISABLE=1

	# waf requires a python interpreter
	python-single-r1_pkg_setup
}

src_prepare() {
	default
}

src_configure() {
	local myconf=(
		$(usex ldap '' --disable-ldap)
		$(usex lmdb '' --without-ldb-lmdb)
		--disable-rpath
		--disable-rpath-install --bundled-libraries=NONE
		--with-modulesdir="${EPREFIX}"/usr/$(get_libdir)/samba
		--builtin-libraries=NONE
	)

	use python || myconf+=( --disable-python )
	waf-utils_src_configure "${myconf[@]}"
}

src_compile() {
	waf-utils_src_compile
	use doc && doxygen Doxyfile
}

src_test() {
	WAF_MAKE=1 \
	PATH=buildtools/bin:../../../buildtools/bin:$PATH:"${BUILD_DIR}"/bin/shared/private/ \
	LD_LIBRARY_PATH=$LD_LIBRARY_PATH:"${BUILD_DIR}"/bin/shared/private/:"${BUILD_DIR}"/bin/shared \
	waf test || die
}

src_install() {
	waf-utils_src_install

	if use doc; then
		doman  apidocs/man/man3/*.3
		docinto html
		dodoc -r apidocs/html/.
	fi

	use python && python_optimize #726454
}

pkg_postinst() {
	if has_version sys-auth/sssd; then
		ewarn "You have sssd installed. It is known to break after ldb upgrades,"
		ewarn "so please try to rebuild it before reporting bugs."
		ewarn "See https://bugs.gentoo.org/404281"
	fi
}
