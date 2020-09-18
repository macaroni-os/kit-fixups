# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic systemd toolchain-funcs user

DESCRIPTION="A persistent caching system, key-value and data structures database"
HOMEPAGE="https://redis.io"
SRC_URI="http://download.redis.io/releases/${P}.tar.gz"

LICENSE="BSD"
KEYWORDS="*"
IUSE="+jemalloc tcmalloc luajit split-conf +ssl test"
SLOT="0"

# Redis does NOT build with Lua 5.2 or newer at this time.
# This should link correctly with both unslotted & slotted Lua, without
# changes.
RDEPEND="
	luajit? ( dev-lang/luajit:2 )
	!luajit? ( || ( dev-lang/lua:5.1 =dev-lang/lua-5.1*:0 ) )
	tcmalloc? ( dev-util/google-perftools )
	jemalloc? ( >=dev-libs/jemalloc-5.1:= )"

BDEPEND="
	${RDEPEND}
	virtual/pkgconfig"

# Tcl is only needed in the CHOST test env
DEPEND="${RDEPEND}
	test? ( dev-lang/tcl:0= )"

REQUIRED_USE="?? ( tcmalloc jemalloc )"
PATCHES=(
	"${FILESDIR}"/${PN}-3.2.3-config.patch
	"${FILESDIR}"/${PN}-5.0-shared.patch
	"${FILESDIR}"/${PN}-6.0.3-sharedlua.patch
	"${FILESDIR}"/${PN}-5.0.8-ppc-atomic.patch
	"${FILESDIR}"/${PN}-sentinel-5.0-config.patch
)

pkg_setup() {
	if egetent group ${PN} > /dev/null ; then
		elog "${PN} group already exist."
		elog "group creation step skipped."
	else
		enewgroup  ${PN} > /dev/null
		elog "${PN} group created by portage."
	fi

        if egetent passwd  ${PN} > /dev/null ; then
                elog "${PN} user already exist."
                elog "user creation step skipped."
        else
                enewuser ${PN} -1 -1 /dev/null ${PN} > /dev/null
                elog "${PN} user with ${NGINX_HOME} home"
                elog "was created by portage."
        fi


}

src_prepare() {
	default

	# unstable on jemalloc
	> tests/unit/memefficiency.tcl || die

	# Copy lua modules into build dir
	cp "${S}"/deps/lua/src/{fpconv,lua_bit,lua_cjson,lua_cmsgpack,lua_struct,strbuf}.c "${S}"/src || die
	cp "${S}"/deps/lua/src/{fpconv,strbuf}.h "${S}"/src || die
	# Append cflag for lua_cjson
	# https://github.com/antirez/redis/commit/4fdcd213#diff-3ba529ae517f6b57803af0502f52a40bL61
	append-cflags "-DENABLE_CJSON_GLOBAL"

	# now we will rewrite present Makefiles
	local makefiles="" MKF
	for MKF in $(find -name 'Makefile' | cut -b 3-); do
		mv "${MKF}" "${MKF}.in"
		sed -i	-e 's:$(CC):@CC@:g' \
			-e 's:$(CFLAGS):@AM_CFLAGS@:g' \
			-e 's: $(DEBUG)::g' \
			-e 's:$(OBJARCH)::g' \
			-e 's:ARCH:TARCH:g' \
			-e '/^CCOPT=/s:$: $(LDFLAGS):g' \
			"${MKF}.in" \
		|| die "Sed failed for ${MKF}"
		makefiles+=" ${MKF}"
	done
	# autodetection of compiler and settings; generates the modified Makefiles
	cp "${FILESDIR}"/configure.ac-3.2 configure.ac || die

	# Use the correct pkgconfig name for Lua
	if false && has_version 'dev-lang/lua:5.3'; then
		# Lua5.3 gives:
		#lua_bit.c:83:2: error: #error "Unknown number type, check LUA_NUMBER_* in luaconf.h"
		LUAPKGCONFIG=lua5.3
	elif false && has_version 'dev-lang/lua:5.2'; then
		# Lua5.2 fails with:
		# scripting.c:(.text+0x1f9b): undefined reference to `lua_open'
		# Because lua_open because lua_newstate in 5.2
		LUAPKGCONFIG=lua5.2
	elif has_version 'dev-lang/lua:5.1'; then
		LUAPKGCONFIG=lua5.1
	else
		LUAPKGCONFIG=lua
	fi
	# The upstream configure script handles luajit specially, and is not
	# effected by these changes.
	einfo "Selected LUAPKGCONFIG=${LUAPKGCONFIG}"
	sed -i	\
		-e "/^AC_INIT/s|, [0-9].+, |, $PV, |" \
		-e "s:AC_CONFIG_FILES(\[Makefile\]):AC_CONFIG_FILES([${makefiles}]):g" \
		-e "/PKG_CHECK_MODULES.*\<LUA\>/s,lua5.1,${LUAPKGCONFIG},g" \
		configure.ac || die "Sed failed for configure.ac"
	eautoreconf
}

