# Distributed under the terms of the GNU General Public License v2

EAPI=7

VERIFY_SIG_OPENPGP_KEY_PATH="${BROOT}"/usr/share/openpgp-keys/antoniodiazdiaz.asc
inherit toolchain-funcs

DESCRIPTION="Parallel lzip compressor"
HOMEPAGE="https://www.nongnu.org/lzip/plzip.html"
SRC_URI="https://download.savannah.gnu.org/releases/lzip/${PN}/${P}.tar.gz"


LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"

RDEPEND="app-arch/lzlib:0="
DEPEND="${RDEPEND}"

src_configure() {
	local myconf=(
		--prefix="${EPREFIX}"/usr
		CXX="$(tc-getCXX)"
		CPPFLAGS="${CPPFLAGS}"
		CXXFLAGS="${CXXFLAGS}"
		LDFLAGS="${LDFLAGS}"
	)

	# not autotools-based
	./configure "${myconf[@]}" || die
}
