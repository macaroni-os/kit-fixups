# Copyright 2023 gordonb3 <gordon@bosvangennip.nl> <-- Funtoo, preserve
# this as it is a specific person not "Gentoo Authors".
# Distributed under the terms of the GNU General Public License v2

# Funtoo notes:

# This ebuild requires perl[ithread], and after doing this, you will need to do a perl-cleaner --reallyall
# to rebuild all perl modules.

# I had issues with Transporter and FLAC using Tidal, where some Tidal songs would sometimes be choppy. 
# I believe this was an issue with the FLAC encoding used by Tidal being too "high" or non-standard for
# the Transporter. Symptoms are the spectrum analyzer getting "choppy", probably due to too much CPU
# being used on the player.
#
# To fix this, I did various things, some or all are required:
# 1. Emerged media-sound/flac which was missing, and is used by /opt/logitechmediaserver/convert.conf.
# 2. As per https://forums.slimdevices.com/forum/user-forums/logitech-media-server/1631018-24-96-from-local-source-stuttering-24-96-radio-stream-plays-just-fine?p=1631212#post1631212 --
#    I added the following to /opt/logitechmediaserver/convert.conf:
#    flc flc * 00:04:20:xx:xx:xx
# FT:{START=--skip=%t}U:{END=--until=%v}
# [flac] -cs1 $START$ $END$ -- $FILE$
# 3. In Server/File types, I unchecked "prefer native format", which I think is causing FLAC to go to PCM. 
# 4. Under Player Settings -> Extra Player Settings -> Streaming Method, I changed to "Proxied Streaming."
#
# Now, when I stream FLAC from Tidal, the spectrum analyzer is always super-fast and it looks like the FLAC
# is being converted to PCM directly using this line from convert.conf:
# 
# flc pcm * *
#     IFT:{START=--skip=%t}U:{END=--until=%v}
#     [flac] -dcs --force-raw-format --endian=little --sign=signed $START$ $END$ -- $FILE$

# I don't know if this means we are getting resampling when we don't want. I grepped for "endian=little" which I
# momentarily saw in the htop output when /usr/bin/flac was now being called directly.
# But sox is not installed, so this pipeline seems to immediately fail. Hmmm. Maybe emerging flac did it,
# or maybe the initial line did it. No, that's a mac address and I pasted it as-is, I think, so it wouldn't
# actually apply.

EAPI="7"

inherit user

MY_PV="${PV/_*}"
MY_PF="${PN}-${MY_PV}"
S="${WORKDIR}/${MY_PF}-noCPAN"

SRC_URI="http://downloads.slimdevices.com/LogitechMediaServer_v${MY_PV}/${MY_PF}-noCPAN.tgz"
HOMEPAGE="http://www.mysqueezebox.com/"

KEYWORDS="*"
DESCRIPTION="Logitech Media Server (streaming audio server)"
LICENSE="${PN}"
RESTRICT="mirror"
SLOT="0"
IUSE="+mp3 +alac +wavpack +flac +ogg +aac mac freetype"

PATCHES=(
	"${FILESDIR}/LMS_replace_UUID-Tiny_with_Data-UUID.patch"
	"${FILESDIR}/LMS-perl-recent.patch"
	"${FILESDIR}/LMS-8.0.0_remove_softlink_target_check.patch"
	"${FILESDIR}/LMS-8.2.0_move_client_playlist_path.patch"
)

EXTRALANGS="he"
for LANG in ${EXTRALANGS}; do
	IUSE="$IUSE l10n_${LANG}"
done

# Installation dependencies.
DEPEND="
	!media-sound/squeezecenter
	!media-sound/squeezeboxserver
	!media-sound/${PN}-bin
	app-arch/unzip
	dev-lang/nasm
"

