# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="PAM base configuration files (virtual)"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="cracklib debug minimal mktemp nullok pam_krb5 pam_ssh passwdqc securetty selinux sha512"

RDEPEND="
>=sys-libs/pam-1.3.1.20190226
cracklib? ( sys-libs/pam[cracklib=] )
debug? ( sys-libs/pam[debug=] )
minimal? ( sys-libs/pam[minimal=] )
mktemp? ( sys-libs/pam[mktemp=] )
nullok? ( sys-libs/pam[nullok=] )
pam_krb5? ( sys-libs/pam[pam_krb5=] )
pam_ssh? ( sys-libs/pam[pam_ssh=] )
passwdqc? ( sys-libs/pam[passwdqc=] )
securetty? ( sys-libs/pam[securetty=] )
selinux? ( sys-libs/pam[selinux=] )
sha512? ( sys-libs/pam[sha512=] )
"
