# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{4,5,6,7} )

inherit distutils-r1

DESCRIPTION="Python bindings for LXC"
HOMEPAGE="https://linuxcontainers.org/lxc/"
SRC_URI="https://linuxcontainers.org/downloads/lxc/${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND=">=app-emulation/lxc-3.0"

DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]"
