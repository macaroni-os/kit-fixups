# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python{2_7,3_4,3_5,3_6} )

inherit python-r1
COMMIT_ID="d9499b57c1291764debcc2be299c12d7b3dce7d3"
DESCRIPTION="Utilities for using XStatic in Tornado applications"
HOMEPAGE="https://github.com/takluyver/tornado_xstatic"
SRC_URI="https://github.com/takluyver/tornado_xstatic/archive/${COMMIT_ID}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="www-servers/tornado[${PYTHON_USEDEP}] ${PYTHON_DEPS}"
DEPEND=""
S=${WORKDIR}/tornado_xstatic-$COMMIT_ID

src_install() {
	# no setup.py. We will create a hack, so that's packages using setup.py can find tornado-xstatic in their reqs.
	touch "${T}/tornado_xstatic-${PV}.egg-info"
	python_foreach_impl python_domodule tornado_xstatic.py "${T}/tornado_xstatic-${PV}.egg-info"
}
