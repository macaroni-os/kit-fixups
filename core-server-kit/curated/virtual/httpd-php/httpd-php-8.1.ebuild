# Distributed under the terms of the GNU General Public License v2

EAPI="6"

DESCRIPTION="Virtual to provide PHP-enabled webservers"
SLOT="${PV}"
KEYWORDS="*"

RDEPEND="|| ( dev-lang/php:${SLOT}[fpm]
			  dev-lang/php:${SLOT}[apache2]
			  dev-lang/php:${SLOT}[cgi] )"
