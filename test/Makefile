# The file to test (without extension)
BASENAME = `basename $(FILE) .tex`

PROTOPDF = ./proto/proto.pdf
DIFFLD = ./diffs
PDFFLD = ./pdfs

BUILDFILE = ./${BASENAME}.tex#
PDFFILE = ${PDFFLD}/${BASENAME}.pdf#

# All files produced while making the document will have this basename
OUTPUTNAME = output

# Placement of all produced files
BUILDFLD = ./.build

# Extra options, these must be available for both pdflatex and latexmk
DEFOPT = -output-directory=$(BUILDFLD) -interaction=nonstopmode 2>/dev/null 1>/dev/null

# Options for glossary
GLOSSOPT = -q

# Command to build document
BUILD = latexmk -pdf -bibtex -jobname=$(OUTPUTNAME) $(DEFOPT) $(BUILDFILE)

# Creates first auxiliary files required to build glossary
LAMEBUILD = pdflatex -jobname=$(OUTPUTNAME) $(DEFOPT) $(BUILDFILE)

# Command to build glossary and glossarylists
# (Not using -d option due to incompatibility with some systems)
BUILDGLOSS = cd $(BUILDFLD) &&\
 makeglossaries $(GLOSSOPT) $(OUTPUTNAME) &&\
 cd - >/dev/null

test: _file _compare

clean:
	@$(RM) -r ${PDFFLD} ${DIFFLD} ${BUILDFLD}
	@echo "Done!"

# Target specific variables
_compare : PAGES=$(shell pdfinfo $(PDFFILE)\
	|grep -Po '(?<=^Pages:)\s*\d+$$'|grep -Po '\d+')
_compare : LAST=$(shell expr $(PAGES) - 1)
_compare : RANGE=$(shell seq 0 $(LAST))
_compare:
	@echo "Testing ${PAGES} pages from document ${PDFFILE}"
	@mkdir -p $(DIFFLD)
	@ERR=""; for p in ${RANGE}; do \
		RES="$$(compare -metric ae ${PDFFILE}[$$p] ${PROTOPDF}[$$p] \
		${DIFFLD}/${BASENAME}_p$$p.png 2>&1)"; \
		if [ "$${RES}" = "0" ]; then rm ${DIFFLD}/${BASENAME}_p$$p.png; \
		else ERR="$${ERR} $$p"; \
		fi; \
		echo -n "."; \
	done; echo ""; if [ -z $${ERR} ]; then \
	echo "No diff was detected!"; rm -r ${DIFFLD}; else echo "diff on pages: $${ERR}"; \
	echo "diff-image(s) is available in ${DIFFLD}"; fi

_file: _ctrl_
	@$(RM) $(PDFFILE)
	@mkdir -p $(BUILDFLD)
	@mkdir -p $(PDFFLD)
	@$(LAMEBUILD)
	@$(BUILDGLOSS)
	@$(BUILD)
	@mv $(BUILDFLD)/$(OUTPUTNAME).pdf $(PDFFILE)
	@$(RM) -r $(BUILDFLD) > /dev/null
	@echo ""
	@echo "PDF is saved as ${PDFFILE}"

_ctrl_:
ifeq ($(FILE),)
	@echo "Specify a FILE"
	@exit 1
endif


# Debug stuff

# Makefile hack: print content of any variable in the Makefile
print-%:
	@echo '$*=$($*)'
