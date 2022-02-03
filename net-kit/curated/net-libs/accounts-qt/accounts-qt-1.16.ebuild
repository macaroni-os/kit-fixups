# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit qmake-utils

DESCRIPTION="Qt5 bindings for libaccounts-glib"
HOMEPAGE="https://01.org/gsso/"
SRC_URI="https://gitlab.com/accounts-sso/lib${PN}/-/archive/VERSION_${PV}/lib${PN}-VERSION_${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/lib${PN}-VERSION_${PV}"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="doc test"

# dbus problems
RESTRICT="test"

RDEPEND="
	>=net-libs/libaccounts-glib-1.23
	dev-libs/glib:2
	dev-qt/qtcore:5
	dev-qt/qtxml:5
"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	test? ( dev-qt/qttest:5 )
"

src_prepare() {
	default

	sed -e "s|share/doc/\$\${PROJECT_NAME}|share/doc/${PF}|" -i doc/doc.pri || die
	use doc || sed -e "/include( doc\/doc.pri )/d" -i ${PN}.pro || die
	use test || sed -i -e '/^SUBDIRS/s/tests//' accounts-qt.pro || die "couldn't disable tests"
}

src_configure() {
	eqmake5 LIBDIR="${EPREFIX%/}/usr/$(get_libdir)"
}

src_install() {
	emake INSTALL_ROOT="${D}" install
}
