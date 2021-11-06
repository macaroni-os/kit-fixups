# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PV=${PV/_/-}
MY_P=${PN}-${MY_PV}

inherit autotools

DESCRIPTION="Portable and efficient API to determine the call-chain of a program"
HOMEPAGE="https://github.com/libunwind/libunwind"

LICENSE="MIT"
SLOT="0"
KEYWORDS="next"
IUSE=""
S="${WORKDIR}/${MY_P}"

DEPEND="=sys-libs/zlib-1.2*"
RDEPEND="${DEPEND}"

SRC_URI="https://github.com/libunwind/libunwind/releases/download/v1.6.0-rc2/libunwind-1.6.0-rc2.tar.gz"

src_prepare(){
	default
	eautoreconf
}
