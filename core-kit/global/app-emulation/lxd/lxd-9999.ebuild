# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Fast, dense and secure container management"
HOMEPAGE="https://linuxcontainers.org/lxd/introduction/"

LICENSE="Apache-2.0 BSD BSD-2 LGPL-3 MIT MPL-2.0"
SLOT="0"
KEYWORDS=""

IUSE="+daemon +ipv6 +dnsmasq nls test"

inherit autotools bash-completion-r1 linux-info systemd user

SRC_URI="https://linuxcontainers.org/downloads/${PN}/lxd-3.0.2.tar.gz"
S=${WORKDIR}/lxd-3.0.2
COMMON_DEPEND="
	dev-libs/libuv
"
DEPEND="
	$COMMON_DEPEND
	>=dev-lang/go-1.9.4
	dev-libs/protobuf
	dev-lang/tcl
	nls? ( sys-devel/gettext )
	test? (
		app-misc/jq
		net-misc/curl
		sys-devel/gettext
	)
"

RDEPEND="
	$COMMON_DEPEND
	daemon? (
		app-arch/xz-utils
		>=app-emulation/lxc-3.0.2[seccomp]
		dnsmasq? (
			net-dns/dnsmasq[dhcp,ipv6?]
		)
		net-misc/rsync[xattr]
		sys-apps/iproute2[ipv6?]
		sys-fs/squashfs-tools
		virtual/acl
		>=sys-fs/lxcfs-3.0.2
		sys-process/criu
	)
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

PATCHES=(
	"${FILESDIR}/ja-translation-newline.patch"  # https://github.com/lxc/lxd/pull/4572
	"${FILESDIR}/de-translation-newline.patch"
)

post_src_unpack() {
	export GOPATH="${S}/dist"
	rm -rf $GOPATH/src/* || die
	go get -d -v github.com/lxc/lxd/lxd || die
	cd ${S}/dist/src/github.com/lxc/lxd || die
}

src_configure() {
	export GOPATH="${S}/dist"
	cd ${S}/dist/src/github.com/lxc/lxd || die
	sed -i -e 's:./configure:./configure --prefix=/usr:g' Makefile || die
	make deps || die
}

src_compile() {
	export GOPATH="${S}/dist"
	export CGO_CFLAGS="-I${GOPATH}/deps/sqlite/ -I${GOPATH}/deps/dqlite/include/"
	export CGO_LDFLAGS="-L${GOPATH}/deps/sqlite/.libs/ -L${GOPATH}/deps/dqlite/.libs/"
	export LD_LIBRARY_PATH="${GOPATH}/deps/sqlite/.libs/:${GOPATH}/deps/dqlite/.libs/"
	cd ${S}/dist/src/github.com/lxc/lxd && make -j ${MAKEOPTS} || die
	if use nls; then
		cd ${S} && emake build-mo
	fi
}

src_test() {
	if use daemon; then
		make check || die
	else
		einfo "No tests to run for client-only builds"
	fi
}

src_install() {

	keepdir /var/lib/lxd


	local bindir="dist/bin"
	dobin ${bindir}/lxc
	if use daemon; then
	
		# User-callable wrapper for lxd that sets LD_LIBRARY_PATH correctly:
		newsbin ${FILESDIR}/lxd-wrapper lxd
		sed -i -e "s:__LIBDIR__:$(get_libdir):g" ${D}/usr/sbin/lxd || die

		# putting lxd into /usr/libexec because it's not intended to be run directly from the
		# command-line. It needs LD_LIBRARY_PATH set to /usr/lib(64)/lxd to find its custom
		# libs.

		exeinto /usr/libexec
		doexe ${bindir}/lxd
		dobin ${bindir}/fuidshift
		dosbin ${bindir}/lxd-benchmark ${bindir}/lxd-p2c

		# lxd uses a special bundled sqlite and dqlite -- we want to grab these, and install
		# them to /usr/$(get_libdir)/lxd/, which is a custom path that will be referenced by
		# the initscript.

		( cd ${S}/dist/deps/dqlite && make DESTDIR=${D} install ) || die 
		( cd ${S}/dist/deps/sqlite && 
			make DESTDIR=${D} install && 
			rm ${D}/usr/bin/sqlite3 && 
			rm ${D}/usr/include/sqlite*.h 
		) || die

		# Move dqlite and sqlite into the custom /usr/lib(64)/lxd directory. These are special
		# builds of these binaries specifically for lxd use.

		dodir /usr/$(get_libdir)/lxd
		( cd ${D}/usr && mv lib/* $(get_libdir)/lxd ) || die
	fi

	if use nls; then
		( cd ${S} && domo po/*.mo ) || die
	fi

	if use daemon; then
		newinitd "${FILESDIR}"/${PN}.initd.1 lxd
		sed -i -e "s:__LIBDIR__:$(get_libdir):g" ${D}/etc/init.d/lxd || die
		newconfd "${FILESDIR}"/${PN}.confd lxd
		systemd_newunit "${FILESDIR}"/${PN}.service ${PN}.service
	fi

	newbashcomp scripts/bash/lxd-client lxc

	dodoc AUTHORS README.md doc/*
}

pkg_postinst() {
	einfo
	einfo "Consult https://wiki.gentoo.org/wiki/LXD for more information,"
	einfo "including a Quick Start."

	# The messaging below only applies to daemon installs
	use daemon || return 0

	# The control socket will be owned by (and writeable by) this group.
	enewgroup lxd

	# Ubuntu also defines an lxd user but it appears unused (the daemon
	# must run as root)

	einfo
	einfo "Though not strictly required, some features are enabled at run-time"
	einfo "when the relevant helper programs are detected:"
	einfo "- sys-apps/apparmor"
	einfo "- sys-fs/btrfs-progs"
	einfo "- sys-fs/lvm2"
	einfo "- sys-fs/zfs"
	einfo
	einfo "Since these features can't be disabled at build-time they are"
	einfo "not USE-conditional."
	einfo
	einfo "Be sure to add your local user to the lxd group."
	einfo
	einfo "Networks with bridge.mode=fan are unsupported due to requiring"
	einfo "a patched kernel and iproute2."
}
