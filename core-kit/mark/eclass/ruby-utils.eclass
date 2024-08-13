# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: ruby-utils.eclass
# @MAINTAINER:
# Ruby team <ruby@gentoo.org>
# @AUTHOR:
# Author: Hans de Graaff <graaff@gentoo.org>
# @BLURB: An eclass for supporting ruby scripts and bindings in non-ruby packages
# @DESCRIPTION:
# The ruby-utils eclass is designed to allow an easier installation of
# Ruby scripts and bindings for non-ruby packages.
#
# This eclass does not set any metadata variables nor export any phase
# functions. It can be inherited safely.


if [[ ! ${_RUBY_UTILS} ]]; then


_ruby_implementation_depend() {
	local rubypn=
	local rubyslot=

	case $1 in
		ruby18)
			rubypn="dev-lang/ruby"
			rubyslot=":1.8"
			;;
		ruby19)
			rubypn="dev-lang/ruby"
			rubyslot=":1.9"
			;;
		ruby20)
			rubypn="dev-lang/ruby"
			rubyslot=":2.0"
			;;
		ruby21)
			rubypn="dev-lang/ruby"
			rubyslot=":2.1"
			;;
		ruby22)
			rubypn="dev-lang/ruby"
			rubyslot=":2.2"
			;;
		ruby23)
			rubypn="dev-lang/ruby"
			rubyslot=":2.3"
			;;
		ruby24)
			rubypn="dev-lang/ruby"
			rubyslot=":2.4"
			;;
		ruby25)
			rubypn="dev-lang/ruby"
			rubyslot=":2.5"
			;;
		ruby26)
			rubypn="dev-lang/ruby"
			rubyslot=":2.6"
			;;
		ruby27)
			rubypn="dev-lang/ruby"
			rubyslot=":2.7"
			;;
		ruby30)
			rubypn="dev-lang/ruby"
			rubyslot=":3.0"
			;;
		ruby31)
			rubypn="dev-lang/ruby"
			rubyslot=":3.1"
			;;
		ruby32)
			rubypn="dev-lang/ruby"
			rubyslot=":3.2"
			;;
		ree18)
			rubypn="dev-lang/ruby-enterprise"
			rubyslot=":1.8"
			;;
		jruby)
			rubypn="dev-java/jruby"
			rubyslot=""
			;;
		rbx)
			rubypn="dev-lang/rubinius"
			rubyslot=""
			;;
		*) die "$1: unknown Ruby implementation"
	esac

	echo "$2${rubypn}$3${rubyslot}"
}



_RUBY_UTILS=1
fi
