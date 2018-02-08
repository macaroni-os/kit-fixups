# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit webapp

DESCRIPTION="phpSysInfo displays system stats via PHP"
HOMEPAGE="https://rk4an.github.com/phpsysinfo/"
SRC_URI="https://github.com/rk4an/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"

SLOT="0"
WEBAPP_MANUAL_SLOT="yes"

KEYWORDS="*"
IUSE=""

RDEPEND="
	virtual/httpd-php
	dev-lang/php[simplexml,xml,xsl(+),xslt(+),unicode]
"

src_install() {
	webapp_src_preinst

	dodoc CHANGELOG.md README*
	rm CHANGELOG.md COPYING README* .gitignore .travis.yml || die

	insinto "${MY_HTDOCSDIR}"
	doins -r .
	newins phpsysinfo.ini{.new,}

	webapp_configfile "${MY_HTDOCSDIR}"/phpsysinfo.ini

	webapp_src_install
}
