# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit eutils prefix

DESCRIPTION="LSB version query program"
HOMEPAGE="https://wiki.linuxfoundation.org/lsb/"
SRC_URI="mirror://sourceforge/lsb/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"

# Perl isn't needed at runtime, it is just used to generate the man page.
DEPEND="dev-lang/perl"

src_prepare() {
	epatch "${FILESDIR}"/${P}-os-release.patch # bug 443116

	# use POSIX 'printf' instead of bash 'echo -e', bug #482370
	sed -i \
		-e "s:echo -e:printf '%b\\\n':g" \
		-e 's:--long:-l:g' \
		lsb_release || die

	hprefixify lsb_release
}

src_install() {
	emake \
		prefix="${ED}/usr" \
		mandir="${ED}/usr/share/man" \
		install

	dodir /etc
	cat > "${ED}/etc/lsb-release" <<- EOF
		DISTRIB_ID="macaroni"
		DISTRIB_DESCRIPTION="Macaroni OS"
		DISTRIB_CODENAME=mark
	EOF
}
