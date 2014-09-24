
import os, sys
import re
import subprocess

SCRIPTDIR = os.path.relpath(os.path.dirname(os.path.realpath(__file__))).replace("\\", "/")
PDFSDIR   = os.path.join(SCRIPTDIR, "pdfs").replace("\\", "/")
PROTODIR  = os.path.join(SCRIPTDIR, "proto").replace("\\", "/")
TMPDIR    = os.path.join(SCRIPTDIR, "tmp").replace("\\", "/")
DIFFDIR   = os.path.join(SCRIPTDIR, "diffs").replace("\\", "/")

TESTFILEPREFIX  = "test"
PROTOFILEPREFIX = "proto"

class debug:
  INFO  = "\\033[1;34m"
  DEBUG = "\\033[0;32m"
  WARNING = "\\033[1;33m"
  YELLOW = "\\033[1;33m"
  ERROR = "\\033[1;31m"
  FUCK = "\\033[1;41m"
  GREEN = "\\033[1;32m"
  WHITE = "\\033[1;37m"
dlvl = [debug.INFO, debug.DEBUG, debug.WARNING, debug.FUCK, debug.WHITE, debug.GREEN, debug.YELLOW, debug.ERROR]

DEBUGLEVEL = debug.WARNING

SHOWDETAILEDINFO = False

NUM_DOTS_PER_LINE = 80

GS = None
GSOPTS = " -q -dQUIET -dSAFER -dBATCH -dNOPAUSE -dNOPROMPT -sDEVICE=pngalpha -dMaxBitmap=500000000 -dAlignToPixels=0 -dGridFitTT=2 "
CMP = None
CMPOPTS = " -metric ae "


def echo(*string):
  color = ""
  if string[0] in dlvl:
    if dlvl.index(string[0]) < dlvl.index(DEBUGLEVEL):
      return

    color = string[0]
    string = string[1:]

  s = "echo -e \"" + color + " ".join([str(x) for x in string]) + "\\033[0m\\c"
  subprocess.Popen(s).wait()

def genFileList():
  FILES = {}
  for f in os.listdir(PDFSDIR):
    if f.startswith(TESTFILEPREFIX) and f.endswith(".pdf"):
      try:
        file = "%s/%s" % (PDFSDIR, f)
        if " " in file:
          raise Exception("Filename cannot contain space")

        protofile = "%s/%s" % (PROTODIR, f)

        if not os.path.exists(protofile):
          raise Exception("Protofile '%s' does not exist" % (protofile,))

        if _getPDFPages(file) != _getPDFPages(protofile):
          raise Exception("File '%s' and protofile '%s' do not have the same number of pages" % (file, protofile,))

        FILES[file] = _genRange(file)
      except Exception as e:
        echo(debug.FUCK, "FILE: ", file)
        echo(debug.WHITE, "\n")
        echo(debug.FUCK, "EXCEPTION: ", e)
        echo(debug.WHITE, "\n")

  return FILES

def _genRange(file):
  basename = os.path.basename(file)
  noext = os.path.splitext(basename)[0]

  numpagesinpdf = _getPDFPages(file)

  # search for a range in filename ( denoted with [ ] ) and save only the range
  textrange = re.search(r"\[.*\]", noext)
  if textrange is not None:
    # remove brackets and commas
    textrange = re.sub(r"([\[\]])", r"", textrange.group()).replace(r",", " ")
    newrange = []

    # make list and translate hyphen into a sequence, e.g 3-6 -> "3 4 5 6"
    for num in textrange.split(" "):
      if "-" in num:
        numrange = num.split("-")
        if len (numrange) != 2:
          raise Exception("syntax error in range")

        numrange = range(int(numrange[0]), int(numrange[1]) + 1)
        newrange.extend(numrange)
      else:
        newrange.append(int(num))

    newrange = sorted(set(newrange))

    for num in newrange:
      if num > numpagesinpdf:
        raise Exception("range goes past number of pages in pdf")

  else:
    newrange = range(1, numpagesinpdf + 1)

  return newrange

def _getPDFPages(file):
  # use pdfinfo to extract number of pages in pdf file
  output = subprocess.check_output(["pdfinfo", file])
  pages = re.findall(r"\d+", re.search(r"Pages:.*", output).group())[0]

  return int(pages)

