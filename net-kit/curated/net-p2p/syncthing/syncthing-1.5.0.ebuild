# Copyright 1999-2019 Gentoo Authors

EAPI=7
EGO_PN="github.com/${PN}/${PN}"

DESCRIPTION="Open Source Continuous File Synchronization"
HOMEPAGE="https://syncthing.net"
SRC_URI="https://${EGO_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="selinux tools"

BDEPEND=">=dev-lang/go-1.13"
RDEPEND="selinux? ( sec-policy/selinux-syncthing )"

inherit golang-vcs-snapshot systemd user xdg-utils

src_prepare() {
	default
}

src_compile() {
	export GOPATH="${S}:$(get_golibdir_gopath)"
	cd src/${EGO_PN} || die
	go run build.go -version "v${PV}" -no-upgrade install \
		$(usex tools "all" "") || die "build failed"
}

src_test() {
	cd src/${EGO_PN} || die
	go run build.go test || die "test failed"
}

src_install() {
	cd src/${EGO_PN} || die
	dobin bin/syncthing
}
