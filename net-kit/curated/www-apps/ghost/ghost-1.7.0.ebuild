# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="Ghost blogging platform."
HOMEPAGE="https://ghost.org"
SRC_URI="https://github.com/TryGhost/Ghost/releases/download/${PV}/Ghost-${PV}.zip"
LICENSE="MIT"
KEYWORDS="*"

RDEPEND="net-libs/nodejs[npm(+)]"
DEPEND="${RDEPEND} \
app-arch/unzip"

SLOT="0"

S=${WORKDIR}

src_install() {
	dodir /var/www/ghost/
	cp -r ${S}/* ${D}/var/www/ghost/
}

pkg_postinst() {
	elog "To start Ghost run:"
	elog "npm install --production"
	elog "Followed by:"
	elog "npm start --production"
	ewarn "Configure Ghost in /var/www/ghost/config.example.js and rename it to config.js"
	ewarn "** When updating in the future make sure to back up your config.js, and any"
	ewarn "themes you want to keep. They will be replaced upon version updates of Ghost **"
}
