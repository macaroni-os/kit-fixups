# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3+ )
inherit xdg-utils meson python-any-r1

DESCRIPTION="A thin layer of types for graphic libraries"
HOMEPAGE="https://ebassi.github.io/graphene/"
SRC_URI="https://github.com/ebassi/graphene/releases/download/${PV}/${P}.tar.xz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="cpu_flags_arm_neon cpu_flags_x86_sse2 doc +introspection test"

RDEPEND="
	>=dev-libs/glib-2.62.0:2
	introspection? ( dev-libs/gobject-introspection:= )
"
DEPEND="${RDEPEND}"
# Python is only needed with USE=introspection or FEATURES=test, but not bothering with conditional python_setup, as meson uses it too anyway
BDEPEND="
	${PYTHON_DEPS}
	doc? ( dev-util/gtk-doc
		app-text/docbook-xml-dtd:4.3 )
	virtual/pkgconfig
"

src_prepare() {
	xdg_environment_reset
	default
}

src_configure() {
	# TODO: Do we want G_DISABLE_ASSERT as buildtype=release would do upstream?
	local emesonargs=(
		-Dgtk_doc=$(usex doc true false)
		-Dgobject_types=true
		-Dintrospection=$(usex introspection true false)
		-Dgcc_vector=true # if built-in support tests fail, it'll just not enable vector intrinsics; unfortunately this probably means disabled on clang too, due to it claiming to be <gcc-4.9
		$(meson_use cpu_flags_x86_sse2 sse2)
		$(meson_use cpu_flags_arm_neon arm_neon)
		$(meson_use test tests)
		-Dbenchmarks=false
		-Dinstalled_tests=false
	)

	meson_src_configure
}
