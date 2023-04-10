# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )

# python-any-r1 required for a script in
# backends/pixma/scripts/
inherit autotools flag-o-matic optfeature python-any-r1 systemd udev user

# gphoto and v4l are handled by their usual USE flags.
# The pint backend was disabled because I could not get it to compile.
IUSE_SANE_BACKENDS=(
	abaton
	agfafocus
	apple
	artec
	artec_eplus48u
	as6e
	avision
	bh
	canon
	canon630u
	canon_dr
	canon_lide70
	canon_pp
	cardscan
	coolscan
	coolscan2
	coolscan3
	dc210
	dc240
	dc25
	dell1600n_net
	dmc
	epjitsu
	epson
	epson2
	epsonds
	escl
	fujitsu
	genesys
	gt68xx
	hp
	hp3500
	hp3900
	hp4200
	hp5400
	hp5590
	hpljm1005
	hpsj5s
	hs2p
	ibm
	kodak
	kodakaio
	kvs1025
	kvs20xx
	kvs40xx
	leo
	lexmark
	ma1509
	magicolor
	matsushita
	microtek
	microtek2
	mustek
	mustek_pp
	mustek_usb
	mustek_usb2
	nec
	net
	niash
	p5
	pie
	pieusb
	pixma
	plustek
	plustek_pp
	pnm
	qcam
	ricoh
	ricoh2
	rts8891
	s9036
	sceptre
	sharp
	sm3600
	sm3840
	snapscan
	sp15c
	st400
	stv680
	tamarack
	teco1
	teco2
	teco3
	test
	u12
	umax
	umax1220u
	umax_pp
	xerox_mfp
)

IUSE="gphoto2 nls snmp systemd threads +usb v4l xinetd +zeroconf"

for GBACKEND in ${IUSE_SANE_BACKENDS[@]}; do
	case ${GBACKEND} in
	# Disable backends that require parallel ports as no one has those anymore.
	canon_pp|hpsj5s|mustek_pp|\
	pnm|mustek_usb2|kvs40xx)
		IUSE+=" sane_backends_${GBACKEND}"
		;;
	*)
		IUSE+=" +sane_backends_${GBACKEND}"
	esac
done

REQUIRED_USE="
	sane_backends_escl? ( zeroconf )
	sane_backends_kvs40xx? ( threads )
	sane_backends_mustek_usb2? ( threads )
"

DESCRIPTION="Scanner Access Now Easy - Backends"
HOMEPAGE="http://www.sane-project.org/"
SRC_URI="https://gitlab.com/sane-project/backends/uploads/7d30fab4e115029d91027b6a58d64b43/${P}.tar.gz"

LICENSE="GPL-2 public-domain"
SLOT="0"
KEYWORDS="*"

# For pixma: see https://gitlab.com/sane-project/backends/-/releases/1.0.28#build
RDEPEND="
	gphoto2? (
		>=media-libs/libgphoto2-2.5.3.1:=
		media-libs/libjpeg-turbo:=
	)
	sane_backends_canon_pp? ( >=sys-libs/libieee1284-0.2.11-r3 )
	sane_backends_dc210? ( media-libs/libjpeg-turbo:= )
	sane_backends_dc240? ( media-libs/libjpeg-turbo:= )
	sane_backends_dell1600n_net? (
		>=media-libs/tiff-3.9.7-r1:0=
		media-libs/libjpeg-turbo:=
	)
	sane_backends_escl? (
		app-text/poppler[cairo]
		|| (
			net-dns/avahi[dbus]
			net-dns/avahi[gtk]
		)
		net-dns/avahi
		net-misc/curl
	)
	sane_backends_hpsj5s? ( >=sys-libs/libieee1284-0.2.11-r3 )
	sane_backends_mustek_pp? ( >=sys-libs/libieee1284-0.2.11-r3 )
	sane_backends_pixma? ( media-libs/libjpeg-turbo:= )
	snmp? ( net-analyzer/net-snmp:0= )
	usb? ( >=virtual/libusb-1-r1:1= )
	v4l? ( >=media-libs/libv4l-0.9.5 )
	xinetd? ( sys-apps/xinetd )
	zeroconf? ( >=net-dns/avahi-0.6.31-r2 )
"

DEPEND="${RDEPEND}
	dev-libs/libxml2
	v4l? ( sys-kernel/linux-headers )
"
BDEPEND="
	${PYTHON_DEPS}
	sys-devel/autoconf-archive
	sys-devel/gettext
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/${PN}-1.0.24-saned_pidfile_location.patch
	"${FILESDIR}"/${PN}-1.0.27-disable-usb-tests.patch
	"${FILESDIR}"/${PN}-1.0.30-add_hpaio_epkowa_dll.conf.patch
	# https://gitlab.com/sane-project/backends/-/merge_requests/688
	"${FILESDIR}"/${PN}-1.1.1-genesys-gl845-crash.patch
	"${FILESDIR}"/${P}-gcc12-tests.patch
	"${FILESDIR}"/${PN}-1.1.1-configure-clang16.patch
	"${FILESDIR}"/${P}-musl.patch
)

