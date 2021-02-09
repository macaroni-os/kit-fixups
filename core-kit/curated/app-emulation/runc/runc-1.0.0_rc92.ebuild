# Distributed under the terms of the GNU General Public License v2

EAPI=6

CONFIG_CHECK="~USER_NS"
EGO_PN="github.com/opencontainers/${PN}"

MY_PV="${PV/_/-}"
# Change this when you update the ebuild
RUNC_COMMIT=ff819c7
SRC_URI="https://${EGO_PN}/archive/${RUNC_COMMIT}.tar.gz -> ${P}.tar.gz"
KEYWORDS=""
inherit linux-info golang-build golang-vcs-snapshot

DESCRIPTION="runc container cli tools"
HOMEPAGE="http://runc.io"

LICENSE="Apache-2.0 BSD-2 BSD MIT"
SLOT="0"
IUSE="+ambient apparmor hardened +kmem +seccomp"

RDEPEND="
	apparmor? ( sys-libs/libapparmor )
	seccomp? ( sys-libs/libseccomp )
	!app-emulation/docker-runc
"

src_compile() {
	# Taken from app-emulation/docker-1.7.0-r1
	export CGO_CFLAGS="-I${ROOT}/usr/include"
	export CGO_LDFLAGS="$(usex hardened '-fno-PIC ' '')
		-L${ROOT}/usr/$(get_libdir)"

	# build up optional flags
	local options=(
		$(usex ambient 'ambient' '')
		$(usex apparmor 'apparmor' '')
		$(usex seccomp 'seccomp' '')
		$(usex kmem '' 'nokmem')
	)

	COMMIT=${RUNC_COMMIT} GOPATH="${S}" emake BUILDTAGS="${options[*]}" \
		-C src/${EGO_PN}
}

src_install() {
	pushd src/${EGO_PN} || die
	dobin runc
	dodoc README.md PRINCIPLES.md
	popd || die
}
