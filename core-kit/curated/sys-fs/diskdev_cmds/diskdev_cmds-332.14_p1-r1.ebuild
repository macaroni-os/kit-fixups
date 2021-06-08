# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

MY_PV=${PV%_p*}

DESCRIPTION="HFS and HFS+ utils ported from OSX, supplies mkfs and fsck"
HOMEPAGE="http://opendarwin.org"
SRC_URI="http://darwinsource.opendarwin.org/tarballs/apsl/diskdev_cmds-${MY_PV}.tar.gz
		 mirror://gentoo/diskdev_cmds-${PV}.patch.bz2"
LICENSE="APSL-2"
SLOT="0"
KEYWORDS="*"
DEPEND="dev-libs/openssl:0="
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-${MY_PV}"

PATCHES=(
	"${WORKDIR}"/diskdev_cmds-${PV}.patch
	"${FILESDIR}"/${PN}-respect-cflags.patch
	"${FILESDIR}"/${P}-AR.patch
	"${FILESDIR}"/${P}-no-sysctl.patch
	"${FILESDIR}"/${P}-ldflags.patch
	"${FILESDIR}"/${P}-musl.patch
)

src_compile() {
	emake -f Makefile.lnx AR="$(tc-getAR)" CC="$(tc-getCC)" || die "emake failed"
}

src_install() {
	into /
	dosbin fsck_hfs.tproj/fsck_hfs || die "dosbin fsck failed"
	dosbin newfs_hfs.tproj/newfs_hfs || die "dosbin newfs failed"
	dosym /sbin/newfs_hfs /sbin/mkfs.hfs || die "dosym mkfs.hfs failed"
	dosym /sbin/newfs_hfs /sbin/mkfs.hfsplus || die "dosym mkfs.hfsplus failed"
	dosym /sbin/fsck_hfs /sbin/fsck.hfs || die "dosym fsck.hfs failed"
	dosym /sbin/fsck_hfs /sbin/fsck.hfsplus || die "dosym fsck.hfsplus failed"
	doman newfs_hfs.tproj/newfs_hfs.8 || die "doman newfs_hfs.8 failed"
	newman newfs_hfs.tproj/newfs_hfs.8 mkfs.hfs.8 || die "doman mkfs.hfs.8 failed"
	newman newfs_hfs.tproj/newfs_hfs.8 mkfs.hfsplus.8 || die "doman mkfs.hfsplus.8 failed"
	doman fsck_hfs.tproj/fsck_hfs.8 || die "doman fsck_hfs.8 failed"
	newman fsck_hfs.tproj/fsck_hfs.8 fsck.hfs.8 || die "doman fsck.hfs.8 failed"
	newman fsck_hfs.tproj/fsck_hfs.8 fsck.hfsplus.8 || die "doman fsck.hfsplus.8 failed"
}
