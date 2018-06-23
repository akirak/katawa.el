EMAKE_SHA1            := 9095599536e5b3ad8c34a3dd3362dbb92ebf701f
PACKAGE_LISP          := katawa-decode.el katawa-google.el katawa.el \
			company-katawa.el katawa-ivy.el katawa-ivy-exwm.el

PACKAGE_ARCHIVES      := gnu melpa
#PACKAGE_TESTS         := test-sample.el # normally, EMake would discover these in the test/ directory
PACKAGE_TEST_DEPS     := package-lint
PACKAGE_TEST_ARCHIVES := gnu melpa

EMACS ?= emacs
CURL ?= curl

EMAKE = PACKAGE_LISP="$(PACKAGE_LISP)" \
	PACKAGE_ARCHIVES="$(PACKAGE_ARCHIVES)" \
	PACKAGE_TEST_DEPS="$(PACKAGE_TEST_DEPS)" \
	PACKAGE_TEST_ARCHIVES="$(PACKAGE_TEST_ARCHIVES)" \
	$(EMACS) -batch -l emake.el \
	--eval "(setq enable-dir-local-variables nil)" \
	$(EMACS_ARGS) \
	--eval "(emake (pop argv))"

.PHONY: install lint compile clean

clean::                         ## clean all generated files
	rm -f *.elc             # delete compiled files
	rm -rf .elpa/           # delete dependencies
	rm -rf .elpa.test/
	rm -f emake.el
	rm -f emacs-travis.mk

emake.el:                       ## download the EMake script
	$(CURL) -O 'https://raw.githubusercontent.com/vermiculus/emake.el/$(EMAKE_SHA1)/emake.el'

emacs-travis.mk:                ## download the emacs-travis.mk Makefile
	$(CURL) -O 'https://raw.githubusercontent.com/flycheck/emacs-travis/master/emacs-travis.mk'

emacs: emake.el                 ## report emacs version (installing $EMACS_VERSION if necessary)
	$(EMACS) -batch -l emake.el -f emake-verify-version 2>&1 || $(MAKE) install-emacs
	$(EMACS) --version

setup: emacs

install-emacs: emacs-travis.mk	## build and install a fresh emacs
	export PATH="$(HOME)/bin:$(PATH)"
	make -f emacs-travis.mk install_emacs

.elpa: emake.el

install: .elpa
	PACKAGE_FILE=katawa-decode.el $(EMAKE) install
	PACKAGE_FILE=katawa.el $(EMAKE) install
	PACKAGE_FILE=katawa-google.el $(EMAKE) install
	PACKAGE_FILE=company-katawa.el $(EMAKE) install
	PACKAGE_FILE=katawa-ivy.el $(EMAKE) install
	PACKAGE_FILE=katawa-ivy-exwm.el $(EMAKE) install

lint: install
	$(EMAKE) test package-lint
	$(EMAKE) test checkdoc

compile: install
	rm -f $(PACKAGE_LISP:.el=.elc)
	$(EMAKE) compile ~error-on-warn
