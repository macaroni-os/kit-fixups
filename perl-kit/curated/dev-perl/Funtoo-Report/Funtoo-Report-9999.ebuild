# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit perl-module

DESCRIPTION="Anonymous reporting tool for Funtoo Linux"
HOMEPAGE="https://github.com/haxmeister/funtoo-reporter"

if [[ ${PV} == 9999* ]]; then
        inherit git-r3
        EGIT_REPO_URI="https://github.com/haxmeister/funtoo-reporter.git"
        EGIT_BRANCH="develop"
        SRC_URI=""
        KEYWORDS=""
else
        SRC_URI="https://github.com/haxmeister/funtoo-reporter/archive/v${PV}.tar.gz -> ${P}.tar.gz"
        KEYWORDS="*"
        S="${WORKDIR}/funtoo-reporter-${PV}"
fi

LICENSE="MIT"
SLOT="0"
IUSE=""

RDEPEND="
		dev-perl/JSON
		sys-apps/pciutils
"

src_compile() {
	pod2man funtoo-report > funtoo-report.1 || die "pod2man failed"
	pod2man lib/Funtoo/Report.pm > Funtoo::Report.3 || die "pod2man failed"
}

src_install() {
	insinto /etc
	doins "${FILESDIR}/funtoo-report.conf"
	dodoc README.md
	doman funtoo-report.1
	doman Funtoo::Report.3
	perl-module_src_install
}

pkg_postinst() {
	elog "The Funtoo Reporter comes with a default config file that can be found in /etc/funtoo-report.conf"
	elog "You can review what information gets submitted and generate/update your config file"
	elog "using the tool directly by issuing:"
	echo
	elog "funtoo-report config-update"
	echo
	elog "You can setup a cron job to submit your information on regular basis."
	elog "The data collected are submitted with a timestamp, so we can follow the changes (kits used, profile usage ...) in time."
	elog "Here is a sample cron job definition to put into your crontab:"
	echo
	elog "0 * * * * /usr/bin/funtoo-report send"
	echo
	elog "This would send data every hour to our database."
}
