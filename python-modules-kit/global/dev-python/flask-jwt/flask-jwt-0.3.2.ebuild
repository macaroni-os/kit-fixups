# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python2_7 python3_{4,5,6} pypy )

inherit distutils-r1

MY_PN="Flask-JWT"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Flask-JWT is a Flask extension that adds basic Json Web Token features to any application"
HOMEPAGE="https://pythonhosted.org/Flask-JWT"
SRC_URI="mirror://pypi/${MY_P:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="test"

RDEPEND="dev-python/flask[${PYTHON_USEDEP}]
		dev-python/pyjwt[${PYTHON_USEDEP}]"
DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]
	test? ( ${RDEPEND} )"

S="${WORKDIR}/${MY_P}"

python_prepare_all() {
	# relax PyJWT dependency.
	sed -i 's/,<1.5.0//' requirements.txt || die "sed failed"
	distutils-r1_python_prepare_all
}
