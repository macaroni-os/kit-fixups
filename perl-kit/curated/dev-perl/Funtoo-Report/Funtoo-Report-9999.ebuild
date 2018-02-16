# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit perl-module git-2

DESCRIPTION="Anonymous reporting tool for Funtoo Linux"
HOMEPAGE="https://github.com/haxmeister/funtoo-reporter"
SRC_URI=""
EGIT_REPO_URI="https://github.com/haxmeister/funtoo-reporter.git"

LICENSE=""
SLOT="0"
KEYWORDS=""
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
