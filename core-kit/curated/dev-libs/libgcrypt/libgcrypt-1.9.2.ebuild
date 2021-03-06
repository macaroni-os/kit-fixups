# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic toolchain-funcs

DESCRIPTION="General purpose crypto library based on the code used in GnuPG"
HOMEPAGE="https://www.gnupg.org/"
SRC_URI="mirror://gnupg/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2.1 MIT"
SLOT="0/20" # subslot = soname major version
KEYWORDS=""
IUSE="+asm cpu_flags_arm_neon cpu_flags_x86_aes cpu_flags_x86_avx cpu_flags_x86_avx2 cpu_flags_x86_padlock cpu_flags_x86_sha cpu_flags_x86_sse4_1 doc o-flag-munging static-libs"

RDEPEND=">=dev-libs/libgpg-error-1.25"
DEPEND="${RDEPEND}"
BDEPEND="doc? ( virtual/texi2dvi )"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		CC_FOR_BUILD="$(tc-getBUILD_CC)"

		--enable-noexecstack
		$(use_enable cpu_flags_arm_neon neon-support)
		$(use_enable cpu_flags_x86_aes aesni-support)
		$(use_enable cpu_flags_x86_avx avx-support)
		$(use_enable cpu_flags_x86_avx2 avx2-support)
		$(use_enable cpu_flags_x86_padlock padlock-support)
		$(use_enable cpu_flags_x86_sha shaext-support)
		$(use_enable cpu_flags_x86_sse4_1 sse41-support)
		# required for sys-power/suspend[crypt], bug 751568
		$(use_enable static-libs static)
		$(use_enable o-flag-munging O-flag-munging)

		# disabled due to various applications requiring privileges
		# after libgcrypt drops them (bug #468616)
		--without-capabilities

		$(use asm || echo "--disable-asm")

		GPG_ERROR_CONFIG="${ESYSROOT}/usr/bin/gpg-error-config"
	)
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}" \
		$("${S}/configure" --help | grep -o -- '--without-.*-prefix')
}

src_compile() {
	default
	use doc && VARTEXFONTS="${T}/fonts" emake -C doc gcrypt.pdf
}

src_install() {
	emake DESTDIR="${D}" install
	use doc && dodoc doc/gcrypt.pdf
}

src_install_all() {
	default
	find "${ED}" -type f -name '*.la' -delete || die
}
