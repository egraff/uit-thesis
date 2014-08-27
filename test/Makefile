# Programs used
COMPARE := "$(shell which compare 2>/dev/null)"
LATEXMK := "$(shell which latexmk 2>/dev/null)"
PDFLATEX := "$(shell which pdflatex 2>/dev/null)"
MAKEGLOSSARIES := "$(shell which makeglossaries 2>/dev/null)"
GS := "$(shell which gc 2>/dev/null || which gswin64c 2>/dev/null || which gswin32c 2>/dev/null)"

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
DEFOPT = -output-directory=$(BUILDFLD) -interaction=nonstopmode &>/dev/null

# Options for glossary
GLOSSOPT = -q

# Command to build document
BUILD = $(LATEXMK) -pdf -bibtex -jobname=$(OUTPUTNAME) $(DEFOPT) $(BUILDFILE)

# Creates first auxiliary files required to build glossary
LAMEBUILD = $(PDFLATEX) -jobname=$(OUTPUTNAME) $(DEFOPT) $(BUILDFILE)

# Command to build glossary and glossarylists
# (Not using -d option due to incompatibility with some systems)
BUILDGLOSS = cd $(BUILDFLD) &&\
 $(MAKEGLOSSARIES) $(GLOSSOPT) $(OUTPUTNAME) &&\
 cd - >/dev/null

FILES := `ls -v | grep -o "^test.*\.tex"`

all:
	@for f in $(FILES); do $(MAKE) test FILE=$$f; echo ""; done

test: _file _compare

clean:
	@$(RM) -r ${PDFFLD} ${DIFFLD} ${BUILDFLD}
	@echo "Done!"

# Target specific variables
_compare : RANGE="$(shell	A="$(shell echo ${BASENAME} \
	| grep -o "(\[.*\])" | sed "s/\[//;s/\]//;s/,/ /g"	)"; \
	for a in $$A; do if [ -z "`echo "$$a" | grep -o "-"`" ]; then echo "$$a"; \
	else seq `echo -n "$$a" | sed 's/-/ /'`; fi; done)"
_compare : PAGES=$(shell pdfinfo $(PDFFILE) | awk '$$1 ~ /^Pages:/ {print $$2}')
_compare : LAST=$(shell expr $(PAGES) - 1)
_compare : FULLRANGE=$(shell seq 0 $(LAST))
_compare:
	@mkdir -p $(DIFFLD)
	@mkdir -p $(TMPFLD)
	@$(GS) -q -dQUIET -dSAFER -dBATCH -dNOPAUSE -dNOPROMPT -o $(TMPFLD)/test%d.png -sDEVICE=pngalpha -dFirstPage=1 -dLastPage=$(LAST) -dMaxBitmap=500000000 -dAlignToPixels=0 -dGridFitTT=2 $(PDFFLD)/$(BASENAME).pdf
	@$(GS) -q -dQUIET -dSAFER -dBATCH -dNOPAUSE -dNOPROMPT -o $(TMPFLD)/proto%d.png -sDEVICE=pngalpha -dFirstPage=1 -dLastPage=$(LAST) -dMaxBitmap=500000000 -dAlignToPixels=0 -dGridFitTT=2 $(PROTOPDF)
	@ERR=""; R=`if [ -z ${RANGE} ]; then echo ${FULLRANGE}; else echo ${RANGE}; fi`; \
		echo "Testing document `readlink -f ${PDFFLD}`/${BASENAME}.pdf"; \
		for p in $$R; do RES="$$($(COMPARE) -metric ae ${TMPFLD}/test$$p.png ${TMPFLD}/proto$$p.png \
		${DIFFLD}/${BASENAME}_p$$p.png 2>&1)"; \
		if [ "$${RES}" = "0" ]; then echo -ne "\e[1;32m.\e[0m"; rm ${DIFFLD}/${BASENAME}_p$$p.png; \
		else echo -ne "\e[1;31mx\e[0m"; ERR="$${ERR} $$p"; \
		fi; \
	done; echo ""; if [ -z "$${ERR}" ]; then \
	echo "No diff was detected!"; else echo "diff on pages: $${ERR}"; \
	echo "diff-image(s) is available in `readlink -f ${DIFFLD}`"; fi

_file: _ctrl_
	@$(RM) $(PDFFILE)
	@mkdir -p $(BUILDFLD)
	@mkdir -p $(PDFFLD)
	@$(LAMEBUILD)
	@$(BUILDGLOSS)
	@$(BUILD)
	@mv $(BUILDFLD)/$(OUTPUTNAME).pdf $(PDFFILE)
	@$(RM) -r $(BUILDFLD) > /dev/null

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
