# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Virtual for I18N-LangTags"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	|| ( =dev-lang/perl-5.32* ~perl-core/I18N-LangTags-${PV} )
	dev-lang/perl:=
	!<perl-core/I18N-LangTags-${PV}
	!>perl-core/I18N-LangTags-${PV}-r999
"
