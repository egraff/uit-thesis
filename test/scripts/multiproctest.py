import testenv

import multiprocessing
import subprocess
import re
import os


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

DEBUGLEVEL = debug.INFO



GS = testenv.getGhostScript()
GSOPTS = " -q -dQUIET -dSAFER -dBATCH -dNOPAUSE -dNOPROMPT -sDEVICE=pngalpha -dMaxBitmap=500000000 -dAlignToPixels=0 -dGridFitTT=2 -r150 "


PDFINFO = testenv.getPDFInfo()

class Deferrer(object):
  def __init__(self, 


class AsyncPopen():
  def __init__(self, cmd, callback=None, *args, **kwargs):
    self.cmd = cmd
    self.callback = callback
    self.args = args
    self.kwargs = kwargs
    
    mp = multiprocessing.Process(target=self.mpTarget)
    mp.start()
  
  def mpTarget(self):
    proc = subprocess.Popen(self.cmd, *self.args, **self.kwargs)
    proc.wait()
    
    if self.callback:
      self.callback(proc)
#


def echo(*string):
  color = ""
  if string[0] in dlvl:
    if dlvl.index(string[0]) < dlvl.index(DEBUGLEVEL):
      return

    color = string[0]
    string = string[1:]

  s = "sh -c \"printf \\\"" + color + " ".join([str(x).replace("\n", "\\n") for x in string]) + "\\033[0m\\\"\""
  AsyncPopen(s, None, shell=True)


class PdfFile(object):
  def __init__(self, path):
    self.path = path

    self.__determineNumPagesInPdf()

  def __determineNumPagesInPdf(self):
    # use pdfinfo to extract number of pages in pdf file
    output = subprocess.check_output([PDFINFO, self.path])
    pages = re.findall(r"\d+", re.search(r"Pages:.*", output).group())[0]

    self.__numPages = int(pages)

  def numPhysicalPages(self):
    return self.__numPages

  # Generate PNG for given page number in PDF
  def getPngForPage(self, pageNum, outPathNoExt, callback):
    outFile = "%s_%s.png" % (outPathNoExt, pageNum)
    outFileCmd = GS + GSOPTS + "-o %s -dFirstPage=%s -dLastPage=%s %s" % (outFile, pageNum, pageNum, self.path)

    AsyncPopen(outFileCmd, callback, shell=True, env=os.environ, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

#

class TestPdf(PdfFile):
  def __init__(self, path):
    super(TestPdf, self).__init__(path)
    self.__determineListOfPagesToTest()

    # Shared memory value
    self.__callbackCounter = multiprocessing.Value('L', 0)

    self.__callback = None

  # Use file name of PDF to determine which pages we want to test
  def __determineListOfPagesToTest(self):
    basename = os.path.basename(self.path)
    noext = os.path.splitext(basename)[0]

    # search for a range in filename ( denoted with [ ] ) and save only the range
    textrange = re.search(r"\[.*\]", noext)
    if textrange is not None:
      # remove brackets and commas
      textrange = re.sub(r"([\[\]])", r"", textrange.group()).replace(r",", " ")
      pageList = []

      # make list and translate hyphen into a sequence, e.g 3-6 -> "3 4 5 6"
      for num in textrange.split(" "):
        if "-" in num:
          numrange = num.split("-")
          assert len(numrange) == 2

          numrange = range(int(numrange[0]), int(numrange[1]) + 1)
          pageList.extend(numrange)
        else:
          pageList.append(int(num))

      pageList = sorted(set(pageList))

      for pageNum in pageList:
        assert pageNum <= self.numPhysicalPages()
    else:
      pageList = range(1, self.numPhysicalPages() + 1)

    self.__pageList = pageList

  # Called when PNGs have been generated for all test pages in PDF
  def _doneCallback(self):
    self.__callback(self)

  # Called after generation of each page-PNG has completed
  def _singleCallback(self, proc):
    with self.__callbackCounter.get_lock():
      self.__callbackCounter.value += 1
      lastCallback = (self.__callbackCounter.value == len(self.__pageList))
      print "Single callback (%s/%s)" % (self.__callbackCounter.value, len(self.__pageList)), lastCallback

    if lastCallback:
      self._doneCallback()

  def generatePagePngs(self, outPathNoExt, callback):
    self.__callback = callback
    for pageNum in self.__pageList:
      PdfFile.getPngForPage(self, pageNum, outPathNoExt, self._singleCallback)

class TestPdfPair(object):
  def __init__(self, testName, callback):
    self.testName = testName

    # Shared memory value!
    self.__remainingCallbackCount = multiprocessing.Value('L', 2)

    testPdfPath = "%s/%s.pdf" % (PDFSDIR, testName)
    protoPdfPath = "%s/%s.pdf" % (PROTODIR, testName)

    testPngPath  = "%s/%s" % (TMPDIR, testName)
    protoPngPath = "%s/%s_%s" % (TMPDIR, PROTOFILEPREFIX, testName)

    self.__callback = callback

    testPdfObj = TestPdf(testPdfPath)
    testPdfObj.generatePagePngs(testPngPath, self._singleCallback)

    protoPdfObj = TestPdf(protoPdfPath)
    protoPdfObj.generatePagePngs(protoPngPath, self._singleCallback)

  # Called when both test PDF and prototype PDF have finished generating all PNGs
  def _doneCallback(self):
    echo(debug.INFO, "%s complete!\n" % (self.testName,))

  # Called for each PDF (test and proto) that has finished generating all PNGs
  def _singleCallback(self, pdfObj):
    with self.__remainingCallbackCount.get_lock():
      self.__remainingCallbackCount.value -= 1
      lastCallback = (self.__remainingCallbackCount.value == 0)

    if lastCallback:
      self._doneCallback()
    
def generateCallback(pdfObj):
  print pdfObj

if __name__ == '__main__':
  echo(debug.INFO, "Creating PNG pages\n")
  
  # echo(debug.INFO, "1\n")
  # TestPdf("pdfs/test_custom_autoref.pdf").generatePagePngs("tmp/test_custom_autoref", generateCallback)
  # echo(debug.INFO, "2\n")
  # TestPdf("pdfs/test-chapter_headings[1,3,5].pdf").generatePagePngs("tmp/test-chapter_headings[1,3,5]", generateCallback)
  # echo(debug.INFO, "3\n")
  # TestPdf("pdfs/test-section_headings_parindent.pdf").generatePagePngs("tmp/test-section_headings_parindent", generateCallback)
  # echo(debug.INFO, "4\n")
  # TestPdf("proto/test-section_headings_parindent.pdf").generatePagePngs("tmp/proto_test-section_headings_parindent", generateCallback)
  # echo(debug.INFO, "5\n")

  TestPdfPair("test-section_headings_parindent", None)