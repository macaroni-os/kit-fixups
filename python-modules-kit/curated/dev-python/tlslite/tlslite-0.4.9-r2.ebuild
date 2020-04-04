# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )

inherit distutils-r1 eutils

# IMPORTANT: At least as of 12 Jul 2019, tlslite is unmaintained and is incompatible with python3.5+
# (It uses 'async' as a named parameter of a function, and with the addition of 'async' as a reserved
# keyword this is not allowed.

# Therefore, if your app needs tlslite, first check to see if tlslite is still unmaintained
# (Look here: https://github.com/trevp/tlslite) and if so, you should look for an updated version of
# your tlslite-dependent app that no longer uses tlslite but uses something else. If your python
# app is actively maintained, it is almost certainly no longer dependent on tlslite.

# -Daniel Robbins

DESCRIPTION="TLS Lite is a free python library that implements SSL 3.0 and TLS 1.0/1.1"
HOMEPAGE="http://trevp.net/tlslite/ https://pypi.org/project/tlslite/ https://github.com/trevp/tlslite"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD public-domain"
SLOT="0"
KEYWORDS="amd64 ppc x86"
#Refrain for now setting IUSE test and deps of test given test restricted.
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

RESTRICT="test"

# Tests still hang
python_test() {
	cd tests || die
	"${PYTHON}" "${S}"/tests/tlstest.py client localhost:4443 . || die
	"${PYTHON}" "${S}"/tests/tlstest.py server localhost:4442 . || die
}

pkg_postinst() {
	optfeature "GMP support" dev-python/gmpy
}
