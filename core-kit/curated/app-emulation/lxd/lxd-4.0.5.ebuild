# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools golang-base bash-completion-r1 linux-info user

DESCRIPTION="Fast, dense and secure container management"
HOMEPAGE="https://linuxcontainers.org/lxd/introduction/ https://github.com/lxc/lxd"
SRC_URI="https://linuxcontainers.org/downloads/${PN}/${P}.tar.gz"

# Needs to include licenses for all bundled programs and libraries.
LICENSE="Apache-2.0 BSD BSD-2 LGPL-3 MIT MPL-2.0"
SLOT="0"
KEYWORDS=""
IUSE="apparmor ipv6 nls"

DEPEND="app-arch/xz-utils
	|| (
		>=app-emulation/lxc-3.0.0[apparmor?,seccomp]
		>=app-emulation/lxc-4.0.6[apparmor?]
	)
	>=sys-kernel/linux-headers-4.15
	dev-lang/tcl
	dev-libs/libuv
	dev-libs/lzo
	net-dns/dnsmasq[dhcp,ipv6?]"
RDEPEND="${DEPEND}
	net-firewall/ebtables
	net-firewall/iptables[ipv6?]
	sys-apps/iproute2[ipv6?]
	sys-fs/fuse:*
	sys-fs/lxcfs
	sys-fs/squashfs-tools[lzma]
	virtual/acl"
BDEPEND=">=dev-lang/go-1.13
	nls? ( sys-devel/gettext )"

CONFIG_CHECK="
	~CGROUPS
	~IPC_NS
	~NET_NS
	~PID_NS

	~SECCOMP
	~USER_NS
	~UTS_NS
"

ERROR_IPC_NS="CONFIG_IPC_NS is required."
ERROR_NET_NS="CONFIG_NET_NS is required."
ERROR_PID_NS="CONFIG_PID_NS is required."
ERROR_SECCOMP="CONFIG_SECCOMP is required."
ERROR_UTS_NS="CONFIG_UTS_NS is required."

# Go magic.
QA_PREBUILT="/usr/lib/lxd/libdqlite.so.0.0.1
	/usr/bin/fuidshift
	/usr/bin/lxc
	/usr/bin/lxc-to-lxd
	/usr/bin/lxd-agent
	/usr/bin/lxd-benchmark
	/usr/bin/lxd-p2c
	/usr/sbin/lxd"

EGO_PN="github.com/lxc/lxd"
GOPATH="${S}/_dist" # this seems to reset every now and then, though

common_op() {
	local i
	for i in dqlite raft; do
		cd "${GOPATH}"/deps/${i} || die "failed to switch dir to ${i}"
		"${@}"
		cd "${S}" || die "failed to switch dir back from ${i} to ${S}"
	done
}

src_prepare() {
	default

	export GOPATH="${S}/_dist"

	sed -i \
		-e "s:\./configure:./configure --prefix=/usr --libdir=${EPREFIX}/usr/lib/lxd:g" \
		-e "s:make:make ${MAKEOPTS}:g" \
		Makefile || die

	sed -i 's#zfs version 2>/dev/null | cut -f 2 -d - | head -1#< /sys/module/zfs/version cut -f 1#' "${GOPATH}"/deps/raft/configure.ac || die

	# Fix hardcoded ovmf file path, see bug 763180
	sed -i \
		-e "s:/usr/share/OVMF:/usr/share/edk2-ovmf:g" \
		-e "s:OVMF_VARS.ms.fd:OVMF_VARS.secboot.fd:g" \
		doc/environment.md \
		lxd/apparmor/instance_qemu.go \
		lxd/instance/drivers/driver_qemu.go || die "Failed to fix hardcoded ovmf paths."

	common_op eautoreconf
}

src_configure() {
	export GOPATH="${S}/_dist"

	export RAFT_CFLAGS="-I${GOPATH}/deps/raft/include/"
	export RAFT_LIBS="${GOPATH}/deps/raft/.libs"

	export PKG_CONFIG_PATH="${GOPATH}/raft/"

	common_op econf --libdir="${EPREFIX}"/usr/lib/lxd
}

