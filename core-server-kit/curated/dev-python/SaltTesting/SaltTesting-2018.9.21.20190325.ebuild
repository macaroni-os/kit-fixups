# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 python3_{6,7} )

inherit eutils distutils-r1

DESCRIPTION="Required testing tools needed in the several Salt Stack projects"
HOMEPAGE="https://saltstack.com/community/"

LICENSE="Apache-2.0"
SLOT="0"

GITHUB_REPO="salt-testing"
GITHUB_USER="saltstack"
GITHUB_TAG="70145afcc5eb96bf15b22631dcb364caf19b1fc1"
SRC_URI="https://www.github.com/${GITHUB_USER}/${GITHUB_REPO}/tarball/${GITHUB_TAG} -> ${PN}-${GITHUB_TAG}.tar.gz"
KEYWORDS="*"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}/${GITHUB_USER}-${GITHUB_REPO}"-??????? "${S}" || die
}

RDEPEND="
	dev-python/psutil[${PYTHON_USEDEP}]
	>=dev-python/requests-2.4.2[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]"
