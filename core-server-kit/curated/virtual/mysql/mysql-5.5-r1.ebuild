# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="Virtual for MySQL client or database"
SLOT="0"
KEYWORDS="*"
IUSE="embedded minimal static static-libs"

RDEPEND="|| (
	=dev-db/mariadb-${PV}*[embedded=,minimal=,static=,static-libs=]
	=dev-db/mysql-${PV}*[embedded=,minimal=,static=,static-libs=]
	=dev-db/mysql-cluster-7.2*[embedded=,minimal=,static=,static-libs=]
)"
