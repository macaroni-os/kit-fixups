# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{4,5,6} )

inherit distutils-r1 user

DESCRIPTION="LXDUI is a web UI for the native Linux container technology LXD/LXC"
HOMEPAGE="https://github.com/AdaptiveScale/lxdui"
SRC_URI="https://github.com/AdaptiveScale/${PN}/archive/v2.1.2.tar.gz -> ${P}.tar.gz"
LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/click[${PYTHON_USEDEP}]
	dev-python/flask[${PYTHON_USEDEP}]
	dev-python/flask-login[${PYTHON_USEDEP}]
	dev-python/flask-jwt[${PYTHON_USEDEP}]
	dev-python/jsonschema[${PYTHON_USEDEP}]
	dev-python/netaddr[${PYTHON_USEDEP}]
	dev-python/psutil[${PYTHON_USEDEP}]
	dev-python/pylxd[${PYTHON_USEDEP}]
	dev-python/pyopenssl[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/terminado[${PYTHON_USEDEP}]
	dev-python/tornado-xstatic[${PYTHON_USEDEP}]
	dev-python/xstatic-termjs[${PYTHON_USEDEP}]
	www-servers/tornado[${PYTHON_USEDEP}]
"

RDEPEND="app-emulation/lxd ${DEPEND}"

PATCHES=( "${FILESDIR}"/${P}-requirements.patch )

python_install_all() {
	dodir /etc/lxdui
	insinto /etc/lxdui
	doins "${FILESDIR}"/lxdui.conf
	doins conf/auth.conf
	keepdir /var/log/lxdui
	dosym ../lib/python-exec/${EPYTHON}/lxdui /usr/sbin/lxdui
	distutils-r1_python_install_all
}

pkg_postinst() {
	einfo "Please, run 'lxdui init' for setting and configuring lxdui"
}