# Runtime dependencies.
RDEPEND="
	virtual/logger
	dev-db/sqlite
	>=dev-lang/perl-5.8.8[ithreads]
	>=dev-perl/Data-UUID-1.202
	>=dev-perl/Audio-Scan-1.20.0
	>=dev-perl/Class-XSAccessor-1.180.0
	dev-perl/CGI
	dev-perl/Class-C3-XS
	dev-perl/DBD-SQLite
	dev-perl/DBI
	dev-perl/Digest-SHA1
	dev-perl/Encode-Detect
	dev-perl/EV
	dev-perl/HTML-Parser
	dev-perl/Image-Scale[gif,jpeg,png]
	dev-perl/IO-AIO
	dev-perl/IO-Interface
	dev-perl/JSON-XS
	dev-perl/Linux-Inotify2
	dev-perl/Sub-Name
	dev-perl/Template-Toolkit[gd]
	dev-perl/XML-Parser
	dev-perl/YAML-LibYAML
	dev-perl/MP3-Cut-Gapless
	l10n_he? ( dev-perl/Locale-Hebrew )
	mp3? ( media-sound/lame )
	wavpack? ( media-sound/wavpack )
	flac? (
		media-libs/flac
		media-sound/sox[flac]
	)
	ogg? ( media-sound/sox[ogg] )
	aac? ( media-libs/slim-faad )
	alac? ( media-libs/slim-faad )
	mac? ( media-sound/mac )
	freetype? ( dev-perl/Font-FreeType )
"

RUN_UID=${PN}
RUN_GID=${PN}

# Installation target locations
BINDIR="/opt/${PN}"
DATADIR="/var/lib/${PN}"
CACHEDIR="${DATADIR}/cache"
USRPLUGINSDIR="${DATADIR}/Plugins"
SVRPLUGINSDIR="${CACHEDIR}/InstalledPlugins"
CLIENTPLAYLISTSDIR="${DATADIR}/ClientPlaylists"
PREFSDIR="${DATADIR}/preferences"
LOGDIR="/var/log/${PN}"
SVRPREFS="${PREFSDIR}/server.prefs"

# Old Squeezebox Server file locations
SBS_PREFSDIR="/etc/squeezeboxserver/prefs"
SBS_SVRPREFS="${SBS_PREFSDIR}/server.prefs"
SBS_VARLIBDIR="/var/lib/squeezeboxserver"
SBS_SVRPLUGINSDIR="${SBS_VARLIBDIR}/cache/InstalledPlugins"
SBS_USRPLUGINSDIR="${SBS_VARLIBDIR}/plugins"

# Original preferences location from the Squeezebox overlay
R1_PREFSDIR="/etc/${PN}"


# Use of DynaLoader causes conflicts because it prefers the system
# perl folders over the local CPAN folder. Following is a list of
# folders and files that we always want to remove from the LMS
# distributed CPAN modules because they are pulled in by our listed
# dependencies.
OBSOLETEDIRS=(
	"Audio"
	"Class/XSAccessor"
	"DBD"
	"DBI/Const"
	"DBI/DBD"
	"DBI/ProfileDumper"
	"Encode/Detect"
	"Image"
	"IO/Interface"
	"Locale"
	"Media"
	"MP3"
	"Sub"
	"Template/Namespace"
	"Template/Stash"
	"UUID"
	"XML/Parser"
	"YAML/XS"
	"arch"
	"common"
)

