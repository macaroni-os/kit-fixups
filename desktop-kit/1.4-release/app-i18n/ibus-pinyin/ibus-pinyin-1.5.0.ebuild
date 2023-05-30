# Distributed under the terms of the GNU General Public License v2

EAPI=7
LUA_COMPAT=( lua5-1 )
PYTHON_COMPAT=( python3+ )

inherit autotools lua-single python-single-r1

DESCRIPTION="Chinese Pinyin and Bopomofo engines for IBus"
HOMEPAGE="https://github.com/ibus/ibus-pinyin"
SRC_URI="https://github.com/ibus/ibus-pinyin/tarball/eecbc1dab658acea9304c1434585669660e76689 -> ibus-pinyin-1.5.0-eecbc1d.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="boost lua nls"
REQUIRED_USE="${PYTHON_REQUIRED_USE}
	lua? ( ${LUA_REQUIRED_USE} )"

RDEPEND="${PYTHON_DEPS}
	app-i18n/pyzy
	dev-db/sqlite:3
	$(python_gen_cond_dep '
		app-i18n/ibus[python(+),${PYTHON_USEDEP}]
		dev-python/pygobject:3[${PYTHON_USEDEP}]
	')
	boost? ( dev-libs/boost )
	lua? ( ${LUA_DEPS} )
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-util/intltool
	sys-devel/autoconf-archive
	virtual/pkgconfig
	nls? ( sys-devel/gettext )"

PATCHES=(
	"${FILESDIR}"/${PN}-boost.patch
	"${FILESDIR}"/${P}-content-type-method.patch
)

src_unpack() {
	unpack ${A}
	mv "${WORKDIR}"/ibus-ibus-pinyin-* "${S}"
}

pkg_setup() {
	python-single-r1_pkg_setup

	if use lua; then
		lua-single_pkg_setup
	fi
}

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable boost) \
		$(use_enable lua lua-extension) \
		$(use_enable nls)
}