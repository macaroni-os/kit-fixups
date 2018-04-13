# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit perl-module

DESCRIPTION="Anonymous reporting tool for Funtoo Linux"
HOMEPAGE="https://github.com/haxmeister/funtoo-reporter"

if [[ ${PV} == 9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/haxmeister/funtoo-reporter.git"
	EGIT_BRANCH="develop"
	SRC_URI=""
	KEYWORDS=""
	IUSE="test"
else
	SRC_URI="https://github.com/haxmeister/funtoo-reporter/archive/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="*"
	S="${WORKDIR}/funtoo-reporter-${PV}"
fi

LICENSE="MIT"
SLOT="0"
IUSE="${IUSE}"

RDEPEND="
	dev-perl/JSON
	sys-apps/pciutils
"

DIST_TEST="do parallel"

src_compile() {
	pod2man funtoo-report > funtoo-report.1 || die "pod2man failed"
	pod2man lib/Funtoo/Report.pm > funtoo-report.3 || die "pod2man failed"
	if [[ ${PV} == 9999* ]]; then
		./bump_version.sh describe
	fi
}

src_install() {
	insinto /etc
	doins "${FILESDIR}/funtoo-report.conf"
	dodoc README.md
	doman funtoo-report.1
	doman funtoo-report.3
	perl-module_src_install
}

pkg_postinst() {
if [[ ${PV} == 9999* ]]; then
	elog Funtoo Reporter - Development release
	elog ====================================================================
	elog WARNING: You are using a version that is tracking the $EGIT_BRANCH
	elog Things can be broken. If you want a stable release use version <9999
	elog ====================================================================
else
	elog Funtoo Reporter - Stable release
fi
	elog "The Funtoo Reporter comes with a default config file that can be found in /etc/funtoo-report.conf"
	elog "You can review what information gets submitted and generate/update your config file"
	elog "using the tool directly by issuing:"
	echo
	elog "funtoo-report -u"
	echo
	elog "You can setup a cron job to submit your information on regular basis."
	elog "The data collected are submitted with a timestamp, so changes can be followed in time (like kits used, profile usage ...)."
	elog "Here is a sample cron job definition to put into your crontab:"
	echo
	elog "0 * * * * /usr/bin/funtoo-report -s"
	echo
	elog "This would send data every hour to the database."
	echo
}
