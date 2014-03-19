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

# If TEXMFHOME is defined, we use it! Else, we try TEXMFLOCAL
try-texmf-home:
ifneq ($(ULTTEXMFHOME),)
  try-texmf-local:  ULTTEXMFLOCAL = $(ULTTEXMFHOME)
endif

# Try TEXMFHOME first. If TEXMFHOME is defined, it will override ULTTEXMFLOCAL
try-texmf-local: try-texmf-home
# If neither TEXMFHOME nor TEXMFLOCAL is defined
ifeq ($(ULTTEXMFLOCAL),)
	@echo -e "Cannot locate your home texmf tree. Specify manually with\n\n    make install TEXMF=/path/to/texmf\n"
	@exit 1
else
  TEXMF = $(ULTTEXMFLOCAL)
endif

ifdef TEXMF
detect-texmf:
else
detect-texmf: try-texmf-local
endif
	@echo "Using texmf tree in \"$(TEXMF)\"."
	$(prompt-texmf)
ULTTEXMF = $(subst \,/,$(TEXMF))
LATEXROOT = $(ULTTEXMF)/tex/latex/$(NAME)
LOCALLATEXROOT = texmf-tds/tex/latex/$(NAME)

check-texmf: detect-texmf
	@test -d "$(ULTTEXMF)" || mkdir -p "$(ULTTEXMF)"

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
	@cp -r -v "$(LOCALLATEXROOT)"/* "$(LATEXROOT)/"
	@if [ $$? -ne 0 ]; then \
		echo "Failed to copy class files to texmf directory" ; \
		exit 1 ; \
	fi
	@echo "Done."
	@echo "You might have to run 'texhash' to update your texmf database." ; \
