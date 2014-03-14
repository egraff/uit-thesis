BUILDFILE=`basename $(FILE) .tex`.tex#

# All files produced while making the document will have this basename
OUTPUTNAME = output

# Placement of all produced files
BUILDFLD = ./.build

# Extra options, these must be available for both pdflatex and latexmk
DEFOPT = -output-directory=$(BUILDFLD) $(OPT) #-quiet

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
      

test: _file
	$(compare -density

_file: _ctrl_
	@mkdir -p $(BUILDFLD)
	@$(LAMEBUILD)
	@$(BUILDGLOSS)
	@$(BUILD)
	@mv $(BUILDFLD)/$(OUTPUTNAME).pdf `basename $(FILE) .tex`.pdf
	@$(RM) -r $(BUILDFLD) > /dev/null

_ctrl_:
ifeq ($(FILE),)
	@echo "Specify a FILE"
	@exit 1
endif
