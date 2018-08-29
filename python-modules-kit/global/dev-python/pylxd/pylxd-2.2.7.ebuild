# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{4,5,6} )

inherit distutils-r1

DESCRIPTION="A Python library for interacting with the LXD REST API"
HOMEPAGE="https://github.com/lxc/pylxd"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"

DEPEND="
        dev-python/setuptools[${PYTHON_USEDEP}]
        >=dev-python/pbr-1.8[${PYTHON_USEDEP}]
        >=dev-python/requests-2.12[${PYTHON_USEDEP}]
        >=dev-python/requests-toolbelt-0.8.0[${PYTHON_USEDEP}]
        >=dev-python/requests-unixsocket-0.1.5[${PYTHON_USEDEP}]
        >=dev-python/python-dateutil-2.4.2[${PYTHON_USEDEP}]
        >=dev-python/six-1.9.0[${PYTHON_USEDEP}]
        >=dev-python/ws4py-0.4.2[${PYTHON_USEDEP}]
        >=dev-python/cryptography-1.7.1[${PYTHON_USEDEP}]
"
