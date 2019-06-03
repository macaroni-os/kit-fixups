# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils libtool multilib-minimal

DESCRIPTION="A library for multiprecision complex arithmetic with exact rounding"
HOMEPAGE="http://mpc.multiprecision.org/"
SRC_URI="http://www.multiprecision.org/mpc/download/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0/3.1"
KEYWORDS="*"
IUSE="+static-libs"

DEPEND=">=dev-libs/gmp-4.3.2:0=[${MULTILIB_USEDEP},static-libs?]
	>=dev-libs/mpfr-2.4.2:0=[${MULTILIB_USEDEP},static-libs?]"
RDEPEND="${DEPEND}"


src_prepare() {
	default

	elibtoolize #347317
}

multilib_src_configure() {
	ECONF_SOURCE=${S} econf $(use_enable static-libs static)
}

multilib_src_install_all() {
	einstalldocs
	prune_libtool_files
}
