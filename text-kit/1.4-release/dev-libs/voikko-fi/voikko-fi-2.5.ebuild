# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
PYTHON_REQ_USE="xml(+)"

inherit python-any-r1

DESCRIPTION="Finnish dictionary for libvoikko based spell checkers (vvfst format)"
HOMEPAGE="https://voikko.puimula.org/"
SRC_URI="https://github.com/voikko/corevoikko/tarball/a3f29da7ce47d77e325898d04f01ac9b5c311581 -> corevoikko-2.5-a3f29da.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="*"

DEPEND="dev-libs/foma:=
	dev-libs/libvoikko"
RDEPEND="${DEPEND}"
BDEPEND="${PYTHON_DEPS}
	dev-libs/libvoikko
	"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}"/voikko-* "${S}"
	S="${S}/voikko-fi"
}

src_compile() {
	emake vvfst
}

src_install() {
	emake DESTDIR="${D}/usr/share/voikko/" vvfst-install
	einstalldocs
}