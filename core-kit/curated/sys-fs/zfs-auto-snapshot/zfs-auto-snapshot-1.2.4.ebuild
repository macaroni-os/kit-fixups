# Distributed under the terms of the GNU General Public License v2

EAPI=5

#inherit perl-module

DESCRIPTION="ZFS Automatic Snapshot Service for Linux"
HOMEPAGE="https://github.com/dajhorn/zfs-auto-snapshot/"

if [[ ${PV} == 9999* ]]; then
        inherit git-r3
        EGIT_REPO_URI="https://github.com/zfsonlinux/zfs-auto-snapshot.git"
        EGIT_BRANCH="master"
        SRC_URI=""
        KEYWORDS=""
else
        SRC_URI="https://github.com/zfsonlinux/zfs-auto-snapshot/archive/upstream/${PV}.tar.gz -> ${P}.tar.gz"
        KEYWORDS="*"
        S="${WORKDIR}/${PN}-upstream-${PV}"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE=""

RDEPEND="
		virtual/cron
		sys-fs/zfs
"

DOCS=( README )

src_install() {
	emake DESTDIR="${D}" PREFIX="${EPREFIX}/usr/" install
	dodoc ${DOCS}
}

pkg_postinst() {
	elog "Use attribute com.sun:auto-snapshot to decide which filesystem should be snapshotted"
	elog "Set attributes like this:"
	elog "zfs set com.sun:auto-snapshot=[true|false]"
	elog "or"
	elog "zfs set com.sun:auto-snapshot:<frequent|hourly|daily|weekly|monthly>=[true|false]"
	elog
	elog "eg."
	elog "# zfs set com.sun:auto-snapshot=false rpool"
	elog "# zfs set com.sun:auto-snapshot=true rpool"
	elog "# zfs set com.sun:auto-snapshot:weekly=true rpool"
	elog
	elog "For details please visit http://docs.oracle.com/cd/E19082-01/817-2271/ghzuk/"
	elog
	ewarn "If you are using fcron as your system crontab, frequent snapshot may not"
	ewarn "work. You should add the jobs manually to your systab or root tab."
	elog
	ewarn "*/15 * * * * zfs-auto-snapshot --default-exclude -q -g --label=frequent --keep=4  //"
	ewarn "*/15 * * * * zfs-auto-snapshot -q -g --label=frequent --keep=4  //"
	elog

}
