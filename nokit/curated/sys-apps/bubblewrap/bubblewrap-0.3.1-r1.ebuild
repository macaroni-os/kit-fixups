# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit bash-completion-r1 linux-info autotools

DESCRIPTION="Unprivileged sandboxing tool, namespaces-powered chroot-like solution"
HOMEPAGE="https://github.com/projectatomic/bubblewrap"
SRC_URI="https://github.com/projectatomic/${PN}/releases/download/v${PV}/${P}.tar.xz"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="amd64 ~arm arm64 ~ppc ~ppc64 x86"
IUSE="selinux +suid"

RDEPEND="
	sys-libs/libseccomp
	sys-libs/libcap
	selinux? ( >=sys-libs/libselinux-2.1.9 )
"
DEPEND="${RDEPEND}
	app-text/docbook-xml-dtd:4.3
	app-text/docbook-xsl-stylesheets
	dev-libs/libxslt
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}/selinux.patch"
)

# tests require root priviledge
RESTRICT="test"

pkg_setup() {
	if [[ ${MERGE_TYPE} != buildonly ]]; then
		CONFIG_CHECK="~UTS_NS ~IPC_NS ~USER_NS ~PID_NS ~NET_NS"
		linux-info_pkg_setup
	fi
}

src_prepare() {
	# Apply patches.
	if declare -p PATCHES | grep -q "^declare -a "; then
		[[ -n ${PATCHES[@]} ]] && eapply "${PATCHES[@]}"
	else
		[[ -n ${PATCHES} ]] && eapply "${PATCHES}"
	fi
	eapply_user

	# Rerun Autotools.
	einfo "Regenerating autotools files..."
	WANT_AUTOCONF=2.63 eautoconf
}

src_configure() {
	econf \
		$(use_enable selinux) \
		"--enable-man" \
		"--with-bash-completion-dir=$(get_bashcompdir)" \
		"--with-priv-mode=$(usex suid setuid none)"
}
