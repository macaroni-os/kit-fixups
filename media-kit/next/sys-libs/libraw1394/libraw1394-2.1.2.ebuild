# Distributed under the terms of the GNU General Public License v2

EAPI=7

AUTOTOOLS_PRUNE_LIBTOOL_FILES=all

inherit autotools

DESCRIPTION="library that provides direct access to the IEEE 1394 bus"
HOMEPAGE="https://ieee1394.wiki.kernel.org/"
SRC_URI="mirror://kernel/linux/libs/ieee1394/${P}.tar.xz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="static-libs"

DEPEND="app-arch/xz-utils"
RDEPEND=""
