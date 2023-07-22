# Copyright 2022 gordonb3 <gordon@bosvangennip.nl>
# Distributed under the terms of the GNU General Public License v2
#
# $Header$

EAPI="8"
inherit perl-module

DESCRIPTION="DLNA server support for LogitechMediaServer"
HOMEPAGE="https://github.com/andygrundman/"
SLOT=0
KEYWORDS="~amd64 ~x86 ~arm ~ppc"
RESTRICT="mirror"

PVLMS=${PV%.0}

# software versions of libraries that need to be statically linked in
PVDB=5.1.25
PVFFMPEG=0.8.4
PVGIF=4.1.6
PVJPEG=8b
PVEXIF=0.6.20
PVPNG=1.6.37

SRC_URI="
	https://github.com/Logitech/slimserver-vendor/raw/public/8.3/CPAN/libmediascan-${PVLMS}.tar.gz
	https://github.com/Logitech/slimserver-vendor/raw/public/8.3/CPAN/db-${PVDB}.tar.gz
	https://github.com/Logitech/slimserver-vendor/raw/public/8.3/CPAN/ffmpeg-${PVFFMPEG}.tar.bz2
	https://github.com/Logitech/slimserver-vendor/raw/public/8.3/CPAN/giflib-${PVGIF}.tar.gz
	https://github.com/Logitech/slimserver-vendor/raw/public/8.3/CPAN/jpegsrc.v${PVJPEG}.tar.gz
	https://github.com/Logitech/slimserver-vendor/raw/public/8.3/CPAN/libexif-${PVEXIF}.tar.bz2
	https://github.com/Logitech/slimserver-vendor/raw/public/8.3/CPAN/libpng-${PVPNG}.tar.gz
"

S=${WORKDIR}/libmediascan-${PVLMS}/bindings/perl
BUILD=${WORKDIR}/build
FLAGS="-fPIC -O3"

FFOPTS="--prefix=$BUILD --disable-ffmpeg --disable-ffplay --disable-ffprobe --disable-ffserver \
        --disable-avdevice --enable-pic \
        --disable-amd3dnow --disable-amd3dnowext --disable-mmx2 --disable-sse --disable-ssse3 --disable-avx \
        --disable-armv5te --disable-armv6 --disable-armv6t2 --disable-armvfp --disable-iwmmxt --disable-mmi --disable-neon \
        --disable-altivec \
        --disable-vis \
        --enable-zlib --disable-bzlib \
        --disable-everything --enable-swscale \
        --enable-decoder=h264 --enable-decoder=mpeg1video --enable-decoder=mpeg2video \
        --enable-decoder=mpeg4 --enable-decoder=msmpeg4v1 --enable-decoder=msmpeg4v2 \
        --enable-decoder=msmpeg4v3 --enable-decoder=vp6f --enable-decoder=vp8 \
        --enable-decoder=wmv1 --enable-decoder=wmv2 --enable-decoder=wmv3 --enable-decoder=rawvideo \
        --enable-decoder=mjpeg --enable-decoder=mjpegb --enable-decoder=vc1 \
        --enable-decoder=aac --enable-decoder=ac3 --enable-decoder=dca --enable-decoder=mp3 \
        --enable-decoder=mp2 --enable-decoder=vorbis --enable-decoder=wmapro --enable-decoder=wmav1 --enable-decoder=flv \
        --enable-decoder=wmav2 --enable-decoder=wmavoice \
        --enable-decoder=pcm_dvd --enable-decoder=pcm_s16be --enable-decoder=pcm_s16le \
        --enable-decoder=pcm_s24be --enable-decoder=pcm_s24le \
        --enable-decoder=ass --enable-decoder=dvbsub --enable-decoder=dvdsub --enable-decoder=pgssub --enable-decoder=xsub \
        --enable-parser=aac --enable-parser=ac3 --enable-parser=dca --enable-parser=h264 --enable-parser=mjpeg \
        --enable-parser=mpeg4video --enable-parser=mpegaudio --enable-parser=mpegvideo --enable-parser=vc1 \
        --enable-demuxer=asf --enable-demuxer=avi --enable-demuxer=flv --enable-demuxer=h264 \
        --enable-demuxer=matroska --enable-demuxer=mov --enable-demuxer=mpegps --enable-demuxer=mpegts --enable-demuxer=mpegvideo \
        --enable-protocol=file --cc=gcc --disable-mmx"

