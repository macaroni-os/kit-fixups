# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{4,5,6,7} )
PYTHON_REQ_USE="sqlite"
# Required for python_fix_shebang:
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 gnome2-utils

DESCRIPTION="A free cross-platform podcast aggregator"
HOMEPAGE="http://gpodder.org/"
SRC_URI="https://github.com/gpodder/gpodder/archive/3.10.5.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE="+dbus bluetooth ipod kernel_linux mtp test"

COMMON_DEPEND="
	>=dev-python/feedparser-5.1.2[${PYTHON_USEDEP}]
	dev-python/html5lib[${PYTHON_USEDEP}]
	>=dev-python/mygpoclient-1.8[${PYTHON_USEDEP}]
	dev-python/pycairo[xcb,${PYTHON_USEDEP}]
	dev-python/pygobject[${PYTHON_USEDEP}]
	dev-python/podcastparser[${PYTHON_USEDEP}]
	dbus? ( dev-python/dbus-python[${PYTHON_USEDEP}] )
	bluetooth? ( net-wireless/bluez )
	ipod? ( media-libs/libgpod[python] )
	mtp? ( >=media-libs/libmtp-1.0.0:= )
"
RDEPEND="${COMMON_DEPEND}
	kernel_linux? ( sys-apps/iproute2 )
"
DEPEND="${COMMON_DEPEND}
	dev-util/desktop-file-utils
	dev-util/intltool
	sys-apps/help2man
	test? (
		dev-python/minimock[${PYTHON_USEDEP}]
		dev-python/coverage[${PYTHON_USEDEP}]
	)
"
src_prepare() {
	default
	sed -i -e '/setup.py.*install/d' makefile || die
	# Fix for "AttributeError: 'gPodder' object has no attribute 'toolbar'":
	python_fix_shebang .
}

src_install() {
	emake DESTDIR="${D}" install
	distutils-r1_src_install
}

src_test() {
	emake releasetest
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}
