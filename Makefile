NAME = uit-thesis

# Try to locate user's local texmf tree
ULTTEXMFHOME = $(shell kpsewhich --var-value TEXMFHOME)
ULTTEXMFLOCAL = $(shell kpsewhich --var-value TEXMFLOCAL)

all: help

help:
	@echo 'uit-thesis makefile targets:'
	@echo ' '
	@echo '                  help  -  (this message)'
	@echo ' '
	@echo '               install  -  install the uit-thesis class into your home texmf tree'
	@echo '             uninstall  -  remove the uit-thesis class from your home texmf tree'

define prompt-texmf
	@while [ -z "$$CONTINUE" ]; do \
		read -r -p "Is this correct? [y/N] " CONTINUE; \
	done ; \
	if [ $$CONTINUE != "y" ] && [ $$CONTINUE != "Y" ]; then \
		echo "Exiting." ; exit 1 ; \
	fi
endef

detect-texmf:
	@echo "Using texmf tree in \"$(TEXMF)\"."
ifndef TEXMF
ifneq ($(ULTTEXMFHOME),)
	$(prompt-texmf)
  TEXMF = $(ULTTEXMFHOME)
else
ifeq ($(ULTTEXMFLOCAL),)
	@echo -e "Cannot locate your home texmf tree. Specify manually with\n\n    make install TEXMF=/path/to/texmf\n"
	@exit 1
else
	$(prompt-texmf)
  TEXMF = $(ULTTEXMFLOCAL)
endif
endif
endif

check-texmf: detect-texmf
	@test -d "$(ULTTEXMF)" || mkdir -p "$(ULTTEXMF)"
  ULTTEXMF = $(subst \,/,$(TEXMF))
  LATEXROOT = $(ULTTEXMF)/tex/latex/$(NAME)
  LOCALLATEXROOT = texmf-tds/tex/latex/$(NAME)

uninstall: check-texmf
	@echo "$(ULTTEXMF)/tex/latex/$(NAME)"
	@if [ -d "$(LATEXROOT)" ]; then \
		echo "Uninstalling..." ; \
		rm -rf "$(LATEXROOT)" ; \
		echo "Uninstalled." ; \
		echo "You might have to run 'texhash' to update your texmf database." ; \
	fi

install: check-texmf uninstall
	@echo "Installing into \"$(LATEXROOT)\"..."
	@test -d "$(LATEXROOT)" || mkdir -p "$(LATEXROOT)"
	cp -r -v "$(LOCALLATEXROOT)"/* "$(LATEXROOT)/"
	@if [ $$? -ne 0 ]; then \
		echo "Failed to copy class files to texmf directory" ; \
		exit 1 ; \
	fi
	@echo "Done."
	@echo "You might have to run 'texhash' to update your texmf database." ; \
