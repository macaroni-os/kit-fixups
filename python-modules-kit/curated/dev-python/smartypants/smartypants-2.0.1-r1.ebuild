# Copyright 2012-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2+ )

inherit distutils-r1

DESCRIPTION="SmartyPants: a smart-quotes plugin."
HOMEPAGE="https://bitbucket.org/livibetter/smartypants.py
https://pypi.python.org/pypi/smartypants"
SRC_URI="https://github.com/leohemsted/${PN}.py/archive/v${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~amd64 ~x86"

S="${WORKDIR}/${PN}.py-${PV}"

LICENSE="BSD"
SLOT="0"
IUSE=""

DEPEND=""
RDEPEND=""

DOCS=( README.rst COPYING CHANGES.rst )

