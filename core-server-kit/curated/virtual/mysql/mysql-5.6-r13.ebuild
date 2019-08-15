# Distributed under the terms of the GNU General Public License v2

EAPI="6"

DESCRIPTION="Virtual for MySQL database server"
SLOT="0/18"
KEYWORDS="*"
IUSE="embedded +server static"

RDEPEND="|| (
		>=dev-db/mariadb-10.0[embedded(-)?,server?,static?]
		>=dev-db/mysql-${PV}[embedded(-)?,server?,static?]
		dev-db/mysql-community
		>=dev-db/percona-server-${PV}[embedded(-)?,server?,static?]
		dev-db/mariadb-galera[embedded(-)?,server?,static?]
		>=dev-db/mysql-cluster-7.3[embedded(-)?,server?,static?]
	)
"
