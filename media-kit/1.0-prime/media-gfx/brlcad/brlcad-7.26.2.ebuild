# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit cmake-utils eutils flag-o-matic

DESCRIPTION="Constructive solid geometry modeling system"
HOMEPAGE="http://brlcad.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2 BSD"
SLOT="0"
KEYWORDS="~*"
IUSE="benchmarks debug doc examples opengl smp"

RESTRICT="mirror"

RDEPEND="
	dev-libs/expat
	media-libs/fontconfig
	media-libs/libpng
	media-libs/urt
	sys-libs/zlib
	>=sci-libs/tnt-3
	sci-libs/jama
	sys-libs/libtermcap-compat
	x11-libs/libdrm
	x11-libs/libXt
	x11-libs/libXi
	"

DEPEND="${RDEPEND}
	sys-devel/bison
	sys-devel/flex
	>=virtual/jdk-1.5
	doc? (
		dev-libs/libxslt
		app-doc/doxygen
	)"
BRLCAD_DIR="/opt/${PN}"

src_configure() {
	append-cflags "-w"
	if use debug; then
		CMAKE_BUILD_TYPE=Debug
		else
		CMAKE_BUILD_TYPE=Release
		fi
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${BRLCAD_DIR}"
		-DBRLCAD_ENABLE_STRICT=OFF
		-DBRLCAD-ENABLE_COMPILER_WARNINGS=OFF
		-DBRLCAD_FLAGS_OPTIMIZATION=OFF
		-DBRLCAD_BUILD_STATIC_LIBS=OFF 
		-DBRLCAD_ENABLE_X11=ON
		-DBRLCAD_BUNDLED_LIBS=ON
		)

			# use flag triggered options
	if use debug; then
		mycmakeargs+=( "-DCMAKE_BUILD_TYPE=Debug" )
	else
		mycmakeargs+=( "-DCMAKE_BUILD_TYPE=Release" )
	fi
	mycmakeargs+=(
		$(cmake-utils_use opengl BRLCAD_ENABLE_OPENGL)
#experimental RTGL support
#		$(cmake-utils_use opengl BRLCAD_ENABLE_RTGL)
		$(cmake-utils_use amd64 BRLCAD_ENABLE_64BIT)
		$(cmake-utils_use smp BRLCAD_ENABLE_SMP)
#experimental RTSERVER support
		$(cmake-utils_use examples BRLCAD_INSTALL_EXAMPLE_GEOMETRY)
		$(cmake-utils_use doc BRLCAD_EXTRADOCS)
		$(cmake-utils_use doc BRLCAD_EXTRADOCS_PDF)
		$(cmake-utils_use doc BRLCAD_EXTRADOCS_MAN)
		$(cmake-utils_use debug BRLCAD_ENABLE_VERBOSE_PROGRESS)
			)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
}

src_test() {
	cmake-utils_src_test
	if use benchmarks; then
		emake benchmark || die "emake benchmark failed"
	fi
}

src_install() {
	cmake-utils_src_install
	rm -f "${D}"usr/share/brlcad/{README,NEWS,AUTHORS,HACKING,INSTALL,COPYING}
	dodoc AUTHORS NEWS README HACKING TODO BUGS ChangeLog
	echo "PATH=\"${BRLCAD_DIR}/bin\"" >  99brlcad
	echo "MANPATH=\"${BRLCAD_DIR}/man\"" >> 99brlcad
	doenvd 99brlcad || die
	newicon misc/macosx/Resources/ReadMe.rtfd/brlcad_logo_tiny.png brlcad.png

	insinto /usr/share/applications
	doins ${FILESDIR}/${PN}.desktop

	dosym /opt/brlcad/bin/mged /usr/bin/mged
	dosym /opt/brlcad/bin/mged /usr/bin/brlcad
}
