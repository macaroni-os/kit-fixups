
EAPI=7

DESCRIPTION="Gnucash Github"
HOMEPAGE="https://github.com/gnucash/gnucash"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="dev-cpp/libxmlpp:2.6"
RDEPEND="${DEPEND}"

GITHUB_REPO="gnucash"
GITHUB_USER="gnucash"
GITHUB_TAG="984fe65822b2a9631889727638380e30896558d8"
SRC_URI="https://github.com/${GITHUB_USER}/${GITHUB_REPO}/tarball/${GITHUB_TAG}/ -> ${PN}-${GITHUB_TAG}.tar.gz"

src_unpack() {
  unpack ${A}
  mv "${WORKDIR}/${GITHUB_USER}-${GITHUB_REPO}"-??????? "${S}" || die
}
