# Copyright 1999-2018 Gentoo Foundation

EAPI=6

PYTHON_COMPAT=( python3+ )

inherit autotools python-any-r1

DESCRIPTION="The GL Vendor-Neutral Dispatch library"
HOMEPAGE="https://github.com/NVIDIA/libglvnd"
EGIT_REPO_URI="${HOMEPAGE}.git"
SRC_URI="${HOMEPAGE}/releases/download/v${PV}/${P}.tar.gz"

KEYWORDS="*"
LICENSE="MIT"
SLOT="0"
IUSE="+asm +glx +gles +egl debug"

GITHUB_REPO="$PN"
GITHUB_USER="NVIDIA"
GITHUB_TAG="v${PV}"
SRC_URI="https://www.github.com/${GITHUB_USER}/${GITHUB_REPO}/tarball/${GITHUB_TAG} -> ${PN}-${GITHUB_TAG}.tar.gz"

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}/${GITHUB_USER}-${PN}"-??????? "${S}" || die
}

RDEPEND="
	x11-libs/libX11
	x11-proto/glproto
	x11-libs/libXext
	!media-libs/mesa-gl-headers
"

DEPEND="
	${PYTHON_DEPS}
	${RDEPEND}
"

RDEPEND="
	${RDEPEND}
	!media-libs/mesa[-glvnd(-)]
"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	ECONF_SOURCE=${S} econf $(usex debug "--enable-debug" "") $(usex asm "" "--disable-asm") $(usex glx "" "--disable-glx") $(usex gles "" "--disable-gles") $(usex egl "" "--disable-egl") --enable-headers
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
