# Distributed under the terms of the GNU General Public License v2

EAPI=7

PHP_EXT_NAME="redis"
DOCS=( arrays.markdown cluster.markdown README.markdown CREDITS )
MY_P="${PN/pecl-/}-${PV/_rc/RC}"
PHP_EXT_PECL_FILENAME="${MY_P}.tgz"
PHP_EXT_S="${WORKDIR}/${MY_P}"

USE_PHP="php7-3 php7-4 php8-0 php8-1"

inherit php-ext-pecl-r3

KEYWORDS="*"

DESCRIPTION="PHP extension for interfacing with Redis"
LICENSE="PHP-3.01"
SLOT="0"
IUSE="igbinary +session msgpack zstd lzf"

DEPEND="
        php_targets_php7-3? (
                dev-lang/php:7.3[session?]
                igbinary? (
                        dev-php/igbinary[php_targets_php7-3]
                )
        )
        php_targets_php7-4? (
                dev-lang/php:7.4[session?]
                igbinary? (
                        dev-php/igbinary[php_targets_php7-4]
                )
        )
        php_targets_php8-0? (
                dev-lang/php:8.0[session?]
                igbinary? (
                        dev-php/igbinary[php_targets_php8-0]
                )
        )
        php_targets_php8-1? (
                dev-lang/php:8.1[session?]
                igbinary? (
                        dev-php/igbinary[php_targets_php8-1]
                )
        )
"

RDEPEND="${DEPEND} !dev-php/pecl-redis:7"

# The test suite requires network access.
RESTRICT=test

S="${WORKDIR}/${MY_P}"

src_configure() {
        local PHP_EXT_ECONF_ARGS=(
                --enable-redis
                $(use_enable igbinary redis-igbinary)
                $(use_enable session redis-session)
                $(use_enable msgpack redis-msgpack)
                $(use_enable zstd redis-zstd)
        )
        php-ext-source-r3_src_configure
}

src_test(){
        local slot
        for slot in $(php_get_slots); do
                php_init_slot_env "${slot}"
                # Run tests for Redis class
                ${PHPCLI} -d extension=modules/redis.so \
                                  tests/TestRedis.php \
                                  --class Redis \
                                  --host ${PECL_REDIS_HOST} || die 'test suite failed'
        done
}

pkg_postinst() {
        elog "The 4.0 release comes with breaking API changes."
        elog "Be sure to verify any applications upon upgrading."
}

