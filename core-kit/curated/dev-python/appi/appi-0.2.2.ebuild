# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{4..8} )

inherit distutils-r1

APPI_VERSION=${PV%.*}
APPI_RELEASE=${PV##*.}

SRC_URI="https://github.com/funtoo/appi/archive/v${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="*"

DESCRIPTION="Another Portage Python Interface"
HOMEPAGE="https://gitlab.com/apinsard/appi/"

LICENSE="GPL-2"
SLOT="0/${APPI_VERSION}"

RDEPEND="sys-apps/portage"
DEPEND="${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"