MSOPTS="--with-static \
        --with-ffmpeg-includes=$BUILD/include \
        --with-lms-includes=$BUILD/include \
        --with-exif-includes=$BUILD/include \
        --with-jpeg-includes=$BUILD/include \
        --with-png-includes=$BUILD/include \
        --with-gif-includes=$BUILD/include \
        --with-bdb-includes=$BUILD/include"


prereqs_configure() {
	# db
	cd ${WORKDIR}/db-${PVDB}/build_unix
	CFLAGS="$FLAGS" LDFLAGS="$FLAGS" ../dist/configure --prefix=$BUILD \
        --with-cryptography=no -disable-hash --disable-queue --disable-replication --disable-statistics --disable-verify \
        --disable-dependency-tracking --disable-shared

	#ffmpeg
	cd ${WORKDIR}/ffmpeg-${PVFFMPEG}
	CFLAGS="$FLAGS" LDFLAGS="$FLAGS" ./configure $FFOPTS

	#giflib
	cd ${WORKDIR}/giflib-${PVGIF}
	CFLAGS="$FLAGS" LDFLAGS="$FLAGS" ./configure --prefix=$BUILD --disable-dependency-tracking

	#libpng
	cd ${WORKDIR}/libpng-${PVPNG}
	CFLAGS="$FLAGS" LDFLAGS="$FLAGS" ./configure --prefix=$BUILD --disable-dependency-tracking

	#libjpeg
	cd ${WORKDIR}/jpeg-${PVJPEG}
	CFLAGS="$FLAGS" LDFLAGS="$FLAGS" ./configure --prefix=$BUILD --disable-dependency-tracking

	#libexif
	cd ${WORKDIR}/libexif-${PVEXIF}
	CFLAGS="$FLAGS" LDFLAGS="$FLAGS" ./configure --prefix=$BUILD --disable-dependency-tracking

	#main library
	cd ${WORKDIR}/libmediascan-${PVLMS}
	CFLAGS="$FLAGS -I$BUILD/include" \
        LDFLAGS="$FLAGS -L$BUILD/lib" \
        OBJCFLAGS="-L$BUILD/lib $FLAGS" \
        ./configure --prefix=$BUILD --disable-shared --disable-dependency-tracking
}

prereqs_compile() {
	# db
	cd ${WORKDIR}/db-${PVDB}/build_unix
	make
	make install

	#ffmpeg
	cd ${WORKDIR}/ffmpeg-${PVFFMPEG}
	make
	make install

	#giflib
	cd ${WORKDIR}/giflib-${PVGIF}
	make
	make install

	#libpng
	cd ${WORKDIR}/libpng-${PVPNG}
	make && make check
	make install

	#libjpeg
	cd ${WORKDIR}/jpeg-${PVJPEG}
	make
	make install

	#libexif
	cd ${WORKDIR}/libexif-${PVEXIF}
	make
	make install

	#main library
	cd ${WORKDIR}/libmediascan-${PVLMS}
	make
	make install
}

src_prepare() {
	eapply_user

	cd ${WORKDIR}
	eapply ${FILESDIR}/imageoptions.patch
}

src_configure() {
	prereqs_configure
	prereqs_compile
	
	cd ${S}
	myconf="$MSOPTS"
	perl-module_src_configure
}

src_compile() {
	cd ${S}
	perl-module_src_compile
}

src_install() {
	cd ${S}
	perl-module_src_install
}
