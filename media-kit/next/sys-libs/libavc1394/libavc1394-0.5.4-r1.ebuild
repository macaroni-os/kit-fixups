# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="library for the 1394 AV/C (Audio/Video Control) Digital Interface Command Set"
HOMEPAGE="https://sourceforge.net/projects/libavc1394/"
SRC_URI="mirror://sourceforge/libavc1394/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="static-libs"

RDEPEND=">=sys-libs/libraw1394-2.1.0-r1"
DEPEND="${RDEPEND} virtual/pkgconfig"