OBSOLETEFILES=(
	"Class/C3/XS.pm"
	"Class/XSAccessor.pm"
	"DBI/Profile.pm"
	"DBI/ProfileData.pm"
	"DBI/ProfileDumper.pm"
	"DBI/ProfileSubs.pm"
	"DBI/DBD.pm"
	"Digest/SHA1.pm"
	"JSON/XS/Boolean.pm"
	"JSON/XS.pm"
	"HTML/Entities.pm"
	"HTML/Filter.pm"
	"HTML/HeadParser.pm"
	"HTML/LinkExtor.pm"
	"HTML/Parser.pm"
	"HTML/PullParser.pm"
	"HTML/TokeParser.pm"
	"IO/AIO.pm"
	"IO/Interface.pm"
	"Linux/Inotify2.pm"
	"Template/Plugin/Assert.pm"
	"Template/Plugin/CGI.pm"
	"Template/Plugin/Datafile.pm"
	"Template/Plugin/Date.pm"
	"Template/Plugin/Directory.pm"
	"Template/Plugin/Dumper.pm"
	"Template/Plugin/File.pm"
	"Template/Plugin/Filter.pm"
	"Template/Plugin/Format.pm"
	"Template/Plugin/HTML.pm"
	"Template/Plugin/Image.pm"
	"Template/Plugin/Iterator.pm"
	"Template/Plugin/Math.pm"
	"Template/Plugin/Pod.pm"
	"Template/Plugin/Procedural.pm"
	"Template/Plugin/String.pm"
	"Template/Plugin/Scalar.pm"
	"Template/Plugin/Table.pm"
	"Template/Plugin/URL.pm"
	"Template/Plugin/View.pm"
	"Template/Plugin/Wrap.pm"
	"Template/Base.pm"
	"Template/Config.pm"
	"Template/Constants.pm"
	"Template/Context.pm"
	"Template/Directive.pm"
	"Template/Document.pm"
	"Template/Exception.pm"
	"Template/Filters.pm"
	"Template/Grammar.pm"
	"Template/Iterator.pm"
	"Template/Parser.pm"
	"Template/Plugin.pm"
	"Template/Plugins.pm"
	"Template/Service.pm"
	"Template/Stash.pm"
	"Template/Test.pm"
	"Template/View.pm"
	"Template/VMethods.pm"
	"XML/Parser.pm"
	"YAML/Dumper/Syck.pm"
	"YAML/Loader/Syck.pm"
	"YAML/XS.pm"
	"DBI.pm"
	"EV.pm"
	"Template.pm"
)

