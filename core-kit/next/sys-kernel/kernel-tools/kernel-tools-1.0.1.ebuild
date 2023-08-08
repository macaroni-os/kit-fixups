# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit bash-completion-r1 eutils

VERSION_DMRAID='1.0.0.rc16-3'
VERSION_MDADM='3.1.5'
VERSION_E2FSPROGS='1.42'
VERSION_FUSE='2.8.6'
VERSION_ISCSI='2.0.877'
VERSION_UNIONFS_FUSE='0.24'
VERSION_GPG='1.4.11'

RH_HOME="ftp://sources.redhat.com/pub"
DM_HOME="http://people.redhat.com/~heinzm/sw/dmraid/src"

COMMON_URI="mirror://funtoo/dmraid-${VERSION_DMRAID}.tar.bz2
		https://github.com/open-iscsi/open-iscsi/archive/${VERSION_ISCSI}.tar.gz -> open-iscsi-${VERSION_ISCSI}.tar.gz
		mirror://funtoo/e2fsprogs-${VERSION_E2FSPROGS}.tar.gz
		mirror://funtoo/fuse-${VERSION_FUSE}.tar.gz
		mirror://funtoo/unionfs-fuse-${VERSION_UNIONFS_FUSE}.tar.bz2
		mirror://funtoo/gnupg-${VERSION_GPG}.tar.bz2"
GIT_TAG="81e80a81c3cb13fd9ee677b560c78b90e57a285c"
SRC_URI="$COMMON_URI https://code.funtoo.org/bitbucket/rest/api/latest/projects/CORE/repos/kernel-tools/archive?at=${GIT_TAG}&format=tgz -> ${P}-${GIT_TAG}.tar.gz"
KEYWORDS="*"
S="${WORKDIR}"

DESCRIPTION="Funtoo kernel tools"
HOMEPAGE="https://code.funtoo.org/bitbucket/projects/CORE/repos/kernel-tools/browse"

LICENSE="GPL-2"
SLOT="0"
IUSE="btrfs cryptsetup ibm selinux"

DEPEND="sys-fs/e2fsprogs
	selinux? ( sys-libs/libselinux )
	sys-apps/busybox[-pam,static]"
RDEPEND="${DEPEND}
		!sys-kernel/genkernel
		btrfs? ( sys-fs/btrfs-progs )
		cryptsetup? ( sys-fs/cryptsetup[static] )
		sys-fs/lvm2[static]
		sys-fs/mdadm[static]
		app-misc/pax-utils
		!<sys-apps/openrc-0.9.9"

src_compile() {
	return
}

src_install() {
	# This block updates genkernel.conf
	sed \
		-e "s:VERSION_MDADM:$VERSION_MDADM:" \
		-e "s:VERSION_DMRAID:$VERSION_DMRAID:" \
		-e "s:VERSION_E2FSPROGS:$VERSION_E2FSPROGS:" \
		-e "s:VERSION_FUSE:$VERSION_FUSE:" \
		-e "s:VERSION_ISCSI:$VERSION_ISCSI:" \
		-e "s:VERSION_UNIONFS_FUSE:$VERSION_UNIONFS_FUSE:" \
		-e "s:VERSION_GPG:$VERSION_GPG:" \
		"${S}"/genkernel.conf > "${T}"/genkernel.conf \
		|| die "Could not adjust versions"
	insinto /etc
	doins "${T}"/genkernel.conf || die "doins genkernel.conf"

	doman genkernel.8 || die "doman"
	dodoc ChangeLog.rst COPYRIGHT.rst || die "dodoc"

	dobin genkernel || die "dobin genkernel"

	rm -f genkernel genkernel.8

	insinto /usr/share/genkernel
	doins -r "${S}"/* || die "doins"

	# Copy files to /usr/share/genkernel/src
	elog "Copying files to /usr/share/genkernel/src..."
	mkdir -p "${D}"/usr/share/genkernel/src
	cp -f \
		"${DISTDIR}"/dmraid-${VERSION_DMRAID}.tar.bz2 \
		"${DISTDIR}"/e2fsprogs-${VERSION_E2FSPROGS}.tar.gz \
		"${DISTDIR}"/fuse-${VERSION_FUSE}.tar.gz \
		"${DISTDIR}"/unionfs-fuse-${VERSION_UNIONFS_FUSE}.tar.bz2 \
		"${DISTDIR}"/gnupg-${VERSION_GPG}.tar.bz2 \
		"${DISTDIR}"/open-iscsi-${VERSION_ISCSI}.tar.gz \
		"${D}"/usr/share/genkernel/src || die "Copying distfiles..."
	newbashcomp "${FILESDIR}"/genkernel.bash "genkernel"
	insinto /etc
	doins "${FILESDIR}"/initramfs.mounts
}