src_compile() {
	export GOPATH="${S}/_dist"
	export GO111MODULE=auto
	export GOFLAGS="-buildmode=pie -trimpath -mod=readonly"

	export CGO_CFLAGS="${CGO_CFLAGS} -I${GOPATH}/deps/dqlite/include/ -I${GOPATH}/deps/raft/include/"
	export CGO_LDFLAGS="${CGO_LDFLAGS} -L${GOPATH}/deps/dqlite/.libs/ -L${GOPATH}/deps/raft/.libs -Wl,-rpath,${EPREFIX}/usr/lib/lxd"
	export LD_LIBRARY_PATH="${GOPATH}/deps/dqlite/.libs/:${GOPATH}/deps/raft/.libs/:${LD_LIBRARY_PATH}"

	cd "${GOPATH}"/deps/raft || die
	emake

	cd "${GOPATH}"/deps/dqlite || die
	emake CFLAGS="-I${GOPATH}/deps/raft/include" LDFLAGS="-L${GOPATH}/deps/raft"

	cd "${GOPATH}/src/${EGO_PN}" || die
	mkdir -p _dist/bin
	go build -v -x -tags "netgo" -o _dist/bin/ ./lxd-p2c/... || die "Failed to build lxd-p2c"
	CGO_LDFLAGS="$CGO_LDFLAGS -static" go build -v -x -tags "agent" -o _dist/bin/ ./lxd-agent/... || die "Failed to build lxd-agent"
	for k in fuidshift lxc lxc-to-lxd lxd lxd-benchmark; do
		go build -v -x -tags "libsqlite3" -o _dist/bin/ ./${k}/... || die "failed compiling ${k}"
	done

	use nls && emake build-mo
}

src_test() {
	export GO111MODULE=auto
	export GOPATH="${S}/_dist"
	export GOFLAGS="-buildmode=pie -trimpath -mod=readonly"

	export CGO_CFLAGS="${CGO_CFLAGS} -I${GOPATH}/deps/dqlite/include/ -I${GOPATH}/deps/raft/include/"
	export CGO_LDFLAGS="${CGO_LDFLAGS} -L${GOPATH}/deps/dqlite/.libs/ -L${GOPATH}/deps/raft/.libs -Wl,-rpath,${EPREFIX}/usr/lib/lxd"
	export LD_LIBRARY_PATH="${GOPATH}/deps/dqlite/.libs/:${GOPATH}/deps/raft/.libs:${LD_LIBRARY_PATH}"

	go test -v ${EGO_PN}/lxd || die
}

src_install() {
	local bindir="_dist/bin"
	export GOPATH="${S}/_dist"

	dosbin ${bindir}/lxd

	for l in fuidshift lxd-agent lxd-benchmark lxd-p2c lxc lxc-to-lxd; do
		dobin ${bindir}/${l}
	done

	for m in dqlite raft; do
		cd "${GOPATH}"/deps/${m} || die "failed switching into ${GOPATH}/${m}"
		emake DESTDIR="${D}" install
	done

	cd "${S}" || die

	# We only need bundled libs during src_compile, and we don't want anything
	# to link against these.
	rm -r "${ED}"/usr/include || die
	rm -r "${ED}"/usr/lib/lxd/*.a || die
	rm -r "${ED}"/usr/lib/lxd/pkgconfig || die

	newbashcomp scripts/bash/lxd-client lxc

	newinitd "${FILESDIR}"/${PV}/lxd.initd lxd || die
	newconfd "${FILESDIR}"/${PV}/lxd.confd lxd || die

	dodoc AUTHORS doc/*
	use nls && domo po/*.mo
}

pkg_postinst() {
	elog
	elog "Consult https://www.funtoo.org/LXD for more information,"
	elog "including a Quick Start."

	# The control socket will be owned by (and writeable by) this group.
	enewgroup lxd

	elog
	elog "Please run 'lxc-checkconfig' to see all optional kernel features."
	elog
	elog "Though not strictly required, some features are enabled at run-time"
	elog "when the relevant helper programs are detected:"
	elog "- sys-fs/btrfs-progs"
	elog "- sys-fs/lvm2"
	elog "- sys-fs/zfs"
	elog "- sys-process/criu"
	elog
	elog "Be sure to add your local user to the lxd group."
}
