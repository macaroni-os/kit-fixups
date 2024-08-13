# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PYTHON_COMPAT=( python2+ )

inherit desktop python-single-r1 scons-utils toolchain-funcs udev

DESCRIPTION="Driver for IEEE1394 (Firewire) audio interfaces"
HOMEPAGE="http://www.ffado.org"

SRC_URI="http://www.ffado.org/files/${P}.tgz"
KEYWORDS="*"

LICENSE="GPL-2 GPL-3"
SLOT="0"
IUSE="debug qt5 test-programs"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

BDEPEND="virtual/pkgconfig"

# Funtoo notes: libffado will use libxmlcpp-3 if available, and fall back to 2.
#               libxmlcpp-2 uses the deprecated C++ auto_ptr, so should be avoided.
#
#               The 0.9.0-r5 version of dbus-c++ has gcc-12 fixes which are needed
#               here.

COMMON_DEPEND="${PYTHON_DEPS}
	dev-cpp/libxmlpp:3.0
	>=dev-libs/dbus-c++-0.9.0-r5
	dev-libs/libconfig[cxx]
	media-libs/alsa-lib
	media-libs/libiec61883
	sys-apps/dbus
	sys-libs/libavc1394
	sys-libs/libraw1394
	qt5? (
		dev-python/dbus-python[${PYTHON_USEDEP}]
		dev-python/PyQt5[dbus,${PYTHON_USEDEP}]
		x11-misc/xdg-utils
	)"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"

myescons() {
	local myesconsargs=(
		PREFIX="${EPREFIX}/usr"
		LIBDIR="${EPREFIX}/usr/$(get_libdir)"
		MANDIR="${EPREFIX}/usr/share/man"
		UDEVDIR="$(get_udevdir)/rules.d"
		CUSTOM_ENV=true
		DETECT_USERSPACE_ENV=false
		DEBUG=$(usex debug)
		PYPKGDIR="$(python_get_sitedir)"
		# ENABLE_OPTIMIZATIONS detects cpu type and sets flags accordingly
		# -fomit-frame-pointer is added also which can cripple debugging.
		# we set flags from portage instead
		ENABLE_OPTIMIZATIONS=false
		ENABLE_SETBUFFERSIZE_API_VER=force
		BUILD_MIXER=$(usex qt5 true false)
		BUILD_TESTS=$(usex test-programs)
	)
	escons "${myesconsargs[@]}" "${@}"
}

src_prepare() {
	default

	# Bug #808853
	cp "${BROOT}"/usr/share/gnuconfig/config.guess admin/ || die "Failed to update config.guess"

	# Always use Qt5
	sed -i -e 's/try:/if False:/' -e 's/except.*/else:/' support/mixer-qt4/ffado/import_pyqt.py || die

	# Bugs #658052, #659226
	sed -i -e 's/^CacheDir/#CacheDir/' SConstruct || die
}

src_compile() {
	tc-export CC CXX
	myescons
}

src_install() {
	myescons DESTDIR="${D}" WILL_DEAL_WITH_XDG_MYSELF="True" install
	einstalldocs

	python_fix_shebang "${D}"
	python_optimize "${D}"

	if use qt5; then
		newicon "support/xdg/hi64-apps-ffado.png" "ffado.png"
		newmenu "support/xdg/ffado.org-ffadomixer.desktop" "ffado-mixer.desktop"
	fi
}

pkg_postinst() {
	udev_reload
}

pkg_postrm() {
	udev_reload
}
