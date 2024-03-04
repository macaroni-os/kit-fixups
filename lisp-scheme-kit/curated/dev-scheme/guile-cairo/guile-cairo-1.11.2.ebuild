# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="Wraps the Cairo graphics library for Guile Scheme"
HOMEPAGE="http://www.nongnu.org/guile-cairo/"
SRC_URI="http://download.savannah.gnu.org/releases/${PN}/${P}.tar.gz"

LICENSE="GPL-3 LGPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="static-libs test"

RDEPEND="
	>=dev-scheme/guile-1.8
	>=x11-libs/cairo-1.4"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	test? ( dev-scheme/guile-lib )"

src_configure() {
	local myeconfargs=( --disable-Werror )
	autotools_src_configure
}
