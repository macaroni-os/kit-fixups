# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python3+ )

inherit distutils-r1

DESCRIPTION="Python bindings for x11-libs/xapps"
HOMEPAGE="https://github.com/linuxmint/python3-xapp"
SRC_URI="https://github.com/linuxmint/python3-xapp/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="x11-libs/xapps[introspection]"
RDEPEND="${DEPEND}
	dev-python/psutil[${PYTHON_USEDEP}]"

S="${WORKDIR}/python3-xapp-${PV}"
