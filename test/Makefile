# Programs used
COMPARE := "$(shell which compare 2>/dev/null)"
LATEXMK := "$(shell which latexmk 2>/dev/null)"
PDFLATEX := "$(shell which pdflatex 2>/dev/null)"
MAKEGLOSSARIES := "$(shell which makeglossaries 2>/dev/null)"

# The file to test (without extension)
BASENAME = $(shell basename $(FILE) .tex)

PROTOPDF = ./proto/proto.pdf
TMPFLD = ./tmp
DIFFLD = ./diffs
PDFFLD = ./pdfs

BUILDFILE = ./${BASENAME}.tex#
PDFFILE = ${PDFFLD}/${BASENAME}.pdf#

# All files produced while making the document will have this basename
OUTPUTNAME = output

# Placement of all produced files
BUILDFLD = ./.build

# Extra options, these must be available for both pdflatex and latexmk
DEFOPT = -output-directory=$(BUILDFLD)/$(BASENAME) -interaction=nonstopmode &>/dev/null

# Options for glossary

GLOSSOPT = -q

# Command to build document
BUILD = $(LATEXMK) -pdf -bibtex -jobname=$(OUTPUTNAME) $(DEFOPT) $(BUILDFILE)

# Creates first auxiliary files required to build glossary
LAMEBUILD = $(PDFLATEX) -jobname=$(OUTPUTNAME) $(DEFOPT) $(BUILDFILE)

# Command to build glossary and glossarylists
# (Not using -d option due to incompatibility with some systems)
BUILDGLOSS = cd $(BUILDFLD)/$(BASENAME) &&\
 $(MAKEGLOSSARIES) $(GLOSSOPT) $(OUTPUTNAME) &&\
 cd - >/dev/null

FILES := $(shell ls -v | grep -o "^test.*\.tex")

.PHONY: test _compare

all: test _compare

test:
	@echo "FILES: $(FILES)"
	@echo ""
	@for f in $(FILES); do $(MAKE) --no-print-directory _file FILE=$$f RETAINBUILDFLD=y; done
	@echo ""
	@$(RM) -r $(BUILDFLD)

clean:
	@$(RM) -r ${PDFFLD} ${DIFFLD} ${BUILDFLD}
	@echo "Done!"

# Target specific variables
_compare: 
	@echo "Running comparison tests..."
	@echo ""
	@python regtest.py

_file: _ctrl_
	@echo "Building $(FILE)..."
	@$(RM) $(PDFFILE)
	@mkdir -p $(BUILDFLD)/$(BASENAME)
	@mkdir -p $(PDFFLD)
	@$(LAMEBUILD)
	@$(BUILDGLOSS)
	@$(BUILD)
	@mv $(BUILDFLD)/$(BASENAME)/$(OUTPUTNAME).pdf $(PDFFILE)
	@$(RM) -r $(BUILDFLD)/$(BASENAME)
ifndef RETAINBUILDFLD
	@$(RM) -r $(BUILDFLD)
endif

_ctrl_:
ifndef COMPARE
	@echo "Cannot find 'compare', install 'imagemagick' to fix this" >&2
	@exit 1
endif
ifndef LATEXMK
	@echo "Cannot find 'latexmk'" >&2
	@exit 2
endif
ifndef PDFLATEX
	@echo "Cannot find 'pdflatex'" >&2
	@exit 3
endif
ifndef MAKEGLOSSARIES
	@echo "Cannot find 'makeglossaries'" >&2
	@exit 4
endif
ifeq ($(FILE),)
	@echo "Specify which test to run as a FILE argument" >&2
	@exit 5
endif

# Debug stuff

# Makefile hack: print content of any variable in the Makefile
#print-%:
#	@echo '$*=$($*)'
