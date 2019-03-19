# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools

DESCRIPTION="LADSPA plugins by swh, used by shotcut."
HOMEPAGE="https://github.com/swh/ladspa"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

COMMON_DEPEND="=sci-libs/fftw-3*"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND} dev-perl/List-MoreUtils"

GITHUB_REPO="ladspa"
GITHUB_USER="swh"
GITHUB_TAG="1f4bd122323d66e76a360efc494c1a146dcf301d"
SRC_URI="https://www.github.com/${GITHUB_USER}/${GITHUB_REPO}/tarball/${GITHUB_TAG} -> ${PN}-${GITHUB_TAG}.tar.gz"

DOCS=( AUTHORS README NEWS ChangeLog )

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}/${GITHUB_USER}-${GITHUB_REPO}"-??????? "${S}" || die
}

src_prepare() {
	eautoreconf
	export CFLAGS="${CFLAGS} -fPIC"
	default
}

src_install() {
	make DESTDIR="$D" install || die
}