def _getGhostScript():
  gs = None

  try:
    whichGc = subprocess.Popen(["sh", "-c", "which gc || which gswin64c || which gswin32c"], env=os.environ, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    whichGc.wait()
    gs = whichGc.stdout.readline().strip()

    if gs == '':
      raise Exception("")

    gs = os.path.basename(gs)
  except:
    raise Exception("GhostScript was not found")

  return gs

def _getCompare():
  cmp = None

  try:
    whichCmp = subprocess.Popen(["sh", "-c", "which compare"], env=os.environ, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    whichCmp.wait()
    cmp = whichCmp.stdout.readline().strip()

    if cmp == '':
      raise Exception("")

    cmp = os.path.basename(cmp)
  except:
    raise Exception("Compare was not found")

  return cmp

def controlAndCreateDirs(*dirs):
  dirstodelete = []

  for dir in dirs:
    if os.path.exists(dir):
      dirstodelete.append(dir)

  if len(dirstodelete) > 0:
    raise Exception("Directories '%s' must be deleted or renamed" % ("', '".join(dirstodelete),))

  for dir in dirs:
    echo(debug.INFO, "mkdir", dir + "\n")
    os.makedirs(dir)

def _cleanup(*dirs):
  echo(debug.INFO, "Cleanup dir\n")

  for dir in dirs:
    echo(debug.INFO, "DIR:", dir + "\n")

    for file in os.listdir(dir):
      echo(debug.INFO, "rm FILE:", os.path.join(dir, file).replace("\\", "/") + "\n")
      os.remove(os.path.join(dir, file).replace("\\", "/"))

    echo(debug.INFO, "rmdir", dir + "\n")
    os.rmdir(dir)

def _cleanupIfEmpty(*dirs):
  echo(debug.INFO, "Cleanup if empty dir\n")

  for dir in dirs:
    echo(debug.INFO, "Cleanup dir:", dir + "\n")

    if len(os.listdir(dir)) == 0:
      for file in os.listdir(dir):
        echo(debug.INFO, "rm FILE:", os.path.join(dir, file).replace("\\", "/") + "\n")
        os.remove(os.path.join(dir, file).replace("\\", "/"))

      echo(debug.INFO, "rmdir", dir + "\n")
      os.rmdir(dir)
    else:
      echo(debug.INFO, dir, "is not empty, will not cleanup\n")

NUM_TESTS_RUN = 0
def testFiles(FILES):
  global NUM_TESTS_RUN
  num_failed = 0
  errors = []

  controlAndCreateDirs(TMPDIR, DIFFDIR)

  for file in FILES:
    didFail, error = _testFile(file, FILES[file])
    if didFail:
      num_failed += 1
      errors.append((file, error))

    NUM_TESTS_RUN += 1

  _cleanup(TMPDIR)
  _cleanupIfEmpty(DIFFDIR)

  return (num_failed, errors)

def _testFile(file, range):
  protofile = "%s/%s" % (PROTODIR, os.path.basename(file))
  echo(debug.INFO, "Comparing '%s' with '%s'\n" % (file, protofile))

  file_tmp  = "%s/%s" % (TMPDIR, os.path.basename(file))
  proto_tmp = "%s/%s_%s" % (TMPDIR, PROTOFILEPREFIX, os.path.basename(file))

  _genPNG(range, (file, file_tmp), (protofile, proto_tmp))

  return _compare(file, protofile, file_tmp, proto_tmp, range)

def _genPNG(pagerange, *inputOutputFilePairs):
  echo(debug.INFO, "Creating PNG pages\n")

  __PNGProcs = []

  for tup in inputOutputFilePairs:
    inputFile, outputFile = tup

    for page in pagerange:
      echo(debug.INFO, "%s => %s (page %s)\n" % (inputFile, outputFile, page))
      __PNGProcs.append(__genPNGPageProc(inputFile, page, os.path.splitext(outputFile)[0]))

  for proc in __PNGProcs:
    proc.wait()
    if proc.returncode != 0:
      print "FUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUCK"
      print proc.stdout.readlines(), proc.stderr.readlines()

def __genPNGPageProc(srcfile, page, noext):
  outfile = "%s_%s.png" % (noext, page)
  outfilecmd = GS + GSOPTS + "-o %s -dFirstPage=%s -dLastPage=%s %s" % (outfile, page, page, srcfile)

  echo(debug.INFO, "CMD: %s\n" % (outfilecmd,))

  gsCmd = subprocess.Popen(outfilecmd, env=os.environ, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

  return gsCmd

def _compare(srcfilename, protofilename, srcfile, protofile, range):
  global NUM_TESTS_RUN

  echo(debug.INFO, "Comparing pages\n")

  __CMPProcs = []
  srcfilenoext = os.path.splitext(srcfile)[0]
  protofilenoext = os.path.splitext(protofile)[0]

  for page in range:
    __CMPProcs.append(__compareProc(srcfilenoext, protofilenoext, page))

  errorpages = []
  numerrors = 0

  for page, noext, src, proto, diff, proc in __CMPProcs:
    proc.wait()
    diffnum = proc.stderr.readlines()[0]

    if int(diffnum) == 0:
      echo(debug.INFO, "Page", "{:>4}".format(page), "in document '" + srcfilename + "' is OK!\n")
      os.remove(diff)
    else:
      numerrors += 1
      errorpages.append(page)

      if SHOWDETAILEDINFO:
        echo(debug.WARNING, "Page", "{:>4}".format(page), "in document '" + srcfilename + "' has diff: ", "{:>10}".format(diffnum) + "\n")

  if numerrors != 0:
    if SHOWDETAILEDINFO:
      echo(debug.ERROR, "'%s' and '%s' has diffs in '%s' pages:\n" % (srcfilename, protofilename, numerrors))
      echo(debug.ERROR, errorpages, "\n")

      return (True, None)
    else:
      echo(debug.ERROR, "F")
      error = "diffs in %s pages: %s" % (numerrors, repr(errorpages))

      return (True, error)
  else:
    if SHOWDETAILEDINFO:
      echo(debug.GREEN, "'%s' and '%s' has no diffs!\n" % (srcfilename, protofilename))
    else:
      echo(debug.GREEN, ".%s" % ("\n" if NUM_TESTS_RUN % NUM_DOTS_PER_LINE == (NUM_DOTS_PER_LINE - 1) else "",))

    return (False, None)

def __compareProc(srcfilenoext, protofilenoext, page):
  src   = "%s_%s.png" % (srcfilenoext, page)
  proto = "%s_%s.png" % (protofilenoext, page)
  diff  = "%s/diff_%s_%s.png" % (DIFFDIR, os.path.basename(srcfilenoext), page)

  cmpcmd = CMP + CMPOPTS + src + " " + proto + " " + diff

  echo(debug.INFO, "cmpcmd: %s\n" % (cmpcmd,))

  return (page, srcfilenoext, src, proto, diff, subprocess.Popen(cmpcmd, env=os.environ, stdout=subprocess.PIPE, stderr=subprocess.PIPE))

if __name__ == '__main__':
  try:
    GS  = _getGhostScript()
    CMP = _getCompare()
    f = genFileList()

    num_failed, errors = testFiles(f)

    echo(debug.WHITE, "\n\n")

    if num_failed > 0:
      if not SHOWDETAILEDINFO:
        # Error summary
        echo(debug.WHITE, "\nFailures:\n\n")

        for i in range(len(errors)):
          file, err = errors[i]

          echo(debug.WHITE, "  %s) %s\n" % (i + 1, file,))
          echo(debug.ERROR, "    " + err + "\n\n")

      echo(debug.ERROR, "\nRan %s tests, %s failed\n" % (len(f), num_failed))
      echo(debug.YELLOW, "PNGs containing diffs are avilable in '%s'\n\n" % (DIFFDIR,))
      sys.exit(1)
    else:
      echo(debug.GREEN, "Ran %s tests, %s failed\n\n" % (len(f), num_failed))
      sys.exit(0)
  except Exception as e:
    echo(debug.WHITE, "\n")
    echo(debug.FUCK, e)
    echo(debug.WHITE, "\n")
