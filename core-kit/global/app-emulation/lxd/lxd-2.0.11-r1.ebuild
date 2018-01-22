# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Fast, dense and secure container management"
HOMEPAGE="https://linuxcontainers.org/lxd/introduction/"
EGO_PN_PARENT="github.com/lxc"
EGO_PN="${EGO_PN_PARENT}/lxd"

# Maintained with https://github.com/hsoft/gentoo-ego-vendor-update
EGO_VENDOR=(
	"github.com/lxc/lxd 73d4d91a18b0fe132e9ccb50c10b61dace2aa131"
	"github.com/gorilla/websocket 292fd08b2560ad524ee37396253d71570339a821"
	"github.com/gorilla/mux 69dae3b874ba34bcaa563d5e5b1680334bfd9b73"
	"github.com/juju/loggo 8232ab8918d91c72af1a9fb94d3edbe31d88b790"
	"github.com/juju/httprequest 77d36ac4b71a6095506c0617d5881846478558cb"
	"github.com/juju/webbrowser 54b8c57083b4afb7dc75da7f13e2967b2606a507"
	"github.com/juju/persistent-cookiejar d5e5a8405ef9633c84af42fbcc734ec8dd73c198"
	"github.com/juju/go4 40d72ab9641a2a8c36a9c46a51e28367115c8e59"
	"github.com/rogpeppe/fastuuid 6724a57986aff9bff1a1770e9347036def7c89f6"
	"github.com/golang/protobuf 1e59b77b52bf8e4b449a57e6f79f21226d571845"
	"github.com/julienschmidt/httprouter e1b9828bc9e5904baec057a154c09ca40fe7fae0"
	"github.com/gosexy/gettext 74466a0a0c4a62fea38f44aa161d4bbfbe79dd6b"
	"github.com/go-stack/stack 259ab82a6cad3992b4e21ff5cac294ccb06474bc"
	"github.com/mattn/go-colorable 6cc8b475d4682021d75d2cbe2bc481bec4ce98e5"
	"github.com/mattn/go-isatty 6ca4dbf54d38eea1a992b3c722a76a5d1c4cb25c"
	"github.com/mattn/go-runewidth 97311d9f7767e3d6f422ea06661bc2c7a19e8a5d"
	"github.com/mattn/go-sqlite3 6c771bb9887719704b210e87e934f08be014bdb1"
	"github.com/olekukonko/tablewriter 96aac992fc8b1a4c83841a6c3e7178d20d989625"
	"github.com/stretchr/testify 87b1dfb5b2fa649f52695dd9eae19abe404a4308"
	"github.com/dustinkirkland/golang-petname d3c2ba80e75eeef10c5cf2fc76d2c809637376b3"
	"github.com/pborman/uuid e533369306653d193b93dae055f6083cbf8ba54f"
	"github.com/syndtr/gocapability db04d3cc01c8b54962a58ec7e491717d06cfcc16"
	"golang.org/x/crypto 13931e22f9e72ea58bb73048bc752b48c6d4d4ac github.com/golang/crypto"
	"golang.org/x/net 5ccada7d0a7ba9aeb5d3aca8d3501b4c2a509fec github.com/golang/net"
	"golang.org/x/sys 2c42eef0765b9837fbdab12011af7830f55f88f0 github.com/golang/sys"
	"gopkg.in/yaml.v2 d670f9405373e636a5a2765eea47fac0c9bc91a4 github.com/go-yaml/yaml" # branch v2
	"gopkg.in/macaroon-bakery.v2-unstable 38b77b89a624fc1ec5b16ad83587befac27431da github.com/go-macaroon-bakery/macaroon-bakery" # branch v2-unstable
	"gopkg.in/errgo.v1 442357a80af5c6bf9b6d51ae791a39c3421004f3 github.com/go-errgo/errgo" # branch v1
	"gopkg.in/macaroon.v2 bed2a428da6e56d950bed5b41fcbae3141e5b0d0 github.com/go-macaroon/macaroon" # branch v2
	"gopkg.in/retry.v1 2d7c7c65cc71d024968d9ff4385d5e7ad3a83fcc github.com/go-retry/retry" # branch v1
	"gopkg.in/inconshreveable/log15.v2 0decfc6c20d9ca0ad143b0e89dcaa20f810b4fb3 github.com/inconshreveable/log15" # branch v2.13
	"gopkg.in/flosch/pongo2.v3 5e81b817a0c48c1c57cdf1a9056cf76bdee02ca9 github.com/flosch/pongo2" # branch v3.0
	"gopkg.in/lxc/go-lxc.v2 8741a7213cda0df1951283400247300e75abaf17 github.com/lxc/go-lxc" # branch v2
	"gopkg.in/tomb.v2 d5d1b5820637886def9eef33e03a27a9f166942c github.com/go-tomb/tomb" # branch v2
)

