# Distributed under the terms of the GNU General Public License v2

EAPI="7"

DESCRIPTION="Chinese extra phrases for IBus-Table"
HOMEPAGE="https://github.com/ibus/ibus/wiki"
# The above URI was used before, unfortunately google code is defunct and it's not known for how long the archive will
# last so I made fork of the source code on my github. Otherwise it seems unmaintained in all other places I have
# looked for it so I guess this is the safest bet idk. Here is the original URL for reference:
# SRC_URI="https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/ibus/${P}.tar.gz"
# This raises another question: Will I maintain it? Idk it seems unmaintained everywhere I looked so probably not but
# who knows I might add some words if needed
SRC_URI="https://github.com/Madman10K/ibus-table-extraphrase/releases/download/v1.3.9.20110826/ibus-table-extraphrase-1.3.9.20110826.tar.gz -> ibus-table-extraphrase-1.3.9.20110826.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="app-i18n/ibus-table"
DEPEND="${RDEPEND}
	virtual/pkgconfig"
