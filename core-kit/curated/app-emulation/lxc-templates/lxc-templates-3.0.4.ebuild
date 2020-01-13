# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="Old style template scripts for LXC"
HOMEPAGE="https://linuxcontainers.org/"
SRC_URI="https://linuxcontainers.org/downloads/lxc/${P}.tar.gz"

KEYWORDS="*"

LICENSE="LGPL-3"
SLOT="0"

RDEPEND="
	dev-util/debootstrap
	>=app-emulation/lxc-3.0"

DEPEND="${RDEPEND}"

PATCHES=( "${FILESDIR}/${PN}-3.0.1-no-cache-dir.patch" )
DOCS=()

src_prepare() {
	default
	eautoreconf
}
