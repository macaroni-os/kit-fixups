# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils multilib

DESCRIPTION="A minimalistic plugin API for video effects"
HOMEPAGE="https://www.dyne.org/software/frei0r/"
SRC_URI="https://files.dyne.org/frei0r/releases/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="doc -facedetect +scale0tilt"

RDEPEND="x11-libs/cairo
	facedetect? ( >=media-libs/opencv-4:= )
	scale0tilt? ( >=media-libs/gavl-1.2.0 )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? ( app-doc/doxygen )"

GITHUB_REPO="frei0r"
GITHUB_USER="dyne"
GITHUB_TAG="bd36127"
SRC_URI="https://www.github.com/${GITHUB_USER}/${GITHUB_REPO}/tarball/${GITHUB_TAG} -> ${PN}-${GITHUB_TAG}.tar.gz"

DOCS=( AUTHORS README.md NEWS ChangeLog )

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}/${GITHUB_USER}-${GITHUB_REPO}"-??????? "${S}" || die
}

src_prepare() {
	epatch ${FILESDIR}/frei0r-plugins-1.6.1-revert-opencv-cmake-changes.patch || die
	cmake-utils_src_prepare

	local f=CMakeLists.txt

	sed -i \
		-e '/set(CMAKE_C_FLAGS/d' \
		-e "/LIBDIR.*frei0r-1/s:lib:$(get_libdir):" \
		${f} || die

	# https://bugs.gentoo.org/418243
	sed -i \
		-e '/set.*CMAKE_C_FLAGS/s:"): ${CMAKE_C_FLAGS}&:' \
		src/filter/*/${f} || die
}

src_configure() {
	local mycmakeargs=(
		-DWITHOUT_OPENCV=$(usex !facedetect)
		-DWITHOUT_GAVL=$(usex !scale0tilt)
	)

	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile

	if use doc; then
		pushd doc
		doxygen || die
		popd
	fi
}

src_install() {
	cmake-utils_src_install

	use doc && dodoc -r doc/html
}
