# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="The Funtoo IBus IME Backends meta package."
HOMEPAGE="https://www.funtoo.org/Funtoo:Multilingual"
SRC_URI=""

LICENSE="metapackage"
SLOT="0"
KEYWORDS="*"
IUSE="ime_backends_bamboo ime_backends_unikey ime_backends_anthy ime_backends_skk ime_backends_libpinyin ime_backends_chewing ime_backends_rime ime_backends_hangul ime_backends_m17n ime_backends_table"

RDEPEND="ime_backends_bamboo? ( app-i18n/ibus-bamboo )
	ime_backends_unikey? ( app-i18n/ibus-unikey )
	ime_backends_anthy? ( app-i18n/ibus-anthy )
	ime_backends_skk? ( app-i18n/ibus-skk )
	ime_backends_libpinyin? ( app-i18n/ibus-libpinyin )
	ime_backends_chewing? ( app-i18n/ibus-chewing )
	ime_backends_rime? ( app-i18n/ibus-rime )
	ime_backends_hangul? ( app-i18n/ibus-hangul )
	ime_backends_m17n? ( app-i18n/ibus-m17n )
	ime_backends_table? (
		app-i18n/ibus-table
		app-i18n/ibus-table-chinese
		app-i18n/ibus-table-others
		app-i18n/ibus-table-extraphrase
	)
"
