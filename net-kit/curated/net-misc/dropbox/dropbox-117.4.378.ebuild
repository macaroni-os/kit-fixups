# Distributed under the terms of the GNU General Public License v2

EAPI=7

GNOME3_LA_PUNT="yes"
PYTHON_COMPAT=( python3+ )

inherit autotools eutils gnome3-utils python-single-r1 gnome3

DESCRIPTION="Dropbox command-line client and Funtoo-optimized installer with GUI setup"
HOMEPAGE="http://dropbox.com/"
SCRIPT_A="dropbox-python-setup-1.1.tar.gz"
SRC_URI="https://www.github.com/funtoo/dropbox-python-setup/tarball/1.1/ -> ${SCRIPT_A}
	x86? ( https://edge.dropboxstatic.com/dbx-releng/client/dropbox-lnx.x86-117.4.378.tar.gz )
	amd64? ( https://edge.dropboxstatic.com/dbx-releng/client/dropbox-lnx.x86_64-117.4.378.tar.gz )
	gnome? ( https://linux.dropbox.com/packages/nautilus-dropbox-2020.03.04.tar.bz2 )"

LICENSE="CC-BY-ND-3.0 FTL MIT LGPL-2 openssl dropbox"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"
IUSE="gnome"

pkg_setup() {
	# tweak S depending on whether we are building nautilus-dropbox or not:
	if use gnome; then
		S="$WORKDIR/nautilus-dropbox-2020.03.04"
	else
		S="$WORKDIR"
	fi
	# get python set up for configure:
	python_setup
}

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RDEPEND="${PYTHON_DEPS}
	!gnome-extra/nautilus-dropbox
	gnome? ( gnome-base/nautilus
	dev-libs/glib
	dev-libs/libffi
	dev-python/pygtk[${PYTHON_USEDEP}]
	x11-libs/gtk+
	x11-libs/libnotify
	x11-libs/libXinerama )
"
DEPEND="${RDEPEND} gnome? (
	virtual/pkgconfig
	dev-python/docutils[${PYTHON_USEDEP}]
	)"

src_unpack() {
	if use gnome; then
		unpack nautilus-dropbox-2020.03.04.tar.bz2
	fi
	unpack ${SCRIPT_A}
}

src_prepare() {
	if use gnome; then
		gnome3_src_prepare
		eapply "${FILESDIR}"/nautilus-dropbox-2019-system-rst2man.patch
		sed -i 's/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/g' configure.ac || die
		AT_NOELIBTOOLIZE=yes eautoreconf
	fi
	default
}

src_configure() {
	use gnome && gnome3_src_configure
}

src_compile() {
	use gnome && gnome3_src_compile
}

src_install () {
	if use gnome; then
		gnome3_src_install
	fi
	insinto /usr/share/dropbox
	if [ "$ARCH" == "amd64" ]; then
		newins ${DISTDIR}/dropbox-lnx.x86_64-${PV}.tar.gz dropbox-dist.tar.gz
	else
		newins ${DISTDIR}/dropbox-lnx.x86-${PV}.tar.gz dropbox-dist.tar.gz
	fi
	newbin "${WORKDIR}/funtoo-dropbox-python-setup"-???????/dropbox.py dropbox || die
}

pkg_postinst () {
	if use gnome; then
		gnome3_pkg_postinst
	fi
	einfo "Type 'dropbox start -i' as the user you wish to enable dropbox to initialize dropbox."
}