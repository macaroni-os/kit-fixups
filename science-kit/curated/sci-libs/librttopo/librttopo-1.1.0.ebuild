# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="RT Topology Library"
HOMEPAGE="https://git.osgeo.org/gitea/rttopo/librttopo"
SRC_URI="https://git.osgeo.org/gitea/rttopo/${PN}/archive/${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="
	>=sci-libs/geos-3.5.0
"
RDEPEND="${DEPEND}"
BDEPEND=""

S="${WORKDIR}/${PN}"

src_prepare(){
	eautoreconf
	default
}

src_install(){
	default
	find "${D}" -name '*.la' -delete || die
}
