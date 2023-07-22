# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

PROJECT="faad2"
COMMIT="d0a0bca3"

DESCRIPTION="Logitech patched AAC audio decoding library"
HOMEPAGE="https://www.audiocoding.com/faad2.html"
SRC_URI="https://github.com/ralph-irving/${PROJECT}/archive/${COMMIT}.tar.gz -> ${PF}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~x86"
IUSE="digitalradio"
RESTRICT="mirror"

RDEPEND=""
DEPEND=""

DOCS=( AUTHORS ChangeLog NEWS README TODO )

src_unpack() {
	unpack ${A}
	mv ${WORKDIR}/${PROJECT}-* ${S}
	mv ${S}/configure.in ${S}/configure.ac 
}

src_prepare() {
	default

	sed -i -e 's:iquote :I:' libfaad/Makefile.am || die

	# enforce static linking as we do not want to install the dynamic libraries and cause a conflict with regular faad2
	sed -e 's:libfaad.la:.libs/libfaad.a:' \
	    -e 's:libmp4ff.la:.libs/libmp4ff.a -lm:' \
	    -i frontend/Makefile.am

	eautoreconf
}

src_configure() {
	local myconf=(
		--without-xmms
		--enable-static
		$(use_with digitalradio drm)
	)

	ECONF_SOURCE="${S}" econf "${myconf[@]}"

	# do not build the frontend for non default abis
	if [ "${ABI}" != "${DEFAULT_ABI}" ] ; then
		sed -i -e 's/frontend//' Makefile || die
	fi
}

src_install() {
	exeinto /opt/logitechmediaserver/Bin/
	doexe frontend/faad
	einstalldocs
}