src_prepare() {
	default	

	# fix default user name to run as
	sed -e "s/squeezeboxserver/${RUN_UID}/" -i slimserver.pl

	# merge the secondary lib folder into CPAN, keeping track of the various locations
	# for CPAN modules is hard enough already without it.
	elog "Merging lib and CPAN folders together"
	cp -aR lib/* CPAN/
	rm -rf lib
	sed -e "/catdir(\$libPath,'lib'),/d" -i Slim/bootstrap.pm

	# Delete files that our dependencies have placed in the system's Perl vendor path
	elog "Remove CPAN modules that conflict with arch specific modules in the system vendor path"
	for DIR in ${OBSOLETEDIRS[@]} ; do
		rm -rf CPAN/${DIR}
	done
	for FILE in ${OBSOLETEFILES[@]} ; do
		rm -f CPAN/${FILE}
	done
}

src_install() {
	# Everything in our package into the /opt hierarchy
	elog "Installing package files"
	dodir "${BINDIR}"
	cp -aR ${S}/* "${ED}/${BINDIR}" || die "Unable to install package files"
	rm ${ED}/${BINDIR}/{Changelog*,License*,README.md,SOCKS.txt}

	# The custom OS module for Gentoo - provides OS-specific path details
	elog "Import custom paths to match Gentoo specifications"
	cp "${FILESDIR}/gentoo-filepaths.pm" "${ED}/${BINDIR}/Slim/Utils/OS/Custom.pm" || die "Unable to install Gentoo custom OS module"
	fperms 644 "${BINDIR}/Slim/Utils/OS/Custom.pm"

	# Documentation
	dodoc Changelog*.html
	dodoc License*.txt
	dodoc "${FILESDIR}/Gentoo-plugins-README.txt"

	# Install init script (OpenRC)
	newinitd "${FILESDIR}/${PN}.init.d" "${PN}"
	newconfd "${FILESDIR}/${PN}.conf.d" "${PN}"

	# prepare data and log file locations
	elog "Set up log and data file locations"
	# Funtoo testing: ${PREFSDIR}/plugin is needed for raw-text prefs files, used by Slim/Utils/Light.pm:
	for TARGETDIR in ${LOGDIR} ${DATADIR} ${PREFSDIR} ${PREFSDIR}/plugin ${CACHEDIR} ${USRPLUGINSDIR} ${CLIENTPLAYLISTSDIR}; do
		keepdir ${TARGETDIR}
		fowners ${RUN_UID}:${RUN_GID} "${TARGETDIR}"
		fperms 770 "${TARGETDIR}"
	done
	for LOGFILE in server scanner perfmon; do
		touch "${ED}/${LOGDIR}/${LOGFILE}.log"
		fowners ${RUN_UID}:${RUN_GID} "${LOGDIR}/${LOGFILE}.log"
	done

	# Install logrotate support
	insinto /etc/logrotate.d
	newins "${FILESDIR}/${PN}.logrotate.d" "${PN}"
}

lms_starting_instr() {
	elog "Logitech Media Server can be started with the following command:"
	elog "\t/etc/init.d/${PN} start"
	elog ""
	elog "Logitech Media Server can be automatically started on each boot"
	elog "with the following command:"
	elog "\trc-update add ${PN} default"
	elog ""
	elog "You might want to examine and modify the following configuration"
	elog "file before starting Logitech Media Server:"
	elog "\t/etc/conf.d/${PN}"
	elog ""

	# Discover the port number from the preferences, but if it isn't there
	# then report the standard one.
	httpport=$(gawk '$1 == "httpport:" { print $2 }' "${ROOT}${SVRPREFS}" 2>/dev/null)
	elog "You may access and configure Logitech Media Server by browsing to:"
	elog "\thttp://localhost:${httpport:-9000}/"
	elog ""
}

pkg_setup() {
	enewgroup ${PN}
	enewuser ${PN} -1 -1 -1 ${PN}
}

pkg_postinst() {

	# Point user to database configuration step, if an old installation
	# of SBS is found.
	if [ -f "${SBS_SVRPREFS}" ]; then
		elog "If this is a new installation of Logitech Media Server and you"
		elog "previously used Squeezebox Server (media-sound/squeezeboxserver)"
		elog "then you may migrate your previous preferences and plugins by"
		elog "running the following command (note that this will overwrite any"
		elog "current preferences and plugins):"
		elog "\temerge --config =${CATEGORY}/${PF}"
		elog ""
	fi

	# Tell user where they should put any manually-installed plugins.
	elog "Manually installed plugins should be placed in the following"
	elog "directory:"
	elog "\t${USRPLUGINSDIR}"
	elog ""

	# Bug: LMS should not write to /etc
	# Move existing preferences from /etc to /var/lib
	if [ ! -f "${PREFSDIR}/server.prefs" ]; then
		if [ -d "${R1_PREFSDIR}" ]; then
			cp -r "${R1_PREFSDIR}"/* "${PREFSDIR}" || die "Failed to copy preferences"
			rm -r "${R1_PREFSDIR}"
			chown -R ${RUN_UID}.${RUN_GID} "${PREFSDIR}"
		fi
	fi

	# Show some instructions on starting and accessing the server.
	lms_starting_instr
}

lms_remove_db_prefs() {
	MY_PREFS=$1

	einfo "Correcting database connection configuration:"
	einfo "\t${MY_PREFS}"
	TMPPREFS="${T}"/lmsserver-prefs-$$
	touch "${EROOT}${MY_PREFS}"
	sed -e '/^dbusername:/d' -e '/^dbpassword:/d' -e '/^dbsource:/d' < "${EROOT}${MY_PREFS}" > "${TMPPREFS}"
	mv "${TMPPREFS}" "${EROOT}${MY_PREFS}"
	chown ${RUN_UID}:${RUN_GID} "${EROOT}${MY_PREFS}"
	chmod 660 "${EROOT}${MY_PREFS}"
}

lms_clean_oldfiles() {
	einfo "locating "
	MY_PERL_VENDORPATH=$(LANG="en_US.UTF-8" LC_ALL="en_US.UTF-8" perl -V | grep vendorarch | sed "s/^.*vendorarch=//" | sed "s/ .*$//g")
	cd ${MY_PERL_VENDORPATH}
	find -type f | sed "s/^\.\///" | grep -v "/DBIx/" | while read file; do 
		if [ -f ${EROOT}${BINDIR}/CPAN/${file} ]; then
			rm -v ${EROOT}${BINDIR}/CPAN/${file}
		fi
	done
	cd - &>/dev/null

	# delete empty directories in LMS path
	cd ${EROOT}${BINDIR}
	MY_SEARCHDEPTH=5
	while [  ${MY_SEARCHDEPTH} -gt 0 ]; do
		find -mindepth ${MY_SEARCHDEPTH} -maxdepth ${MY_SEARCHDEPTH} -type d -empty -exec rmdir -v {} \;
		MY_SEARCHDEPTH=$((MY_SEARCHDEPTH-1))
	done
	cd - &>/dev/null
}

pkg_config() {
	einfo "Press ENTER to migrate any preferences from a previous installation of"
	einfo "Squeezebox Server (media-sound/squeezeboxserver) to this installation"
	einfo "of Logitech Media Server."
	einfo ""
	einfo "Note that this will remove any current preferences and plugins and"
	einfo "therefore you should take a backup if you wish to preseve any files"
	einfo "from this current Logitech Media Server installation."
	einfo ""
	einfo "Alternatively, press Control-C to abort now..."
	read

	# Preferences.
	einfo "Migrating previous Squeezebox Server configuration:"
	if [ -f "${SBS_SVRPREFS}" ]; then
		[ -d "${EROOT}${PREFSDIR}" ] && rm -rf "${EROOT}${PREFSDIR}"
		einfo "\tPreferences (${SBS_PREFSDIR})"
		cp -r "${EROOT}${SBS_PREFSDIR}" "${EROOT}${PREFSDIR}"
		chown -R ${RUN_UID}:${RUN_GID} "${EROOT}${PREFSDIR}"
		chmod -R u+w,g+w "${EROOT}${PREFSDIR}"
		chmod 770 "${EROOT}${PREFSDIR}"
	fi

	# Plugins installed through the built-in extension manager.
	if [ -d "${EROOT}${SBS_SVRPLUGINSDIR}" ]; then
		einfo "\tServer plugins (${SBS_SVRPLUGINSDIR})"
		[ -d "${EROOT}${SVRPLUGINSDIR}" ] && rm -rf "${EROOT}${SVRPLUGINSDIR}"
		cp -r "${EROOT}${SBS_SVRPLUGINSDIR}" "${EROOT}${SVRPLUGINSDIR}"
		chown -R ${RUN_UID}:${RUN_GID} "${EROOT}${SVRPLUGINSDIR}"
		chmod -R u+w,g+w "${EROOT}${SVRPLUGINSDIR}"
		chmod 770 "${EROOT}${SVRPLUGINSDIR}"
	fi

	# Plugins manually installed by the user.
	if [ -d "${EROOT}${SBS_USRPLUGINSDIR}" ]; then
		einfo "\tUser plugins (${SBS_USRPLUGINSDIR})"
		[ -d "${EROOT}${USRPLUGINSDIR}" ] && rm -rf "${EROOT}${USRPLUGINSDIR}"
		cp -r "${EROOT}${SBS_USRPLUGINSDIR}" "${EROOT}${USRPLUGINSDIR}"
		chown -R ${RUN_UID}:${RUN_GID} "${EROOT}${USRPLUGINSDIR}"
		chmod -R u+w,g+w "${EROOT}${USRPLUGINSDIR}"
		chmod 770 "${EROOT}${USRPLUGINSDIR}"
	fi

	# Remove the existing MySQL preferences from Squeezebox Server (if any).
	lms_remove_db_prefs "${SVRPREFS}"

	# Scan system for possible version conflicts
	lms_clean_oldfiles

	# Phew - all done. Give some tips on what to do now.
	einfo "Done."
	einfo ""
}