src_prepare() {
	default

	# Patch out the git reference so we can run eautoreconf
	sed \
		-e "s/m4_esyscmd_s(\[git describe --dirty\])/${PV}/" \
		-e '/^AM_MAINTAINER_MODE/d' \
		-i configure.ac || die
	eautoreconf

	# Fix for "make check".  Upstream sometimes forgets to update this.
	local ver=$(./configure --version | awk '{print $NF; exit 0}')
	sed -i \
		-e "/by sane-desc 3.5 from sane-backends/s:sane-backends .*:sane-backends ${ver}:" \
		testsuite/tools/data/html* || die

	# don't bleed user LDFLAGS into pkgconfig files
	sed 's|@LDFLAGS@ ||' -i tools/*.pc.in || die
}

src_configure() {
	# From Fedora
	append-flags -fno-strict-aliasing

	# the blank is intended - an empty string would result in building ALL backends.
	local lbackends=" "

	use gphoto2 && lbackends="gphoto2"
	use v4l && lbackends+=" v4l"
	use sane_backends_escl && lbackends+=" escl"
	local backend
	for backend in ${IUSE_SANE_BACKENDS[@]} ; do
		if use "sane_backends_${backend}" && [[ "${backend}" != pnm ]] && [[ "${backend}" != escl ]] ; then
			lbackends+=" ${backend}"
		fi
	done

	local myconf=(
		$(use_with usb)
		$(use_with snmp)

		$(use_with sane_backends_escl poppler-glib)
		# you can only enable this backend, not disable it...
		$(usex sane_backends_pnm --enable-pnm-backend '')
		$(usex sane_backends_mustek_pp --enable-parport-directio '')
	)

	if ! { use sane_backends_canon_pp || use sane_backends_hpsj5s || use sane_backends_mustek_pp ; } ; then
		myconf+=( sane_cv_use_libieee1284=no )
	fi

	# relative path must be used for tests to work properly
	# All distributions pass --disable-locking because /var/lock/sane/ would be a world-writable directory
	# that break in many ways, bug #636202, #668232, #668350
	# People can refer to the "Programmer's Documentation" at http://www.sane-project.org/docs.html
	myconf+=(
		--enable-ipv6
		--disable-locking
		$(use_enable nls)
		$(use_with gphoto2)
		$(use_with systemd)
		$(use_with v4l)
		$(use_enable threads pthread)
		$(use_with zeroconf avahi)
	)

	ECONF_SOURCE="${S}" \
	SANEI_JPEG="sanei_jpeg.o" SANEI_JPEG_LO="sanei_jpeg.lo" \
	BACKENDS="${lbackends}" \
	econf "${myconf[@]}"
}

src_compile() {
	emake VARTEXFONTS="${T}/fonts"

	if use usb ; then
		sed -i -e '/^$/d' \
			tools/hotplug/libsane.usermap || die
	fi
}

src_install() {
	emake INSTALL_LOCKPATH="" DESTDIR="${D}" install \
		docdir="${EPREFIX}"/usr/share/doc/${PF}

	dodir /etc/env.d

	if use systemd ; then
		systemd_newunit "${FILESDIR}"/saned_at.service-r1 "saned@.service"
		systemd_newunit "${FILESDIR}"/saned.socket saned.socket
	fi

	if use usb ; then
		exeinto /etc/hotplug/usb
		doexe tools/hotplug/libusbscanner
		newdoc tools/hotplug/README README.hotplug
	fi

	dodoc NEWS AUTHORS PROBLEMS README README.linux
	find "${ED}" -name '*.la' -delete || die

	if use xinetd ; then
		insinto /etc/xinetd.d
		doins "${FILESDIR}"/saned
	fi

	newinitd "${FILESDIR}"/saned.initd saned
	newconfd "${FILESDIR}"/saned.confd saned
}

pkg_setup() {
	enewgroup scanner 332 || die "problem creating 'scanner' group"
	enewuser saned 409 -1 /dev/null scanner || die "problem adding 'saned' user"
}

pkg_postrm() {
	udev_reload
}

pkg_postinst() {
	udev_reload

	optfeature "Network scanner backend" media-gfx/sane-airscan
	optfeature "Epson-specific backend" media-gfx/iscan
	optfeature "HP-specific backend" net-print/hplip

	if use xinetd ; then
		elog "If you want remote clients to connect, edit"
		elog "/etc/sane.d/saned.conf and /etc/hosts.allow"
	fi
}
