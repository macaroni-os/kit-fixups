# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit multilib-minimal

DESCRIPTION="Core nsswitch.conf file and Name Service Switch module for Multicast DNS"
HOMEPAGE="https://github.com/lathiat/nss-mdns"
SRC_URI="https://github.com/lathiat/nss-mdns/releases/download/v${PV}/nss-mdns-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="test +mdns +minimal +ipv6"
S=${WORKDIR}/nss-mdns-${PV}

RDEPEND=">=net-dns/avahi-0.6.31-r2[${MULTILIB_USEDEP}]
!sys-auth/nss-mdns"
DEPEND="${RDEPEND}
	test? ( >=dev-libs/check-0.11[${MULTILIB_USEDEP}] )"

multilib_src_configure() {
	local myconf=(
		# $(localstatedir)/run/... is used to locate avahi-daemon socket
		--localstatedir=/
	)

	ECONF_SOURCE=${S} \
	econf "${myconf[@]}"
}

multilib_src_install_all() {
	dodoc *.md
	insinto /etc
	doins "${FILESDIR}"/mdns.allow
	doins "${FILESDIR}"/nsswitch.conf
	if use mdns; then
		if use minimal; then
			if use ipv6; then
				files_line="mdns_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] dns mdns"
			else
				files_line="mdns4_minimal [NOTFOUND=return] resolve [!UNAVAIL=return] dns mdns4"
			fi
		else
			if use ipv6; then
				files_line="mdns resolve [!UNAVAIL=return] dns"
			else
				files_line="mdns4 resolve [!UNAVAIL=return] dns"
			fi
		fi
	else
		files_line="files resolve [!UNAVAIL=return] dns"
	fi
	sed -i -e "s/__HOSTS__/$files_line/g" $D/etc/nsswitch.conf || die
}

pkg_postinst() {
	if use mdns; then
		ewarn "Multicast DNS lookups enabled."
		if ! use minimal; then
			ewarn "You have disabled .local-only DNS lookups."
			ewarn "If you want to perform mDNS lookups for domains other than the ones"
			ewarn "ending in .local, add them to /etc/mdns.allow."
		fi
	fi
}
