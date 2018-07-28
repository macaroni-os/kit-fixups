# Distributed under the terms of the GNU General Public License v2

EAPI=6

GNOME2_LA_PUNT="yes"
PYTHON_COMPAT=( python2_7 )

inherit autotools eutils gnome2-utils python-single-r1 gnome2

DESCRIPTION="Dropbox command-line client and Funtoo-optimized installer with GUI setup"
HOMEPAGE="http://dropbox.com/"
NAUT_A="nautilus-dropbox-1.6.2.tar.bz2"
GITHUB_REPO="dropbox-python-setup"
GITHUB_USER="funtoo"
GITHUB_TAG="1.1"
SCRIPT_A="dropbox-python-setup-${GITHUB_TAG}.tar.gz"
SRC_URI="https://www.github.com/${GITHUB_USER}/${GITHUB_REPO}/tarball/${GITHUB_TAG} -> ${SCRIPT_A} 
	x86? ( https://clientupdates.dropboxstatic.com/dbx-releng/client/dropbox-lnx.x86-${PV}.tar.gz )
	amd64? ( https://clientupdates.dropboxstatic.com/dbx-releng/client/dropbox-lnx.x86_64-${PV}.tar.gz )
	gnome? ( http://www.dropbox.com/download?dl=packages/$NAUT_A )"

LICENSE="CC-BY-ND-3.0 FTL MIT LGPL-2 openssl dropbox"
SLOT="0"
KEYWORDS="amd64 x86 x86-linux"
RESTRICT="mirror"
IUSE="gnome"

pkg_setup() {
	# tweak S depending on whether we are building nautilus-dropbox or not:
	if use gnome; then
		S="$WORKDIR/${NAUT_A%.tar.bz2}"
	else
		S="$WORKDIR"
	fi
	# get python-2.7 set up for configure:
	python_setup
}

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RDEPEND="${PYTHON_DEPS}
	!gnome-extra/nautilus-dropbox
	gnome? ( gnome-base/nautilus
	dev-libs/glib:2
	dev-python/pygtk:2[${PYTHON_USEDEP}]
	x11-libs/gtk+:2
	x11-libs/libnotify
	x11-libs/libXinerama )
"

DEPEND="${RDEPEND} gnome? (
	virtual/pkgconfig
	dev-python/docutils[${PYTHON_USEDEP}]
	)"

src_unpack() {
	if use gnome; then
		unpack ${NAUT_A}
	fi
	unpack ${SCRIPT_A}
}

src_prepare() {
	if use gnome; then
		gnome2_src_prepare
		eapply "${FILESDIR}"/nautilus-dropbox-0.7.0-system-rst2man.patch
		sed -i 's/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/g' configure.in || die
		AT_NOELIBTOOLIZE=yes eautoreconf
	fi
	default
}

src_compile() {
	use gnome && gnome2_src_compile
}

src_configure() {
	use gnome && gnome2_src_configure
}

src_install () {
	if use gnome; then
		gnome2_src_install
	fi
	insinto /usr/share/dropbox
	if [ "$ARCH" == "amd64" ]; then
		newins ${DISTDIR}/dropbox-lnx.x86_64-${PV}.tar.gz dropbox-dist.tar.gz
	else 
		newins ${DISTDIR}/dropbox-lnx.x86-${PV}.tar.gz dropbox-dist.tar.gz
	fi
	newbin "${WORKDIR}/${GITHUB_USER}-dropbox-python-setup"-???????/dropbox.py dropbox || die
}

pkg_postinst () {
	if use gnome; then
		gnome2_pkg_postinst
	fi
	einfo "Type 'dropbox start -i' as the user you wish to enable dropbox to initialize dropbox."
}