ARCHIVE_URI="https://${EGO_PN}/archive/${P}.tar.gz -> ${P}.tar.gz"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

IUSE="+daemon +ipv6 +dnsmasq nls test"

inherit bash-completion-r1 linux-info user golang-vcs-snapshot

SRC_URI="${ARCHIVE_URI}
	${EGO_VENDOR_URI}"

DEPEND="
	>=dev-lang/go-1.7.1
	dev-go/go-sqlite3
	dev-libs/protobuf
	nls? ( sys-devel/gettext )
	test? (
		app-misc/jq
		dev-db/sqlite
		net-misc/curl
		sys-devel/gettext
	)
"

RDEPEND="
	daemon? (
		app-arch/xz-utils
		>=app-emulation/lxc-2.0.7[seccomp]
		dnsmasq? (
			net-dns/dnsmasq[dhcp,ipv6?]
		)
		net-misc/rsync[xattr]
		sys-apps/iproute2[ipv6?]
		sys-fs/squashfs-tools
		virtual/acl
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
	"${FILESDIR}/${PN}-2.18-dont-go-get.patch"
	"${FILESDIR}/${P}-fix-ja-po.patch"
)

src_prepare() {
	default_src_prepare

	# Examples in go-lxc make our build fail.
	rm -rf "${S}/src/${EGO_PN}/vendor/gopkg.in/lxc/go-lxc.v2/examples" || die
}

src_compile() {
	export GOPATH="${S}"

	cd "${S}/src/${EGO_PN}" || die "Failed to change to deep src dir"

	#tmpgoroot="${T}/goroot"
	if use daemon; then
		# Build binaries
		emake
	else
		# build client tool
		emake client
	fi

	use nls && emake build-mo
}

src_test() {
	if use daemon; then
		export GOPATH="${S}"
		cd "${S}/src/${EGO_PN}" || die "Failed to change to deep src dir"

		emake check
	fi
}

src_install() {
	dobin bin/lxc
	if use daemon; then
		dosbin bin/lxd
		dobin bin/lxd-benchmark
		dobin bin/lxd-bridge-proxy
		dobin bin/fuidshift
	fi

	cd "src/${EGO_PN}" || die "can't cd into ${S}/src/${EGO_PN}"

	if use nls; then
		domo po/*.mo
	fi

	if use daemon; then
		newinitd "${FILESDIR}"/${PN}-2.18.initd lxd
		newconfd "${FILESDIR}"/${PN}-2.18.confd lxd
	fi

	newbashcomp config/bash/lxd-client lxc

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
	einfo "- sys-fs/lxcfs"
	einfo "- sys-fs/zfs"
	einfo "- sys-process/criu"
	einfo
	einfo "Since these features can't be disabled at build-time they are"
	einfo "not USE-conditional."
	einfo
	einfo "Networks with bridge.mode=fan are unsupported due to requiring"
	einfo "a patched kernel and iproute2."
}
