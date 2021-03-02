# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
PYTHON_REQ_USE="threads(+)"
inherit waf-utils python-single-r1

DESCRIPTION="Samba tevent library"
HOMEPAGE="https://tevent.samba.org/"
SRC_URI="https://samba.org/ftp/tevent/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="elibc_glibc python"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="test"

RDEPEND="
	!elibc_FreeBSD? ( dev-libs/libbsd )
	>=sys-libs/talloc-2.3.1
	python? (
		${PYTHON_DEPS}
		sys-libs/talloc[python,${PYTHON_USEDEP}]
	)
"
DEPEND="${RDEPEND}
	elibc_glibc? (
		net-libs/libtirpc
		|| (
			net-libs/rpcsvc-proto
			<sys-libs/glibc-2.26[rpc(+)]
		)
	)
"
BDEPEND="${PYTHON_DEPS}
	virtual/pkgconfig
"

WAF_BINARY="${S}/buildtools/bin/waf"

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	default
}

src_configure() {
	waf-utils_src_configure \
		--bundled-libraries=NONE \
		--builtin-libraries=NONE \
		$(usex python '' '--disable-python')
}

src_compile() {
	# need to avoid parallel building, this looks like the sanest way with waf-utils/multiprocessing eclasses
	unset MAKEOPTS
	waf-utils_src_compile
}

src_install() {
	waf-utils_src_install

	use python && python_domodule tevent.py
}

src_install_all() {
	insinto /usr/include
	doins tevent_internal.h
}
