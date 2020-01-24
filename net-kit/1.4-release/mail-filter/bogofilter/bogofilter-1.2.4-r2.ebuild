# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools flag-o-matic toolchain-funcs

DESCRIPTION="Bayesian spam filter designed with fast algorithms, and tuned for speed"
HOMEPAGE="http://bogofilter.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="+berkdb sqlite tokyocabinet"
REQUIRED_USE="^^ ( berkdb sqlite tokyocabinet )"

# pax needed for bf_tar
DEPEND="
	app-arch/pax
	sci-libs/gsl:=
	virtual/libiconv
	berkdb?  ( sys-libs/db:18.1 )
	sqlite?  ( >=dev-db/sqlite-3.6.22 )
	tokyocabinet? ( dev-db/tokyocabinet )
"
RDEPEND="${DEPEND}"

PATCHES=( 
	"${FILESDIR}/${P}-test-env.patch"
	"${FILESDIR}/bogofilter-1.2.4-db-18.1.patch"
)

src_prepare() {
	default

	# bug 445918
	sed -i -e 's/ -ggdb//' configure.ac || die

	# bug 421747
	chmod +x src/tests/t.{ctype,leakfind,lexer.qpcr,lexer.eoh,message_id,queue_id}

	# bug 654990
	sed -i -e 's/t.bulkmode//' \
		-e 's/t.dump.load//' \
		-e 's/t.nonascii.replace//' \
		src/tests/Makefile.am || die
	eautoreconf
}

src_configure() {

	# Please note that bogofilter has (or had) its own 'db detection logic' in
	# configure.ac. This has been removed (with a patch) and instead we hard-code
	# the build process to use db-18.1. This may be less than ideal as we don't
	# have a handy config option for it (yet) but it gets this build linking
	# properly in Funtoo.

	local myconf=""
	myconf="--without-included-gsl"
	if use berkdb; then
		myconf="${myconf} --with-database=db"
		append-cppflags "-I/usr/include/db18.1"
	elif use sqlite ; then
		myconf="${myconf} --with-database=sqlite"
	elif use tokyocabinet ; then
		myconf="${myconf} --with-database=tokyocabinet"
	fi
	econf ${myconf}
}

src_test() {
	emake -C src/ check
}

src_install() {
	emake DESTDIR="${D}" install

	exeinto /usr/share/${PN}/contrib
	doexe contrib/{bogofilter-qfe,parmtest,randomtrain}.sh \
		contrib/{bfproxy,bogominitrain,mime.get.rfc822,printmaildir}.pl \
		contrib/{spamitarium,stripsearch}.pl

	insinto /usr/share/${PN}/contrib
	doins contrib/{README.*,dot-qmail-bogofilter-default} \
		contrib/{bogogrep.c,bogo.R,bogofilter-milter.pl,*.example} \
		contrib/vm-bogofilter.el \
		contrib/{trainbogo,scramble}.sh

	dodoc AUTHORS NEWS README RELEASE.NOTES* TODO GETTING.STARTED \
		doc/integrating-with-* doc/README.{db,sqlite}

	dodoc -r doc/*.html

	dodir /usr/share/doc/${PF}/samples
	mv "${D}"/etc/bogofilter.cf.example "${D}"/usr/share/doc/${PF}/samples/ || die
	rmdir "${D}"/etc || die
}
