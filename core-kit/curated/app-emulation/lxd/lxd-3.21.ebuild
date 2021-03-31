# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Fast, dense and secure container management"
HOMEPAGE="https://linuxcontainers.org/lxd/introduction/"

LICENSE="Apache-2.0 BSD BSD-2 LGPL-3 MIT MPL-2.0"
SLOT="0"
KEYWORDS="*"

IUSE="apparmor +ipv6 +dnsmasq nls"

inherit autotools bash-completion-r1 golang-base linux-info user

SRC_URI="https://linuxcontainers.org/downloads/${PN}/${P}.tar.gz"

COMMON_DEPEND="
	>=sys-libs/libseccomp-2.4.2
	dev-libs/libuv
	>=app-emulation/lxc-2.0.7[seccomp]
"

DEPEND="
	$COMMON_DEPEND
	dev-lang/tcl
	>=dev-lang/go-1.9.4
	dev-libs/protobuf
	nls? ( sys-devel/gettext )
"

# Note: would make sense to add a PDEPEND for apparmor-utils to sys-apps/apparmor.

RDEPEND="
	$COMMON_DEPEND
	apparmor? (
		sys-apps/apparmor
		sys-apps/apparmor-utils
	)
	app-arch/xz-utils
	dev-libs/lzo
	dev-util/xdelta:3
	dnsmasq? (
		net-dns/dnsmasq[dhcp,ipv6?]
	)
	net-firewall/ebtables
	net-firewall/iptables[ipv6?]
	net-libs/libnfnetlink
	net-libs/libnsl:0=
	net-misc/rsync[xattr]
	sys-apps/iproute2[ipv6?]
	sys-fs/fuse:0=
	sys-fs/lxcfs
	sys-fs/squashfs-tools
	virtual/acl
"

CONFIG_CHECK="
	~BRIDGE
	~DUMMY
	~IP6_NF_NAT
	~IP6_NF_TARGET_MASQUERADE
	~IPV6
	~IP_NF_NAT
	~IP_NF_TARGET_MASQUERADE
	~MACVLAN
	~NETFILTER_XT_MATCH_COMMENT
	~NET_IPGRE
	~NET_IPGRE_DEMUX
	~NET_IPIP
	~NF_NAT_MASQUERADE_IPV4
	~NF_NAT_MASQUERADE_IPV6
	~VXLAN
"

ERROR_BRIDGE="BRIDGE: needed for network commands"
ERROR_DUMMY="DUMMY: needed for network commands"
ERROR_IP6_NF_NAT="IP6_NF_NAT: needed for network commands"
ERROR_IP6_NF_TARGET_MASQUERADE="IP6_NF_TARGET_MASQUERADE: needed for network commands"
ERROR_IPV6="IPV6: needed for network commands"
ERROR_IP_NF_NAT="IP_NF_NAT: needed for network commands"
ERROR_IP_NF_TARGET_MASQUERADE="IP_NF_TARGET_MASQUERADE: needed for network commands"
ERROR_MACVLAN="MACVLAN: needed for network commands"
ERROR_NETFILTER_XT_MATCH_COMMENT="NETFILTER_XT_MATCH_COMMENT: needed for network commands"
ERROR_NET_IPGRE="NET_IPGRE: needed for network commands"
ERROR_NET_IPGRE_DEMUX="NET_IPGRE_DEMUX: needed for network commands"
ERROR_NET_IPIP="NET_IPIP: needed for network commands"
ERROR_NF_NAT_MASQUERADE_IPV4="NF_NAT_MASQUERADE_IPV4: needed for network commands"
ERROR_NF_NAT_MASQUERADE_IPV6="NF_NAT_MASQUERADE_IPV6: needed for network commands"
ERROR_VXLAN="VXLAN: needed for network commands"

EGO_PN="github.com/lxc/lxd"
S=${WORKDIR}/go/src/github.com/lxc/lxd

pkg_setup() {
	export GOPATH="${WORKDIR}/go"
}

