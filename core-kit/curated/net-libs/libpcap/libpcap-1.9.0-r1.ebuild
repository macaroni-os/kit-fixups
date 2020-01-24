# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit autotools ltprune

DESCRIPTION="A system-independent library for user-level network packet capture"
HOMEPAGE="
	http://www.tcpdump.org/
	https://github.com/the-tcpdump-group/libpcap
"
SRC_URI="
	https://github.com/the-tcpdump-group/${PN}/archive/${P/_}.tar.gz
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="bluetooth dbus netlink static-libs usb"

RDEPEND="
	bluetooth? ( net-wireless/bluez:= )
	dbus? ( sys-apps/dbus )
	netlink? ( dev-libs/libnl:3 )
"
DEPEND="
	${RDEPEND}
	sys-devel/flex
	virtual/yacc
	dbus? ( virtual/pkgconfig )
"

S=${WORKDIR}/${PN}-${P/_}

PATCHES=(
	"${FILESDIR}"/${PN}-1.6.1-prefix-solaris.patch
	"${FILESDIR}"/${PN}-1.8.1-darwin.patch
	"${FILESDIR}"/${PN}-1.8.1-usbmon.patch
)

src_prepare() {
	default
	echo ${PV} > VERSION || die
	eautoreconf
}

src_configure() {
	ECONF_SOURCE="${S}" \
	econf \
		$(use_enable bluetooth) \
		$(use_enable usb) \
		$(use_enable dbus) \
		$(use_with netlink libnl) \
		--enable-ipv6
}

src_compile() {
	emake all shared
}

src_install() {
	default
	dodoc CREDITS CHANGES VERSION TODO README.* doc/README.*
	# remove static libraries (--disable-static does not work)
	if ! use static-libs; then
		find "${ED}" -name '*.a' -exec rm {} + || die
	fi
	prune_libtool_files

	# We need this to build pppd on G/FBSD systems
	if [[ "${USERLAND}" == "BSD" ]]; then
		insinto /usr/include
		doins pcap-int.h portability.h
	fi
}
