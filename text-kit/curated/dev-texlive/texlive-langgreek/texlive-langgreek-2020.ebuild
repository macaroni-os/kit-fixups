# Distributed under the terms of the GNU General Public License v2

EAPI="7"

TEXLIVE_MODULE_CONTENTS="babel-greek begingreek betababel cbfonts cbfonts-fd gfsbaskerville gfsporson greek-fontenc greek-inputenc greekdates greektex greektonoi hyphen-greek hyphen-ancientgreek ibycus-babel ibygrk kerkis levy lgreek mkgrkindex teubner xgreek yannisgr collection-langgreek
"
TEXLIVE_MODULE_DOC_CONTENTS="babel-greek.doc begingreek.doc betababel.doc cbfonts.doc cbfonts-fd.doc gfsbaskerville.doc gfsporson.doc greek-fontenc.doc greek-inputenc.doc greekdates.doc greektex.doc greektonoi.doc hyphen-greek.doc ibycus-babel.doc ibygrk.doc kerkis.doc levy.doc lgreek.doc mkgrkindex.doc teubner.doc xgreek.doc yannisgr.doc "
TEXLIVE_MODULE_SRC_CONTENTS="babel-greek.source begingreek.source cbfonts-fd.source greek-fontenc.source greekdates.source ibycus-babel.source teubner.source xgreek.source "
inherit  texlive-module
DESCRIPTION="TeXLive Greek"

LICENSE=" GPL-1 GPL-2 LGPL-3 LPPL-1.3 LPPL-1.3c public-domain TeX-other-free "
SLOT="0"
KEYWORDS="*"
IUSE=""
DEPEND=">=dev-texlive/texlive-basic-2020
"
RDEPEND="${DEPEND} "
TEXLIVE_MODULE_BINSCRIPTS="texmf-dist/scripts/mkgrkindex/mkgrkindex"
