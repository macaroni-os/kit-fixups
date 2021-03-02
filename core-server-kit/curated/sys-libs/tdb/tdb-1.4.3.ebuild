# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
PYTHON_REQ_USE="threads(+)"
inherit waf-utils python-single-r1

DESCRIPTION="Simple database API"
HOMEPAGE="https://tdb.samba.org/"
SRC_URI="https://samba.org/ftp/tdb/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="python"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="test"

RDEPEND="
	!elibc_FreeBSD? ( dev-libs/libbsd )
	python? ( ${PYTHON_DEPS} )
"
DEPEND="${RDEPEND}"
BDEPEND="${PYTHON_DEPS}
	app-text/docbook-xml-dtd:4.2
"

WAF_BINARY="${S}/buildtools/bin/waf"

src_prepare() {
	default
	python_fix_shebang .
}

src_configure() {
	local extra_opts=()
	if ! use python; then
		extra_opts+=( --disable-python )
	fi

	waf-utils_src_configure "${extra_opts[@]}"
}

src_compile() {
	# need to avoid parallel building, this looks like the sanest way with waf-utils/multiprocessing eclasses
	unset MAKEOPTS
	waf-utils_src_compile
}

src_test() {
	# the default src_test runs 'make test' and 'make check', letting
	# the tests fail occasionally (reason: unknown)
	emake check
}

src_install() {
	waf-utils_src_install
}
