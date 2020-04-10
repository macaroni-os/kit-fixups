# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{5,6} )

inherit distutils-r1

DESCRIPTION="Naming Convention checker for Python"
HOMEPAGE="https://github.com/PyCQA/pep8-naming"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

RDEPEND=">=dev-python/flake8-polyfill-1.0.2[${PYTHON_USEDEP}]
	<dev-python/flake8-polyfill-2.0.0"
DEPEND="${RDEPEND}"

DOCS="README.rst"
