# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Thin wrapper over POSIX syscalls"
HOMEPAGE="https://github.com/sionescu/libfixposix"
SRC_URI="https://github.com/sionescu/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSL-1.1"
SLOT="0"
KEYWORDS="*"

RDEPEND=""
DEPEND=""

src_prepare(){
	einfo "Generating autotools files..."
	autoreconf -i -f
	default
}
