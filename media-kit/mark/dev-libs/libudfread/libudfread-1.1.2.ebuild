# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

SRC_URI="https://code.videolan.org/videolan/libudfread/-/archive/${PV}/${P}.tar.gz"
KEYWORDS="*"


DESCRIPTION="Library for reading UDF from raw devices and image files"
HOMEPAGE="https://code.videolan.org/videolan/libudfread/"

LICENSE="LGPL-2.1+"
SLOT="0"
IUSE="static-libs"

src_prepare() {
	default
	eautoreconf
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
	if ! use static-libs ; then
		find "${D}" -name '*.a' -delete || die
	fi
}
