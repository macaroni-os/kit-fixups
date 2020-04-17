# Distributed under the terms of the GNU General Public License v2

EAPI=7

export CBUILD=${CBUILD:-${CHOST}}
export CTARGET=${CTARGET:-${CHOST}}

MY_PV=${PV/_/}

inherit toolchain-funcs

SRC_URI="https://storage.googleapis.com/golang/go${MY_PV}.src.tar.gz "
S="${WORKDIR}"/go
KEYWORDS="*"

DESCRIPTION="A concurrent garbage collected and typesafe programming language"
HOMEPAGE="https://golang.org"

LICENSE="BSD"
SLOT="0/${PV}"

BDEPEND="|| (
		dev-lang/go
		dev-lang/go-bootstrap )"

# Do not complain about CFLAGS, etc, since Go doesn't use them.
QA_FLAGS_IGNORED='.*'

# The tools in /usr/lib/go should not cause the multilib-strict check to fail.
QA_MULTILIB_PATHS="usr/lib/go/pkg/tool/.*/.*"

# Do not strip this package. Stripping is unsupported upstream and may
# fail.
RESTRICT+=" strip"

DOCS=(
AUTHORS
CONTRIBUTING.md
CONTRIBUTORS
PATENTS
README.md
)

go_arch()
{
	# By chance most portage arch names match Go
	local portage_arch=$(tc-arch $@)
	case "${portage_arch}" in
		x86)	echo 386;;
		x64-*)	echo amd64;;
		*)		echo "${portage_arch}";;
	esac
}

go_arm()
{
	case "${1:-${CHOST}}" in
		armv5*)	echo 5;;
		armv6*)	echo 6;;
		armv7*)	echo 7;;
		*)
			die "unknown GOARM for ${1:-${CHOST}}"
			;;
	esac
}

go_os()
{
	case "${1:-${CHOST}}" in
		*-linux*)	echo linux;;
		*)
			die "unknown GOOS for ${1:-${CHOST}}"
			;;
	esac
}

go_tuple()
{
	echo "$(go_os $@)_$(go_arch $@)"
}

go_cross_compile()
{
	[[ $(go_tuple ${CBUILD}) != $(go_tuple) ]]
}

src_compile()
{
	# try go-bootstrap first
	if has_version -b dev-lang/go-bootstrap; then
		export GOROOT_BOOTSTRAP="${BROOT}/usr/lib/go-bootstrap"
	elif has_version -b dev-lang/go; then
		export GOROOT_BOOTSTRAP="${BROOT}/usr/lib/go"
	else
		eerror "Go cannot be built without go or go-bootstrap installed"
		die "Should not be here, please report a bug"
	fi

	export GOROOT_FINAL="${EPREFIX}"/usr/lib/go
	export GOROOT="$(pwd)"
	export GOBIN="${GOROOT}/bin"

	# Go's build script does not use BUILD/HOST/TARGET consistently. :(
	export GOHOSTARCH=$(go_arch ${CBUILD})
	export GOHOSTOS=$(go_os ${CBUILD})
	export CC=$(tc-getBUILD_CC)

	export GOARCH=$(go_arch)
	export GOOS=$(go_os)
	export CC_FOR_TARGET=$(tc-getCC)
	export CXX_FOR_TARGET=$(tc-getCXX)
	if [[ ${ARCH} == arm ]]; then
		export GOARM=$(go_arm)
	fi

	cd src
	./make.bash || die "build failed"
}

src_test()
{
	go_cross_compile && return 0

	cd src
	PATH="${GOBIN}:${PATH}" \
	./run.bash -no-rebuild || die "tests failed"
	cd ..
	rm -fr pkg/*_race || die
	rm -fr pkg/obj/go-build || die
}

src_install()
{
	local bin_path f x

	dodir /usr/lib/go

	# deliberately use cp to retain permissions
	cp -R api bin doc lib pkg misc src test "${ED}"/usr/lib/go
	# testdata directories are not needed on the installed system
	rm -fr $(find "${ED}"/usr/lib/go -iname testdata -type d -print)
	if go_cross_compile; then
		bin_path="bin/$(go_tuple)"
	else
		bin_path=bin
	fi
	for x in ${bin_path}/*; do
		f=${x##*/}
		dosym ../lib/go/${bin_path}/${f} /usr/bin/${f}
	done
	einstalldocs
}
