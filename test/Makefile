# Programs used
LATEXMK := "$(shell which latexmk 2>/dev/null)"
PDFLATEX := "$(shell which pdflatex 2>/dev/null)"
MAKEGLOSSARIES := "$(shell which makeglossaries 2>/dev/null)"

# The file to test (without extension)
BASENAME = $(shell basename $(FILE) .tex)

TESTSDIR = tests
MAINDIR_REL2_TESTSDIR = ..

PDFFLD = pdfs

# Placement of all produced files
BUILDFLD = .build

BUILDFILE = $(BASENAME).tex
PDFFILE = $(PDFFLD)/$(BASENAME).pdf

# All files produced while making the document will have this basename
OUTPUTNAME = output

# Extra options, these must be available for both pdflatex and latexmk
DEFOPT = -output-directory=$(MAINDIR_REL2_TESTSDIR)/$(BUILDFLD)/$(BASENAME) -interaction=batchmode

# Options for glossary
GLOSSOPT = -q

# Command to build document
BUILD = ($(LATEXMK) -pdf -bibtex -jobname=$(OUTPUTNAME) $(DEFOPT) $(BUILDFILE) 2>&1) >/dev/null

# Creates first auxiliary files required to build glossary
LAMEBUILD = ($(PDFLATEX) -jobname=$(OUTPUTNAME) $(DEFOPT) $(BUILDFILE) 2>&1) >/dev/null

# Command to build glossary and glossarylists
# (Not using -d option due to incompatibility with some systems)
BUILDGLOSS = cd $(BUILDFLD)/$(BASENAME) &&\
 $(MAKEGLOSSARIES) $(GLOSSOPT) $(OUTPUTNAME) &&\
 cd - >/dev/null

.PHONY: test

all: test

clean:
	@$(RM) -r $(PDFFLD) $(BUILDFLD)
	@echo "Done!"

test: 
	@echo "Running comparison tests..."
	@echo ""
	@python ../ult-base/test-scripts/regtest.py .

_file: _ctrl_
	@echo "Building $(FILE)..."
	@$(RM) $(PDFFILE)
	@mkdir -p $(BUILDFLD)/$(BASENAME)
	@mkdir -p $(PDFFLD)
	cd tests && $(LAMEBUILD)
	$(BUILDGLOSS)
	(cd tests && $(BUILD)) && mv $(BUILDFLD)/$(BASENAME)/$(OUTPUTNAME).pdf $(PDFFILE) && \
	  $(RM) -r $(BUILDFLD)/$(BASENAME)
ifndef RETAINBUILDFLD
	@$(RM) -r $(BUILDFLD)
endif

_ctrl_:
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
