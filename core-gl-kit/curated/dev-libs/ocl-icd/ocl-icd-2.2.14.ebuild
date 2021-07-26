# Distributed under the terms of the GNU General Public License v2

EAPI=7

USE_RUBY="ruby25 ruby26 ruby27"
inherit autotools flag-o-matic multilib-minimal ruby-single

DESCRIPTION="Alternative to vendor specific OpenCL ICD loaders"
HOMEPAGE="https://github.com/OCL-dev/ocl-icd"
SRC_URI="https://github.com/OCL-dev/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"
LICENSE="BSD-2"
SLOT="0"
KEYWORDS="*"

BDEPEND="${RUBY_DEPS}"
DEPEND="dev-util/opencl-headers"
RDEPEND="${DEPEND}
	!<app-eselect/eselect-opencl-1.2.0
	!dev-libs/opencl-icd-loader"

src_prepare() {
	replace-flags -Os -O2 # bug 646122

	default
	eautoreconf
}

multilib_src_configure() {
	# dev-util/opencl-headers ARE official Khronos Group headers, what this option
	# does is disable the use of the bundled ones
	ECONF_SOURCE="${S}" econf --enable-pthread-once --disable-official-khronos-headers
}

multilib_src_install() {
	default

	# Drop .la files
	find "${ED}" -name '*.la' -delete || die
}
