# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION=""
HOMEPAGE=""

DESCRIPTION="Super Audio CD ripping and management tools, including sacd-extract tool."
HOMEPAGE="https://github.com/hank/sacd-ripper"
LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
RESTRICT="mirror"
GITHUB_REPO="sacd-ripper"
GITHUB_USER="hank"
GITHUB_TAG="86fe4ce1ae5971b1e7b5f374eb0cfe0174ba335d"
SRC_URI="https://www.github.com/${GITHUB_USER}/${GITHUB_REPO}/tarball/${GITHUB_TAG} -> ${PN}-${GITHUB_TAG}.tar.gz"

LICENSE="GPLv2+"
IUSE=""

DEPEND="dev-util/cmake"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}/${GITHUB_USER}-sacd-ripper"-??????? "${S}" || die
}

src_prepare() {
	# let's get this sucker to compile, FILE_OFFSET_BITS and the next line to get rid of a bad warning:
	sed -i -e 's/-liconv/-D_FILE_OFFSET_BITS=64/g' tools/sacd_extract/CMakeLists.txt || die
	sed -i -e 's/ftello64/ftello/g' libs/libsacd/dsdiff.c || die
}

src_configure() {
	# let's not do the standard configure thing...
	return
}

src_compile() {
	cd ${S}/tools/sacd_extract
	cmake . || die
	emake || die
}

src_install() {
	# let's normalize the name, get rid of the underscore:
	newbin ${S}/tools/sacd_extract/sacd_extract sacd-extract
}
