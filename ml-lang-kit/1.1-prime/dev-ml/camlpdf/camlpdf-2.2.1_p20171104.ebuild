# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit findlib eutils
COMMIT_ID="b8b69e9b03b2daa2d8b716a818581cba07be9a4e"
DESCRIPTION="OCaml library for reading, writing, and modifying PDF files"
HOMEPAGE="https://github.com/johnwhitington/camlpdf/"
SRC_URI="https://github.com/johnwhitington/${PN}/archive/${COMMIT_ID}.tar.gz -> ${P}.tar.gz"

# technically LGPL-2.1+ with linking exception
LICENSE="LGPL-2.1-with-linking-exception"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE="doc examples"

RDEPEND="dev-lang/ocaml:="
DEPEND="${RDEPEND}"
S=${WORKDIR}/${PN}-${COMMIT_ID}

src_compile() {
	# parallel make bugs
	emake -j1
}

src_install() {
	findlib_src_install
	dodoc Changes README.md

	if use doc ; then
		dodoc introduction_to_camlpdf.pdf
		dohtml doc/camlpdf/html/*
	fi

	use examples && dodoc -r examples
}

