# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Virtual for ${PN#perl-}"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	|| ( ~dev-perl/Pod-Parser-1.630.0 <dev-lang/perl-5.32 )
	dev-lang/perl:=
	!perl-core/Pod-Parser
"
