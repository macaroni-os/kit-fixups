# baselayout Makefile
# Copyright 2006-2011 Gentoo Foundation
# Copyright 2024 Macaroni OS
# Distributed under the terms of the GNU General Public License v2
#
# Based on the Gentoo baselayout work..

PV = 3.0
PKG = baselayout-$(PV)
DISTFILE = $(PKG).tar.bz2

INSTALL_DIR    = install -m 0755 -d
INSTALL_EXE    = install -m 0755
INSTALL_FILE   = install -m 0644
INSTALL_SECURE = install -m 0600

ifeq ($(OS),)
OS=$(shell uname -s)
ifneq ($(OS),Linux)
OS=BSD
endif
endif

KEEP_DIRS-BSD += \
	/var/lock \
	/var/run
KEEP_DIRS-Linux += \
	/dev \
	/run \
	/sys \
	/usr/src
KEEP_DIRS = $(KEEP_DIRS-$(OS)) \
	/boot \
	/etc/profile.d \
	/home \
	/mnt \
	/proc \
	/opt \
	/root \
	/usr/local/bin \
	/usr/local/sbin \
	/var/cache \
	/var/empty \
	/var/lib \
	/var/log \
	/var/spool

all:

clean:

install:
	$(INSTALL_DIR) $(DESTDIR)/etc
	cp -pPR etc/* etc.$(OS)/* $(DESTDIR)/etc/
	$(INSTALL_DIR) $(DESTDIR)/usr/share/baselayout
	cp -pPR share.$(OS)/* $(DESTDIR)/usr/share/baselayout/

layout-dirs:
	# Create base filesytem layout
	for x in $(KEEP_DIRS) ; do \
		test -e $(DESTDIR)$$x/.keep && continue ; \
		$(INSTALL_DIR) $(DESTDIR)$$x || exit $$? ; \
		touch $(DESTDIR)$$x/.keep || echo "ignoring touch failure; mounted fs?" ; \
	done

layout-BSD: layout-dirs
	-chgrp uucp $(DESTDIR)/var/lock
	install -m 0775 -d $(DESTDIR)/var/lock

layout-Linux: layout-dirs
	ln -snf /proc/self/mounts $(DESTDIR)/etc/mtab
	ln -snf /run $(DESTDIR)/var/run
	ln -snf /run/lock $(DESTDIR)/var/lock

layout: layout-dirs layout-$(OS)
	# Special dirs
	install -m 0700 -d $(DESTDIR)/root
	touch $(DESTDIR)/root/.keep
	install -m 1777 -d $(DESTDIR)/var/tmp
	touch $(DESTDIR)/var/tmp/.keep
	install -m 1777 -d $(DESTDIR)/tmp
	touch $(DESTDIR)/tmp/.keep
	# FHS compatibility symlinks stuff
	ln -snf /var/tmp $(DESTDIR)/usr/tmp

layout-usrmerge: layout
ifeq ($(OS),Linux)
	ln -snf usr/bin ${DESTDIR}/bin
	ln -snf usr/sbin ${DESTDIR}/sbin
	ln -snf bin ${DESTDIR}/usr/sbin
endif

live:
	rm -rf /tmp/$(PKG)
	cp -r . /tmp/$(PKG)
	tar jcf /tmp/$(PKG).tar.bz2 -C /tmp $(PKG) --exclude=.git
	rm -rf /tmp/$(PKG)
	ls -l /tmp/$(PKG).tar.bz2

release:
	git show-ref -q --tags $(PKG)
	git archive --prefix=$(PKG)/ $(PKG) | bzip2 > $(DISTFILE)
	ls -l $(DISTFILE)

snapshot:
	git show-ref -q $(GITREF)
	git archive --prefix=$(PKG)/ $(GITREF) | bzip2 > $(PKG)-$(GITREF).tar.bz2
	ls -l $(PKG)-$(GITREF).tar.bz2

.PHONY: all changelog clean install layout live release snapshot

# vim: set ts=4 :
