# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit perl-module

COMMIT_ID="369fd109db2588dda749230a0b556ac3b14e7c32"
DESCRIPTION="Anonymous reporting tool for Funtoo Linux"
HOMEPAGE="https://github.com/haxmeister/funtoo-reporter"
SRC_URI="https://github.com/haxmeister/funtoo-reporter/archive/${COMMIT_ID}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
		dev-perl/JSON
		dev-perl/Search-Elasticsearch
"

S="${WORKDIR}/funtoo-reporter-${COMMIT_ID}"

src_install() {
	mydoc="README.md"
	perl-module_src_install
	dosbin funtoo-report
}
