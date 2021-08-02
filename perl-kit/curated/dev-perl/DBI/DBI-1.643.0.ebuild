# Distributed under the terms of the GNU General Public License v2

EAPI=7

DIST_AUTHOR=TIMB
DIST_VERSION=1.643
DIST_EXAMPLES=("ex/*")
inherit perl-module

DESCRIPTION="Database independent interface for Perl"

SLOT="0"
KEYWORDS="*"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="
	>=dev-perl/PlRPC-0.200.0
	>=virtual/perl-Sys-Syslog-0.170.0
	virtual/perl-File-Spec
	!<=dev-perl/SQL-Statement-1.330.0
"
BDEPEND="${RDEPEND}
	>=virtual/perl-ExtUtils-MakeMaker-6.480.0
	test? (
		>=virtual/perl-Test-Simple-0.900.0
	)
"
PERL_RM_FILES=(
	t/pod-coverage.t
	t/pod.t
)
src_compile() {
	mymake=(
		"OPTIMIZE=${CFLAGS}"
	)
	perl-module_src_compile
}

src_test() {
	if [[ $(makeopts_jobs) -gt 70 ]]; then
		einfo "Reducing jobs to 70. Bug: https://bugs.gentoo.org/675164"
		MAKEOPTS="${MAKEOPTS} -j70";
	fi
	perl-module_src_test
}
