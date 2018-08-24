# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Fast, dense and secure container management"
HOMEPAGE="https://linuxcontainers.org/lxd/introduction/"

LICENSE="Apache-2.0 BSD BSD-2 LGPL-3 MIT MPL-2.0"
SLOT="0"
KEYWORDS=""

IUSE="+daemon +ipv6 +dnsmasq nls test"

inherit bash-completion-r1 linux-info systemd user

SRC_URI="https://linuxcontainers.org/downloads/${PN}/${P}.tar.gz"

DEPEND="
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

src_compile() {
	export GOPATH="${S}/dist"
	install -d $GOPATH
	rm -rf $GOPATH/src/*
	go get -d -v github.com/lxc/lxd/lxd || die
	#rm -rf $GOPATH/src/github.com/juju/utils
	#rm -rf $GOPATH/src/gopkg.in
	#go get -d -v github.com/lxc/lxd/lxd || die
	cd $GOPATH/src/github.com/lxc/lxd || die
	make -j ${MAKEOPTS} deps || die
	export CGO_CFLAGS="-I${GOPATH}/deps/sqlite/ -I${GOPATH}/deps/dqlite/include/"
	export CGO_LDFLAGS="-L${GOPATH}/deps/sqlite/.libs/ -L${GOPATH}/deps/dqlite/.libs/"
	export LD_LIBRARY_PATH="${GOPATH}/deps/sqlite/.libs/:${GOPATH}/deps/dqlite/.libs/"
	make -j ${MAKEOPTS} || die
	cd ${S} || die
	use nls && emake build-mo
}

src_test() {
	if use daemon; then
		export GOPATH="${S}/dist"
		# This is mostly a copy/paste from the Makefile's "check" rule, but
		# patching the Makefile to work in a non "fully-qualified" go namespace
		# was more complicated than this modest copy/paste.
		# Also: sorry, for now a network connection is needed to run tests.
		# Will properly bundle test dependencies later.
		go get -v -x github.com/rogpeppe/godeps
		go get -v -x github.com/remyoudompheng/go-misc/deadcode
		go get -v -x github.com/golang/lint/golint
		go test -v ${EGO_PN}/lxd
	else
		einfo "No tests to run for client-only builds"
	fi
}

src_install() {
	local bindir="dist/bin"
	dobin ${bindir}/lxc
	if use daemon; then
		dosbin ${bindir}/lxd
		dobin ${bindir}/fuidshift
		dosbin ${bindir}/lxd-benchmark ${bindir}/lxd-p2c ${bindir}/lxc-to-lxd
	fi

	if use nls; then
		domo po/*.mo
	fi

	if use daemon; then
		newinitd "${FILESDIR}"/${PN}.initd lxd
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
	einfo "- sys-process/criu"
	einfo
	einfo "Since these features can't be disabled at build-time they are"
	einfo "not USE-conditional."
	einfo
	einfo "Be sure to add your local user to the lxd group."
	einfo
	einfo "Networks with bridge.mode=fan are unsupported due to requiring"
	einfo "a patched kernel and iproute2."
}
