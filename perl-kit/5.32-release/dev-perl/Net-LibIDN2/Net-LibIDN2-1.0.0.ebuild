# Distributed under the terms of the GNU General Public License v2

EAPI=7

DIST_AUTHOR=THOR
DIST_VERSION=1.00
inherit perl-module

DESCRIPTION="Perl bindings for GNU Libidn2"
SLOT="0"
KEYWORDS="*"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="net-dns/libidn2:="
DEPEND="
	net-dns/libidn2:=
	dev-perl/Module-Build
"
BDEPEND="${RDEPEND}
	virtual/perl-ExtUtils-CBuilder
	virtual/perl-ExtUtils-ParseXS
	dev-perl/Module-Build
	test? (
		>=virtual/perl-Test-Simple-0.10.0
	)
"

PATCHES=( "${FILESDIR}/${P}"-libidn-2.0.5.patch )

src_configure() {
	unset LD
	[[ -n "${CCLD}" ]] && export LD="${CCLD}"
	perl-module_src_configure
}
src_compile() {
	./Build --config optimize="${CFLAGS}" build || die
}
