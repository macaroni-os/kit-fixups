# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson

DESCRIPTION="A RIST protocol library."
HOMEPAGE="https://code.videolan.org/rist/librist"
SRC_URI="https://code.videolan.org/rist/librist/-/archive/v0.2.7/librist-v0.2.7.tar.gz"
#librist-v0.2.7
S="${WORKDIR}/${PN}-v${PV}"

LICENSE="FreeBSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND="
	>=dev-util/meson-0.47
	dev-util/ninja
"
