modules := $(modules) \
	bootstrap

bsversion := 5.1.3
iconversion := 1.8.3

# Arrays
bsicons := \
	question-circle-fill \
	arrow-repeat \
	x-circle-fill \
	check-circle-fill

bssrcs := \
	https://github.com/twbs/bootstrap/releases/download/v${bsversion}/bootstrap-${bsversion}-dist.zip \
	https://github.com/twbs/icons/releases/download/v${iconversion}/bootstrap-icons-${iconversion}.zip \
	https://cdn.datatables.net/v/bs5/dt-1.12.1/b-2.2.3/b-colvis-2.2.3/b-html5-2.2.3/b-print-2.2.3/fc-4.1.0/fh-3.2.4/datatables.min.css \
	https://cdn.datatables.net/v/bs5/dt-1.12.1/b-2.2.3/b-colvis-2.2.3/b-html5-2.2.3/b-print-2.2.3/fc-4.1.0/fh-3.2.4/datatables.min.js \
	https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js

bsdsts := $(patsubst %, ./download/%, $(notdir $(bssrcs))) # get only the filename of the URLs
bsicons_path := $(patsubst %, ./download/icons/%, $(addsuffix .svg, $(bsicons)))

# Targets
$(bsicons_path): 
	@mkdir -p download/icons
	@echo $@
	cp -v $(patsubst download/icons/%, download/bootstrap-icons-${iconversion}/% , $@) download/icons/

$(bsdsts): download/%: #to get rid of "download" prefix - no prerequisites
	@mkdir -p download
#	fetch correct url by maching the filename
	@echo "download" $* "->" $(filter %$*, $(bssrcs)) "->" $@
	wget $(filter %$*, $(bssrcs)) -O $@
	if [[ $(suffix $*) == .zip ]]; then unzip -o download/$* -d download/; fi 

$(addsuffix dlclean, $(bsdsts)):
	if [[ $(suffix $(subst dlclean, , $@)) == .zip ]]; then $(RM) -r $(subst .zip, , $(subst dlclean, , $@)) ; fi

# Tasks
.PHONY: bootstrap_download
bootstrap_download: $(bsdsts) $(bsicons_path)
	cp -v download/bootstrap-${bsversion}-dist/js/bootstrap.bundle.min* download/
	cp -v download/bootstrap-${bsversion}-dist/css/bootstrap.min* download/
	rm download/bootstrap-icons-${iconversion}/*svg
	cp -rv download/bootstrap-icons-${iconversion}/* download/icons


.PHONY: bootstrap_clean
bootstrap_distclean: 
	$(MAKE) bootstrap_clean
	$(MAKE) bootstrap_dlclean
	$(RM) -r download/icons
	$(RM) download/*bootstrap*
	$(RM) download/*jquery*
	$(RM) download/*datatable*


.PHONY: bootstrap_clean
bootstrap_clean: 
	$(RM) -r ../public/css
	$(RM) -r ../public/js

.PHONY: bootstrap_dlclean
bootstrap_dlclean: $(addsuffix dlclean, $(bsdsts))
	$(RM) -r download/bootstrap-${bsversion}-dist*
	$(RM) -r download/bootstrap-icons-${iconversion}*

.PHONY: bootstrap_build
bootstrap_build: 
	cp -rv download/icons ../public/css/
	cp -v download/*.css* ../public/css/
	cp -v download/*.js* ../public/js/
