# Distributed under the terms of the GNU General Public License v2

EAPI=7

DIST_AUTHOR=ZEFRAM
DIST_VERSION=0.008
inherit perl-module

DESCRIPTION="Custom OP checking attached to subroutines"
SLOT="0"
KEYWORDS="*"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-perl/DynaLoader-Functions-0.1.0
	virtual/perl-Exporter
	virtual/perl-XSLoader
	virtual/perl-parent
"
DEPEND="
	dev-perl/Module-Build
"
BDEPEND="${RDEPEND}
	dev-perl/Module-Build
	test? (
		>=virtual/perl-ExtUtils-CBuilder-0.150.0
		virtual/perl-ExtUtils-ParseXS
		virtual/perl-File-Spec
		virtual/perl-IO
		virtual/perl-Test-Simple
	)
"
PERL_RM_FILES=(
	t/pod_cvg.t
	t/pod_syn.t
)
src_configure() {
	unset LD
	[[ -n "${CCLD}" ]] && export LD="${CCLD}"
	perl-module_src_configure
}
src_compile() {
	./Build --config optimize="${CFLAGS}" build || die
}
