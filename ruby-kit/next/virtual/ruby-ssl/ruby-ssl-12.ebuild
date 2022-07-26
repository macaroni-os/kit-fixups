# Distributed under the terms of the GNU General Public License v2

EAPI=7
USE_RUBY="ruby27 ruby30 ruby31"

inherit ruby-ng

DESCRIPTION="Virtual ebuild for the Ruby OpenSSL bindings"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	ruby_targets_ruby27? ( dev-lang/ruby:2.7[ssl] )
	ruby_targets_ruby30? ( dev-lang/ruby:3.0[ssl] )
	ruby_targets_ruby31? ( dev-lang/ruby:3.1[ssl] )
"

pkg_setup() { :; }
src_unpack() { :; }
src_prepare() { eapply_user; }
src_compile() { :; }
src_install() { :; }
pkg_preinst() { :; }
pkg_postinst() { :; }
