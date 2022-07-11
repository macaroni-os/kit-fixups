# Distributed under the terms of the GNU General Public License v2

# please keep this ebuild at EAPI 7 -- sys-apps/portage dep
EAPI=7

DISTUTILS_USE_PEP517=no
PYTHON_COMPAT=( python3+ pypy3 )

inherit distutils-r1

DESCRIPTION="A library for installing Python wheels"
HOMEPAGE="
	https://pypi.org/project/installer/
	https://github.com/pypa/installer/
	https://installer.readthedocs.io/en/latest/
"
SRC_URI="
	https://github.com/pypa/installer/archive/${PV}.tar.gz
		-> ${P}.gh.tar.gz
	https://files.pythonhosted.org/packages/py3/${PN::1}/${PN}/${P%_p*}-py3-none-any.whl
		-> ${P%_p*}-py3-none-any.whl.zip
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"

BDEPEND="
	app-arch/unzip
"

distutils_enable_tests pytest

python_compile() {
	python_domodule src/installer "${WORKDIR}"/*.dist-info
}
