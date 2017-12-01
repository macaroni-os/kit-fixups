# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Fast, dense and secure container management"
HOMEPAGE="https://linuxcontainers.org/lxd/introduction/"
EGO_PN_PARENT="github.com/lxc"
EGO_PN="${EGO_PN_PARENT}/lxd"

# pay close attention to the list of go packages deps below when doing bumps.
EGO_VENDOR=(
	"github.com/golang/protobuf 1e59b77b52bf8e4b449a57e6f79f21226d571845"
	"github.com/gorilla/websocket aa5ed01c91270a67ce417d1810afc31ec14779a9"
	"github.com/juju/loggo 8232ab8918d91c72af1a9fb94d3edbe31d88b790"
	"github.com/juju/webbrowser 54b8c57083b4afb7dc75da7f13e2967b2606a507"
	"github.com/julienschmidt/httprouter e1b9828bc9e5904baec057a154c09ca40fe7fae0"
	"github.com/rogpeppe/fastuuid 6724a57986aff9bff1a1770e9347036def7c89f6"
	"golang.org/x/crypto 9f005a07e0d31d45e6656d241bb5c0f2efd4bc94 github.com/golang/crypto"
	"golang.org/x/net 9dfe39835686865bff950a07b394c12a98ddc811 github.com/golang/net"
	"gopkg.in/errgo.v1 442357a80af5c6bf9b6d51ae791a39c3421004f3 github.com/go-errgo/errgo"
	"gopkg.in/httprequest.v1 35158f716c228fdf58b5a5b80cf331302d10160a github.com/go-httprequest//httprequest"
	"github.com/gosexy/gettext 74466a0a0c4a62fea38f44aa161d4bbfbe79dd6b"
	"github.com/juju/persistent-cookiejar d5e5a8405ef9633c84af42fbcc734ec8dd73c198"
	"github.com/mattn/go-colorable 6fcc0c1fd9b620311d821b106a400b35dc95c497"
	"github.com/olekukonko/tablewriter a7a4c189eb47ed33ce7b35f2880070a0c82a67d4"
	"gopkg.in/juju/environschema.v1 7359fc7857abe2b11b5b3e23811a9c64cb6b01e0 github.com/juju/environschema"
	"gopkg.in/yaml.v2 287cf08546ab5e7e37d55a84f7ed3fd1db036de5 github.com/go-yaml/yaml"
	"github.com/dustinkirkland/golang-petname d3c2ba80e75eeef10c5cf2fc76d2c809637376b3"
	"github.com/gorilla/mux 2d5fef06b891c971b14aa6f71ca5ab6c03a36e0e"
	"github.com/juju/idmclient 15392b0e99abe5983297959c737b8d000e43b34c"
	"github.com/mattn/go-sqlite3 d5ffb5c0cca8778699a929b236766f4a7af674e8"
	"github.com/pborman/uuid e790cca94e6cc75c7064b1332e63811d4aae1a53"
	"github.com/stretchr/testify 2aa2c176b9dab406a6970f6a55f513e8a8c8b18f"
	"github.com/syndtr/gocapability db04d3cc01c8b54962a58ec7e491717d06cfcc16"
	"gopkg.in/flosch/pongo2.v3 5e81b817a0c48c1c57cdf1a9056cf76bdee02ca9 github.com/flosch/pongo2"
	"gopkg.in/lxc/go-lxc.v2 99ba61b9d6c9df1239f9ee43c48903a214d2cd34 github.com/lxc/go-lxc"
	"gopkg.in/tomb.v2 d5d1b5820637886def9eef33e03a27a9f166942c github.com/go-tomb/tomb"
	"github.com/juju/httprequest 77d36ac4b71a6095506c0617d5881846478558cb"
	"github.com/juju/schema e4e05803c9a103fdfa880476044100ac17e54830"
	"gopkg.in/macaroon-bakery.v2 ec9d2ad6796100720c154f614b6dea8798ec1181 github.com/go-macaroon-bakery/macaroon-bakery"
	"gopkg.in/macaroon.v2 bed2a428da6e56d950bed5b41fcbae3141e5b0d0 github.com/go-macaroon/macaroon"
	"github.com/juju/errors c7d06af17c68cd34c835053720b21f6549d9b0ee"
	"github.com/juju/go4 40d72ab9641a2a8c36a9c46a51e28367115c8e59"
	"github.com/juju/utils 4d9b38694f1e441c16421e2320f2b2fbd97fa597"
	"github.com/mattn/go-isatty 6ca4dbf54d38eea1a992b3c722a76a5d1c4cb25c"
	"github.com/mattn/go-runewidth 97311d9f7767e3d6f422ea06661bc2c7a19e8a5d"
	"golang.org/x/sys 82aafbf43bf885069dc71b7e7c2f9d7a614d47da github.com/golang/sys"
	"gopkg.in/retry.v1 01631078ef2fdce601e38cfe5f527fab24c9a6d2 github.com/go-retry/retry"
	"gopkg.in/juju/names.v2 54f00845ae470a362430a966fe17f35f8784ac92 github.com/juju/names"
)

ARCHIVE_URI="https://${EGO_PN}/archive/${P}.tar.gz -> ${P}.tar.gz"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""

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
)

src_prepare() {
	default_src_prepare

	# Examples in go-lxc make our build fail.
	rm -rf "${S}/src/${EGO_PN}/vendor/gopkg.in/lxc/go-lxc.v2/examples" || die
}

src_compile() {
	export GOPATH="${S}"

	cd "${S}/src/${EGO_PN}" || die "Failed to change to deep src dir"

	tmpgoroot="${T}/goroot"
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

