PROTODIR ?= proto

# All files produced while making the document will have this basename
LATEX_JOBNAME ?= output

PDFFLD = pdfs
BUILDFLD = .build

# Extra options, these must be available for both pdflatex and latexmk
DEFOPT = -output-directory=$(LATEX_OUTPUT_DIR) -interaction=batchmode

# Command to build document
BUILD = ($(LATEXMK) -pdf -bibtex -latexoption=-shell-escape -jobname=$(LATEX_JOBNAME) $(DEFOPT) $(TEXFILE_FILENAME) 2>&1) >/dev/null

# Creates first auxiliary files required to build glossary
LAMEBUILD = ($(PDFLATEX) -shell-escape -jobname=$(LATEX_JOBNAME) $(DEFOPT) $(TEXFILE_FILENAME) 2>&1) >/dev/null

# Command to build glossary and glossarylists
# (Not using -d option due to incompatibility with some systems)
BUILDGLOSS = cd $(LATEX_OUTPUT_DIR) && $(MAKEGLOSSARIES) -q $(LATEX_JOBNAME) && cd - >/dev/null

.PHONY: test
all: test


detect-python:
ifndef PYTHON
  PY := "$(shell which py 2>/dev/null)"
  ifeq ($(PY),"")
    PYTHON := "$(shell which python3.8 2>/dev/null || which python3.7 2>/dev/null || which python3.6 2>/dev/null || which python3 2>/dev/null)"
  else
    PYTHON := $(PY) -3
  endif
endif


clean:
	@$(RM) -r $(PDFFLD) $(BUILDFLD)
	@echo "Done!"

test: detect-python
	@echo "Running comparison tests..."
	@echo ""
	@$(PYTHON) ../ult-base/test-scripts/regtest.py --protodir $(PROTODIR) .

_file: _ctrl_
	@echo "Building $(TEXFILE_DIR)/$(TEXFILE_FILENAME)..."
	( \
	  cd $(TEXFILE_DIR) && \
	  $(LAMEBUILD) && \
	  (if grep -q "\\makeglossaries" $(TEXFILE_FILENAME); then $(BUILDGLOSS); fi) && \
	  $(BUILD) \
	)

_ctrl_:
ifndef LATEXMK
  LATEXMK := "$(shell which latexmk 2>/dev/null)"
endif
ifndef PDFLATEX
  PDFLATEX := "$(shell which pdflatex 2>/dev/null)"
endif
ifndef MAKEGLOSSARIES
  MAKEGLOSSARIES := "$(shell which makeglossaries 2>/dev/null)"
endif
ifeq ($(LATEXMK),"")
	@echo "Cannot find 'latexmk'" >&2
	@exit 2
endif
ifeq ($(PDFLATEX),"")
	@echo "Cannot find 'pdflatex'" >&2
	@exit 3
endif
ifeq ($(MAKEGLOSSARIES),"")
	@echo "Cannot find 'makeglossaries'" >&2
	@exit 4
endif
ifeq ($(TEXFILE_DIR),"")
	@echo "TEXFILE_DIR not set" >&2
	@exit 5
endif
ifeq ($(TEXFILE_FILENAME),"")
	@echo "TEXFILE_FILENAME not set" >&2
	@exit 6
endif
ifeq ($(LATEX_OUTPUT_DIR),"")
	@echo "LATEX_OUTPUT_DIR not set" >&2
	@exit 7
endif

# Debug stuff

# Makefile hack: print content of any variable in the Makefile
#print-%:
#	@echo '$*=$($*)'
