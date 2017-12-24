# Distributed under the terms of the GNU General Public License v2

EAPI=5
PYTHON_COMPAT=(python3_{4,5,6} )

inherit distutils-r1

DESCRIPTION="Python bindings for RRDtool with a native C extension"
HOMEPAGE="https://github.com/commx/python-rrdtool"
SRC_URI="https://github.com/commx/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64"

IUSE="graph"

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="
	>=net-analyzer/rrdtool-1.5.5[-python]
	graph? ( >=net-analyzer/rrdtool-1.5.5[graph] )
"

src_prepare() {
	if use graph; then
		epatch "${FILESDIR}"/have_graph.patch
	fi
}

