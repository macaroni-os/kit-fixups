# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic

DESCRIPTION="Free Japanese conversion engine"
HOMEPAGE="http://anthy.osdn.jp/"
SRC_URI="https://osdn.net/dl/anthy/anthy-9100h.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="static-libs"

RDEPEND=""
DEPEND="${RDEPEND}"

PATCHES=( "${FILESDIR}/${PN}-anthy_context_t.patch" )
DOCS=( AUTHORS ChangeLog DIARY NEWS README )

src_configure() {
	econf $(use_enable static-libs static)
}

src_install() {
	default
	find "${D}" -name "*.la" -type f -delete || die

	rm doc/Makefile* || die
	dodoc -r doc
}