src_configure() {
	econf $(use_with luajit)
	
	# Linenoise can't be built with -std=c99, see https://bugs.gentoo.org/451164
	# also, don't define ANSI/c99 for lua twice
	sed -i -e "s:-std=c99::g" deps/linenoise/Makefile deps/Makefile || die

}

src_compile() {
	local myconf=""

	if use jemalloc; then
		myconf+="MALLOC=jemalloc "
	elif use tcmalloc; then
		myconf+="MALLOC=tcmalloc "
	else
		myconf+="MALLOC=libc "
	fi
	
	if use ssl; then
        myconf+="BUILD_TLS=yes "
    fi

#	emake ${myconf} V=1 CC="${CC}" AR="${AR} rcu" RANLIB="${RANLIB}"
	tc-export CC
	emake V=1 ${myconf} CC="${CC}"
}

src_install() {
	
    keepdir "${EROOT}etc/${PN}"
    keepdir "${EROOT}etc/${PN}/conf"
	
	if use split-conf; then
        insinto "${EROOT}etc/${PN}"
        doins sentinel.conf
        
        newins "${FILESDIR}/redis_split.conf" "${PN}.conf"
        insinto "${EROOT}etc/${PN}/conf"
        newins "${FILESDIR}/10_general.conf"    10_general.conf
        newins "${FILESDIR}/10_memory.conf"     10_memory.conf
        newins "${FILESDIR}/10_network.conf"    10_network.conf
        newins "${FILESDIR}/10_security.conf"   10_security.conf
        newins "${FILESDIR}/10_snapshot.conf"   10_snapshot.conf
        newins "${FILESDIR}/10_ssl.conf"        10_ssl.conf
        newins "${FILESDIR}/20_cluster.conf"    20_cluster.conf
        newins "${FILESDIR}/20_replication.conf"    20_replication.conf
        newins "${FILESDIR}/30_advance_config.conf" 30_advance_config.conf
        newins "${FILESDIR}/30_append.conf"         30_append.conf
        newins "${FILESDIR}/30_defragmentation.conf" 30_defragmentation.conf
        newins "${FILESDIR}/30_latency.conf"    30_latency.conf
        newins "${FILESDIR}/30_lazy.conf"   30_lazy.conf
        newins "${FILESDIR}/30_nat.conf"    30_nat.conf
        newins "${FILESDIR}/30_slowlog.conf"    30_slowlog.conf
        newins "${FILESDIR}/30_threads.conf"    30_threads.conf
        newins "${FILESDIR}/40_event.conf"  40_event.conf
        newins "${FILESDIR}/40_gopher.conf" 40_gopher.conf
        newins "${FILESDIR}/40_keys_tracking.conf" 40_keys_tracking.conf
        newins "${FILESDIR}/40_lua.conf"    40_lua.conf
      
	else
      insinto "${EROOT}etc/${PN}"
      doins redis.conf sentinel.conf
	fi
	
	use prefix || fowners redis:redis "${EROOT}/etc/${PN}/"{redis,sentinel}.conf
	fperms 0644 "${EROOT}/etc/${PN}/"{redis,sentinel}.conf

	newconfd "${FILESDIR}/redis.confd-r1" redis
	newinitd "${FILESDIR}/redis.initd-5" redis

	systemd_newunit "${FILESDIR}/redis.service-3" redis.service
	systemd_newtmpfilesd "${FILESDIR}/redis.tmpfiles-2" redis.conf

	newconfd "${FILESDIR}/redis-sentinel.confd" redis-sentinel
	newinitd "${FILESDIR}/redis-sentinel.initd" redis-sentinel

	insinto /etc/logrotate.d/
	newins "${FILESDIR}/${PN}.logrotate" ${PN}

	dodoc 00-RELEASENOTES BUGS CONTRIBUTING MANIFESTO README.md

	dobin src/redis-cli
	dosbin src/redis-benchmark src/redis-server src/redis-check-aof src/redis-check-rdb
	fperms 0750 /usr/sbin/redis-benchmark
	dosym redis-server /usr/sbin/redis-sentinel

	if use prefix; then
		diropts -m0750
	else
		diropts -m0750 -o redis -g redis
	fi
	keepdir /var/{log,lib}/redis
}
