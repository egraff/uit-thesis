PROTODIR ?= proto

# All files produced while making the document will have this basename
LATEX_JOBNAME ?= output

PDFFLD = pdfs
BUILDFLD = .build

# Extra options, these must be available for both pdflatex and latexmk
DEFOPT = -output-directory=$(LATEX_OUTPUT_DIR) -interaction=nonstopmode -halt-on-error

# Command to build document
BUILD = ($(LATEXMK) -pdf -bibtex -latexoption=-shell-escape -jobname=$(LATEX_JOBNAME) $(DEFOPT) $(TEXFILE_FILENAME) 2>&1) >/dev/null

# Creates first auxiliary files required to build glossary
LAMEBUILD = ($(PDFLATEX) -shell-escape -jobname=$(LATEX_JOBNAME) $(DEFOPT) $(TEXFILE_FILENAME) 2>&1) >/dev/null

# Command to build glossary and glossarylists
# (Not using -d option due to incompatibility with some systems)
BUILDGLOSS = cd $(LATEX_OUTPUT_DIR) && $(MAKEGLOSSARIES) -q $(LATEX_JOBNAME) && cd - >/dev/null

PHONY += all
all: test


ifeq ($(strip $(WARMUP_COMPILE)),)
  override WARMUP_COMPILE := 0
endif


ifeq ($(strip $(LATEXMK)),)
  override LATEXMK = "$(shell which latexmk 2>/dev/null)"
endif
ifeq ($(strip $(PDFLATEX)),)
  override PDFLATEX = "$(shell which pdflatex 2>/dev/null)"
endif
ifeq ($(strip $(MAKEGLOSSARIES)),)
  override MAKEGLOSSARIES = "$(shell which makeglossaries 2>/dev/null)"
endif


define detect-python
	_PY=$$(which py 2>/dev/null); \
	if [ -z "$${_PY}" ]; then \
	  _PYTHON=$$(which python3.12 2>/dev/null || which python3.11 2>/dev/null || which python3 2>/dev/null) ; \
	else \
	  _PYTHON="$${_PY} -3-64" ; \
	fi ; \
	echo "$${_PYTHON}"
endef

# Note: this is evaluated lazily (and not at all if overridden on the command line)
PYTHON = $(shell $(detect-python))

define check-python-version
	_PYTHON=$$(echo $(PYTHON)) ; \
	if [ -z "$${_PYTHON}" ]; then \
	  echo "Cannot find 'python'" >&2 ; \
	  exit 10 ; \
	fi ; \
	_PYTHON_VER_STR=$$($${_PYTHON} -V 2>&1) ; \
	_PYTHON_STR=$$(echo $$_PYTHON_VER_STR | cut -d ' ' -f 1) ; \
	if [ "$${_PYTHON_STR}" != "Python" ]; then \
	  echo "Found 'python' executable does not quack like python (got '$${_PYTHON_STR}')" >&2 ; \
	  exit 11 ; \
	fi ; \
	_PYTHON_VER=$$(echo $$_PYTHON_VER_STR | cut -d ' ' -f 2) ; \
	_PYTHON_VER_MAJ=$$(echo $$_PYTHON_VER | cut -d '.' -f 1) ; \
	_PYTHON_VER_MIN=$$(echo $$_PYTHON_VER | cut -d '.' -f 2) ; \
	if [ \( -z "$${_PYTHON_VER_MAJ##*[!0-9]*}" \) -o \( -z "$${_PYTHON_VER_MIN##*[!0-9]*}" \) ]; then \
	  echo "Could not identify 'python' version" >&2 ; \
	  exit 12 ; \
	fi ; \
	if [ ! \( \( $$_PYTHON_VER_MAJ -eq 3 \) -a \( $$_PYTHON_VER_MIN -ge 11 \) \) ]; then \
	  echo "Cannot find 'python' >= 3.11 (found version $$_PYTHON_VER)" >&2 ; \
	  exit 13 ; \
	fi
endef


PHONY += check-python
check-python:
	@$(check-python-version)

PHONY += check-file-params
check-file-params:
ifeq ($(strip $(TEXFILE_DIR)),)
	@echo "TEXFILE_DIR not set" >&2
	@exit 2
endif
ifeq ($(strip $(TEXFILE_FILENAME)),)
	@echo "TEXFILE_FILENAME not set" >&2
	@exit 3
endif
ifeq ($(strip $(LATEX_OUTPUT_DIR)),)
	@echo "LATEX_OUTPUT_DIR not set" >&2
	@exit 4
endif

PHONY += check-file-programs
check-file-programs:
	_LATEXMK=$$(echo $(LATEXMK)) ; \
	if [ -z "$${_LATEXMK}" ]; then \
	  echo "Cannot find 'latexmk'" >&2 ; \
	  exit 2 ; \
	fi ; \
	_PDFLATEX=$$(echo $(PDFLATEX)) ; \
	if [ -z "$${_PDFLATEX}" ]; then \
	  echo "Cannot find 'pdflatex'" >&2 ; \
	  exit 3 ; \
	fi ; \
	_MAKEGLOSSARIES=$$(echo $(MAKEGLOSSARIES)) ; \
	if [ -z "$${_MAKEGLOSSARIES}" ]; then \
	  echo "Cannot find 'makeglossaries'" >&2 ; \
	  exit 4 ; \
	fi

PHONY += clean
clean:
	@$(RM) -r $(PDFFLD) $(BUILDFLD)
	@echo "Done!"

PHONY += test
test: check-python
	@echo "Running comparison tests..."
	@echo ""
	@$(PYTHON) ../ult-base/test-scripts/regtest.py --protodir $(PROTODIR) --warmup-compile $(WARMUP_COMPILE) .

PHONY += _file
_file: check-file-params check-file-programs
	@echo "Building $(TEXFILE_DIR)/$(TEXFILE_FILENAME)..."
	( \
	  cd $(TEXFILE_DIR) && \
	  $(LAMEBUILD) && \
	  (if grep -q "\\makeglossaries" $(TEXFILE_FILENAME); then $(BUILDGLOSS); fi) && \
	  $(BUILD) \
	)

.PHONY: $(PHONY)

# Debug stuff

# Makefile hack: print content of any variable in the Makefile
#print-%:
#	@echo '$*=$($*)'
