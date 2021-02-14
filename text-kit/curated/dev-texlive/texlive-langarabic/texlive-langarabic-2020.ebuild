# Distributed under the terms of the GNU General Public License v2

EAPI="7"

TEXLIVE_MODULE_CONTENTS="alkalami alpha-persian amiri arabi arabi-add arabluatex arabtex bidi bidihl dad ghab hyphen-arabic hyphen-farsi imsproc kurdishlipsum lshort-persian luabidi na-box persian-bib sexam simurgh tram xepersian xepersian-hm collection-langarabic
"
TEXLIVE_MODULE_DOC_CONTENTS="alkalami.doc alpha-persian.doc amiri.doc arabi.doc arabi-add.doc arabluatex.doc arabtex.doc bidi.doc bidihl.doc dad.doc ghab.doc imsproc.doc kurdishlipsum.doc lshort-persian.doc luabidi.doc na-box.doc persian-bib.doc sexam.doc simurgh.doc tram.doc xepersian.doc xepersian-hm.doc "
TEXLIVE_MODULE_SRC_CONTENTS="arabluatex.source bidi.source xepersian.source xepersian-hm.source "
inherit  texlive-module
DESCRIPTION="TeXLive Arabic"

LICENSE=" CC-BY-SA-4.0 GPL-2 GPL-3+ LPPL-1.3 LPPL-1.3c MIT "
SLOT="0"
KEYWORDS="*"
IUSE=""
DEPEND=">=dev-texlive/texlive-basic-2020
"
RDEPEND="${DEPEND} "
