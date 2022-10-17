# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="${PN/sebastian-/}"

DESCRIPTION="Allows reflection of object attributes, including inherited and non-public ones"
HOMEPAGE="https://phpunit.de"
SRC_URI="https://github.com/sebastianbergmann/${MY_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

BDEPEND="dev-php/theseer-Autoload"

RDEPEND="dev-php/fedora-autoloader
	>=dev-lang/php-7.1:*"

S="${WORKDIR}/${MY_PN}-${PV}"

src_prepare() {
	default

	phpab \
		--output src/autoload.php \
		--template fedora2 \
		--basedir src \
		src \
		|| die
}

src_install() {
	insinto /usr/share/php/SebastianBergmann/ObjectReflector
	doins -r src/.

	einstalldocs
}
