# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
inherit autotools fcaps linux-info python-r1 systemd user

DESCRIPTION="Linux real time system monitoring, done right!"
HOMEPAGE="https://github.com/netdata/netdata https://my-netdata.io/"
LICENSE="GPL-3+ MIT BSD"
SRC_URI="https://github.com/netdata/netdata/releases/download/v1.29.3/netdata-v1.29.3.tar.gz"

SLOT="0"
KEYWORDS="*"
IUSE="caps +compression cpu_flags_x86_sse2 cups dbengine ipmi jsonc mysql nfacct nodejs postgres prometheus +python tor xen"

REQUIRED_USE="
	mysql? ( python )
	python? ( ${PYTHON_REQUIRED_USE} )
	tor? ( python )"

# most unconditional dependencies are for plugins.d/charts.d.plugin:
RDEPEND="
	app-misc/jq
	>=app-shells/bash-4:0
	|| (
		net-analyzer/openbsd-netcat
		net-analyzer/netcat
	)
	net-analyzer/tcpdump
	net-analyzer/traceroute
	net-libs/libwebsockets
	net-misc/curl
	net-misc/wget
	sys-apps/util-linux
	virtual/awk
	caps? ( sys-libs/libcap )
	cups? ( net-print/cups )
	dbengine? (
	app-arch/lz4
	dev-libs/judy
	dev-libs/openssl:=
	)
	dev-libs/libuv
	compression? ( sys-libs/zlib )
	ipmi? ( sys-libs/freeipmi )
	jsonc? ( dev-libs/json-c:= )
	nfacct? (
		net-firewall/nfacct
		net-libs/libmnl
	)
	nodejs? ( net-libs/nodejs )
	prometheus? (
	dev-libs/protobuf:=
	app-arch/snappy
	)
	python? (
		${PYTHON_DEPS}
		dev-python/pyyaml[${PYTHON_USEDEP}]
		mysql? (
			|| (
				dev-python/mysqlclient[${PYTHON_USEDEP}]
				dev-python/mysql-python[${PYTHON_USEDEP}]
			)
		)
		postgres? ( dev-python/psycopg:2[${PYTHON_USEDEP}] )
		tor? ( net-libs/stem[${PYTHON_USEDEP}] )
	)
	xen? (
		app-emulation/xen-tools
		dev-libs/yajl
	)"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

: ${NETDATA_USER:=netdata}
: ${NETDATA_GROUP:=netdata}

FILECAPS=(
	'cap_dac_read_search,cap_sys_ptrace+ep' 'usr/libexec/netdata/plugins.d/apps.plugin'
)

S="${WORKDIR}/${PN}-v${PV}"

pkg_setup() {
	linux-info_pkg_setup

	enewgroup ${PN}
	enewuser ${PN} -1 -1 / ${PN}
}

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		--localstatedir="${EPREFIX}"/var \
		--with-user=${NETDATA_USER} \
		$(use_enable cups plugin-cups) \
		$(use_enable nfacct plugin-nfacct) \
		$(use_enable ipmi plugin-freeipmi) \
		$(use_enable xen plugin-xenstat) \
		$(use_enable cpu_flags_x86_sse2 x86-sse) \
		$(use_with compression zlib)
}

src_install() {
	default

	rm -rf "${D}/var/cache" || die

	keepdir /var/log/netdata
	fowners -Rc ${NETDATA_USER}:${NETDATA_GROUP} /var/log/netdata
	keepdir /var/lib/netdata
	keepdir /var/lib/netdata/registry
	fowners -Rc ${NETDATA_USER}:${NETDATA_GROUP} /var/lib/netdata

	fowners -Rc root:${NETDATA_GROUP} /usr/share/${PN}

	newinitd system/netdata-openrc ${PN}
	systemd_dounit system/netdata.service
	insinto /etc/netdata
	doins system/netdata.conf
}