# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3+ )
PYTHON_REQ_USE="xml"

inherit python-single-r1

DESCRIPTION="Translation tool for XML documents that uses gettext files and ITS rules"
HOMEPAGE="http://itstool.org/"
SRC_URI="http://files.itstool.org/itstool/${P}.tar.bz2"

# files in /usr/share/itstool/its are HPND/as-is || GPL-3
LICENSE="GPL-3+ || ( HPND GPL-3+ )"
SLOT="0"
KEYWORDS="*"
IUSE=""

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	$(python_gen_cond_dep 'dev-libs/libxml2[python,${PYTHON_USEDEP}]')"
DEPEND="${RDEPEND}"

pkg_setup() {
	DOCS=(ChangeLog NEWS) # AUTHORS, README are empty
	python-single-r1_pkg_setup
}

src_prepare() {
	python_fix_shebang "${WORKDIR}"
	eapply "${FILESDIR}"/issue_36.patch
	eapply_user
}
