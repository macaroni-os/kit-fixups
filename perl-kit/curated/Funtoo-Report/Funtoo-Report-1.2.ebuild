# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit perl-module git-r3

DESCRIPTION="Anonymous reporting tool for Funtoo Linux"
HOMEPAGE="https://github.com/haxmeister/funtoo-reporter"
SRC_URI=""
EGIT_REPO_URI="https://github.com/haxmeister/funtoo-reporter.git"
EGIT_COMMIT="25d2732c2461829544c76f7018475bb502e031ab"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="
		dev-perl/JSON
		dev-perl/Search-Elasticsearch
"

S="${WORKDIR}/${PN}-${PV}"

src_install() {
	mydoc="README.md"
	perl-module_src_install
	dosbin funtoo-report
}
