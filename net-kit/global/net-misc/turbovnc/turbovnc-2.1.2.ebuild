# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit java-pkg-2 multilib

DESCRIPTION="Advanced and fast VNC client/server with encryption and VirtualGL support."
HOMEPAGE="https://www.turbovnc.org"
SRC_URI="mirror://sourceforge/project/turbovnc/2.1.2/turbovnc-2.1.2.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

COMMON_DEPEND="media-libs/libjpeg-turbo[java]
	dev-libs/openssl
	sys-libs/pam
	x11-base/xorg-server"
DEPEND="${COMMON_DEPEND}
	dev-util/cmake
	>=virtual/jdk-1.6"
RDEPEND="${COMMON_DEPEND} 
	>=virtual/jre-1.6
	!net-misc/tigervnc"

src_prepare() {
	# delete -O3 hack in source:
	sed -i -e '/^if(CMAKE_COMPILER_IS_GNUCC/,/^endif()/d' unix/CMakeLists.txt || die
	eapply_user
}

src_configure() {
	cmake -G"Unix Makefiles" \
		-DTJPEG_LIBRARY="-L/usr/lib -lturbojpeg" \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DTJPEG_JAR="/usr/share/libjpeg-turbo/lib/turbojpeg.jar" \
		-DTJPEG_JNILIBRARY="/usr/$(get_libdir)/libturbojpeg.so" \
		-DCMAKE_INSTALL_DOCDIR="/usr/share/doc/${P}" 
}

src_compile() {
	emake
}

# TODO: add desktop entry like in tigervnc, maybe add initscript...

src_install() {
	make DESTDIR=${D} install || die
	rm ${D}/usr/share/man/man1/Xserver.1 || die
	rm -rf ${D}/etc/init.d ${D}/etc/sysconfig || die
}
