BASEDIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
DOCROOT:=$(BASEDIR)/public
TMPDIR := $(shell mktemp -d)
ZIPFILE := $(strip $(subst tmp, $(notdir $(BASEDIR)), $(notdir $(TMPDIR))).zip)

include config_default.txt
-include config.txt

# ------------------------------------------------------------------------------

# prepare for TSD

PHONY: prepare_offline
prepare_offline:
	git clone $(BASEDIR) $(TMPDIR)
	cd $(TMPDIR) && \
		make download && \
		cd .. && \
		zip -r $(ZIPFILE) $(notdir $(TMPDIR))
	@echo zip folder made: $(dir $(TMPDIR))$(ZIPFILE)

# ------------------------------------------------------------------------------

# run

.PHONY: run_webui
run_webui: 
	PORT=${WEBSERVERPORT} \
	DOCROOT=${DOCROOT} \
	BASEDIR=$(BASEDIR) \
	DATADIR=$(BASEDIR)/$(DATAFOLDER) \
	R_LIBS_USER=$(BASEDIR)/3rdparty/r_packages \
	3rdparty/lighttpd/sbin/lighttpd -D -f lighttpd.conf

# ------------------------------------------------------------------------------

# clean
.PHONY: clean
clean: 
	$(MAKE) -C 3rdparty clean

.PHONY: dlclean
dlclean: 
	$(MAKE) -C 3rdparty dlclean


.PHONY: distclean
distclean: 
	$(MAKE) -C 3rdparty distclean

# ------------------------------------------------------------------------------

# build

.PHONY: build
build: 
	mkdir -p public/css/icons
	mkdir -p public/js
	$(MAKE) -C 3rdparty build
	
# ------------------------------------------------------------------------------

# download

.PHONY: download
download: 
	$(MAKE) -C 3rdparty download
	