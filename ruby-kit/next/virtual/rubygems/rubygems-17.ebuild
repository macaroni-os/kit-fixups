# Distributed under the terms of the GNU General Public License v2

EAPI=7
USE_RUBY="ruby27 ruby30 ruby31"

inherit ruby-ng

DESCRIPTION="Virtual ebuild for rubygems"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	ruby_targets_ruby27? ( >=dev-ruby/rubygems-3.1.0[ruby_targets_ruby27] )
	ruby_targets_ruby30? ( >=dev-ruby/rubygems-3.2.0[ruby_targets_ruby30] )
	ruby_targets_ruby31? ( >=dev-ruby/rubygems-3.3.0[ruby_targets_ruby31] )
"

pkg_setup() { :; }
src_unpack() { :; }
src_prepare() { eapply_user; }
src_compile() { :; }
src_install() { :; }
pkg_preinst() { :; }
pkg_postinst() { :; }
