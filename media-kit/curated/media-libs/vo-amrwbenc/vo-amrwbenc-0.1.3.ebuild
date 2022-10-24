# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit

SRC_URI="mirror://sourceforge/opencore-amr/${P}.tar.gz"
KEYWORDS="*"

DESCRIPTION="VisualOn AMR-WB encoder library"
HOMEPAGE="https://sourceforge.net/projects/opencore-amr/"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="examples static-libs"

src_prepare() {
	default
}

src_configure() {
	econf \
		$(use_enable examples example) \
		$(use_enable static-libs static)
}

DOCS=("ChangeLog" "README")
src_install() {
	default

	# package provides .pc files
	find "${D}" -name '*.la' -delete || die
}
