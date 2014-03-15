TESTDIR = ./test

FILES := `ls ${TESTDIR} | grep -Po "^test.*\.tex" | sort -V`

all:
	@for f in $(FILES); do $(MAKE) -s -C $(TESTDIR) FILE=$$f; done