src_unpack() {
	unpack ${A}
	install -d ${GOPATH}

	# lxd ships a _dist directory which contains a full snapshot of all sources, organized in a GOPATH.
	# If we set up _dist correctly and use it to build, the Makefile doesn't use go get and git clone to
	# grab stuff over the network. But if we don't use _dist, the Makefile will try to grab stuff over
	# the network during the build. We don't want this, and this is a sign that we are not using _dist
	# correctly since we want to use the distributed sources, not live sources.

	# However, the lxd source tarball and its _dist subdirectory is set up kind of strangely.
	# Inside _dist, src/github.com/lxc/lxd is a symlink to the main source code directory. This is weird.
	# Let's configure a real GOPATH directory structure before starting the build. This makes the build
	# more straightforward and hopefully more maintainable and easier to troubleshoot.

	rm ${WORKDIR}/${P}/_dist/src/github.com/lxc/lxd
	mv ${WORKDIR}/${P}/_dist/* ${GOPATH}/
	mv ${WORKDIR}/${P} ${S}
}

src_prepare() {
	eapply_user
	( cd ${WORKDIR}; cat ${FILESDIR}/zeropad.diff | patch -p0 || die ) || die "zeropad patch fail"
	# We put the libraries that lxd uses in /usr/lib/lxd, since the sqlite library conflicts with the
	# official one in Funtoo. LDFLAGS are tweaked during build to allow the binaries to find the lxd
	# versions of the libraries even though they aren't in the official system library path.
	cd ${GOPATH} && eapply "${FILESDIR}/${PV}/disable-raft-zfs-test.patch"


	einfo "Tweaking Makefile to put libraries in /usr/lib/lxd ..."
	sed -i \
		-e "s:\./configure:./configure --prefix=/usr --libdir=${EPREFIX}/usr/lib/lxd:g" \
		-e "s:make:make ${MAKEOPTS}:g" \
		${S}/Makefile || die
	einfo "Fixing libco library install path to be /usr/lib/lxd ..."
}

src_configure() {
	return
}

src_compile() {
	emake deps
	export CGO_CFLAGS="${CGO_CFLAGS} -I${GOPATH}/deps/sqlite/ -I${GOPATH}/deps/libco/ -I${GOPATH}/deps/raft/include/ -I${GOPATH}/deps/dqlite/include/"
	# Find libs in /usr/lib/lxd:
	export CGO_LDFLAGS="-Wl,-rpath,${EPREFIX}/usr/lib/lxd"
	export CGO_LDFLAGS="${CGO_LDFLAGS} -L${GOPATH}/deps/sqlite/.libs/ -L${GOPATH}/deps/libco/ -L${GOPATH}/deps/raft/.libs -L${GOPATH}/deps/dqlite/.libs/"
	export LD_LIBRARY_PATH="${GOPATH}/deps/sqlite/.libs/:${GOPATH}/deps/libco/:${GOPATH}/deps/raft/.libs/:${GOPATH}/deps/dqlite/.libs/"
	emake
	use nls && emake build-mo
}

src_install() {
	local bindir="${WORKDIR}/go/bin"

	cd "${GOPATH}/deps/sqlite" || die "Can't cd to sqlite dir"
	emake DESTDIR="${D}" libdir=/usr/lib/lxd install

	cd "${GOPATH}/deps/raft" || die "Can't cd to raft dir"
	emake DESTDIR="${D}" libdir=/usr/lib/lxd install

	cd "${GOPATH}/deps/libco" || die "Can't cd to libco dir"
	emake DESTDIR="${D}" LIBDIR=lib/lxd install

	cd "${GOPATH}/deps/dqlite" || die "Can't cd to dqlite dir"
	emake DESTDIR="${D}" libdir=/usr/lib/lxd install

	# We only need the shared libraries, and nothing else will be linking against these:

	rm -rf ${D}/usr/lib/lxd/pkgconfig
	rm -rf ${D}/usr/lib/lxd/*.a

	# Must only install libs
	rm "${D}/usr/bin/sqlite3" || die "Can't remove custom sqlite3 binary"
	rm -r "${D}/usr/include" || die "Can't remove include directory"

	cd "${S}" || die "Can't cd to \${S}"
	dosbin ${bindir}/lxd

	dobin ${bindir}/*

	if use nls; then
		domo po/*.mo
	fi

	newinitd "${FILESDIR}"/${PV}/lxd.initd lxd || die
	newconfd "${FILESDIR}"/${PV}/lxd.confd lxd || die
	newbashcomp scripts/bash/lxd-client lxc
	dodoc AUTHORS doc/*
}

pkg_postinst() {
	elog
	elog "Consult https://www.funtoo.org/LXD for more information,"
	elog "including a Quick Start."

	# The control socket will be owned by (and writeable by) this group.
	enewgroup lxd

	elog
	elog "Though not strictly required, some features are enabled at run-time"
	elog "when the relevant helper programs are detected:"
	elog "- sys-fs/btrfs-progs"
	elog "- sys-fs/lvm2"
	elog "- sys-fs/zfs"
	elog "- sys-process/criu"
	elog
	elog "Be sure to add your local user to the lxd group."
	elog
	elog "Networks with bridge.mode=fan are unsupported due to requiring"
	elog "a patched kernel and iproute2."
}
