NAME = uit-thesis

# Try to locate user's local texmf tree
ULTTEXMFHOME = $(shell kpsewhich --var-value TEXMFHOME 2>/dev/null)
ULTTEXMFLOCAL = $(shell kpsewhich --var-value TEXMFLOCAL 2>/dev/null)

all: help

help:
	@echo "uit-thesis makefile targets:"
	@echo " "
	@echo "          help  -  (this message)"
	@echo " "
	@echo "       install  -  install the uit-thesis class into your home texmf tree"
	@echo "     uninstall  -  remove the uit-thesis class from your home texmf tree"

define prompt-texmf
	while [ -z "$$CONTINUE" ]; do                                           \
	    read -r -p "Is this correct? [y/N] " CONTINUE;                      \
	done ;                                                                  \
	if [ $$CONTINUE != "y" ] && [ $$CONTINUE != "Y" ]; then                 \
	    echo "Exiting." ; exit 1 ;                                          \
	fi
endef


# If the TEXMF argument is on the kpathsea form {dir1:dir2:dir3} or {dir1;dir2;dir3} or {dir1,dir2,dir3},
# then select the first directory from the list. Otherwise, use the TEXMF argument verbatim.
define parse-texmf
	MULTI_PATHS=$$(echo "$(1)" | sed -n 's/^{\(.*\)}/\1/p') ;               \
	if [ ! -z "$$MULTI_PATHS" ]; then                                       \
	    if [ "$(OS)" = "Windows_NT" ]; then                                 \
	        IFS=';,' ;                                                      \
	    else                                                                \
	        IFS=';:,' ;                                                     \
	    fi ;                                                                \
	    for p in $$MULTI_PATHS; do                                          \
	        echo "$$p" ;                                                    \
	        break ;                                                         \
	    done ;                                                              \
	else                                                                    \
	    echo "$(1)" ;                                                       \
	fi
endef


# If TEXMFHOME is defined, we use it! Else, we try TEXMFLOCAL
# (note that if TEXMF has been specified as a command line argument, it takes precedence)
ifneq ($(ULTTEXMFHOME),)
  TEXMF = $(shell $(call parse-texmf,$(ULTTEXMFHOME)))
else ifneq ($(ULTTEXMFLOCAL),)
  TEXMF = $(shell $(call parse-texmf,$(ULTTEXMFLOCAL)))
endif


check-texmf:
ifeq ($(strip $(TEXMF)),)
	@echo "Cannot locate your home texmf tree. Specify manually with"
	@echo " "
	@echo "    make install TEXMF=/path/to/texmf"
	@echo " "
	@exit 1
endif


detect-texmf: check-texmf
	@echo "Using texmf tree in \"$(TEXMF)\"."
	@$(prompt-texmf)
ULTTEXMF = $(subst \,/,$(TEXMF))
LATEXROOT = $(ULTTEXMF)/tex/latex/$(NAME)
LOCALLATEXROOT = texmf-tds/tex/latex/$(NAME)

ensure-texmf-exists: detect-texmf
	@test -d "$(ULTTEXMF)" || mkdir -p "$(ULTTEXMF)"

uninstall: ensure-texmf-exists
	$(MAKE) -C ult-base uninstall TEXMF=$(TEXMF) CONTINUE=y
	@echo "$(ULTTEXMF)/tex/latex/$(NAME)"
	@if [ -d "$(LATEXROOT)" ]; then \
		echo "Uninstalling..." ; \
		rm -rf "$(LATEXROOT)" ; \
		echo "Uninstalled." ; \
		echo "You might have to run 'texhash' to update your texmf database." ; \
	fi

install: ensure-texmf-exists uninstall
	$(MAKE) -C ult-base install TEXMF=$(TEXMF) CONTINUE=y
	@echo "Installing into \"$(LATEXROOT)\"..."
	@test -d "$(LATEXROOT)" || mkdir -p "$(LATEXROOT)"
	@cp -r -v "$(LOCALLATEXROOT)"/* "$(LATEXROOT)/"
	@if [ $$? -ne 0 ]; then \
		echo "Failed to copy class files to texmf directory" ; \
		exit 1 ; \
	fi
	@git rev-parse --verify HEAD > "$(LATEXROOT)/REVISION"
	@echo "Done."
	@echo "You might have to run 'texhash' to update your texmf database." ; \
