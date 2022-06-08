# Distributed under the terms of the GNU General Public License v2

EAPI=7

USE_RUBY="ruby26 ruby27 ruby30 ruby31"

# The specs require a number of gems to be installed in a temporary
# directory, but this requires network access. They also don't work
# when run with a path that contains "-".
RUBY_FAKEGEM_RECIPE_TEST="none"

# No documentation task
RUBY_FAKEGEM_EXTRADOC="README.md CHANGELOG.md"

RUBY_FAKEGEM_BINDIR="exe"

inherit ruby-fakegem

DESCRIPTION="An easy way to vendor gem dependencies"
HOMEPAGE="https://github.com/carlhuda/bundler"

LICENSE="MIT"
SLOT="$(ver_cut 1)"
KEYWORDS="*"
IUSE="-doc test"

ruby_add_rdepend virtual/rubygems

RDEPEND+=" dev-vcs/git !<dev-ruby/bundler-1.17.3-r1:0"
