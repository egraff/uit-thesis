#!/usr/bin/env python

import testenv
import asynclib

import threading
import subprocess
import re
import os
import sys
import json


SCRIPTDIR   = os.path.relpath(os.path.dirname(os.path.realpath(__file__))).replace("\\", "/")
TESTDIR     = os.path.relpath(os.path.join(SCRIPTDIR, "..")).replace("\\", "/")
TEXTESTDIR  = os.path.join(TESTDIR, "tests").replace("\\", "/")
PDFSDIR     = os.path.join(TESTDIR, "pdfs").replace("\\", "/")
PROTODIR    = os.path.join(TESTDIR, "proto").replace("\\", "/")
TMPDIR      = os.path.join(TESTDIR, "tmp").replace("\\", "/")
DIFFDIR     = os.path.join(TESTDIR, "diffs").replace("\\", "/")


TESTFILEPREFIX  = "test"
PROTOFILEPREFIX = "proto"


class debug:
  NORMAL = "\\033[0m"
  INFO  = "\\033[1;34m"
  DEBUG = "\\033[0;32m"
  WARNING = "\\033[1;33m"
  YELLOW = "\\033[1;33m"
  ERROR = "\\033[1;31m"
  FUCK = "\\033[1;41m"
  GREEN = "\\033[1;32m"
  WHITE = "\\033[1;37m"
dlvl = [debug.INFO, debug.DEBUG, debug.WARNING, debug.FUCK, debug.NORMAL, debug.WHITE, debug.GREEN, debug.YELLOW, debug.ERROR]


DEBUGLEVEL = debug.INFO
NUM_DOTS_PER_LINE = 80


GS = testenv.getGhostScript()
CMP = testenv.getCompare()
PDFINFO = testenv.getPDFInfo()


testenv.mkdirp(PDFSDIR)
testenv.mkdirp(TMPDIR)
testenv.mkdirp(DIFFDIR)


def echo(*string):
  color = ""
  if string[0] in dlvl:
    if dlvl.index(string[0]) < dlvl.index(DEBUGLEVEL):
      return

    color = string[0]
    string = string[1:]

  s = "sh -c \"printf \\\"" + color + " ".join([str(x).replace("\n", "\\n") for x in string]) + "\\033[0m\\\"\""
  asynclib.AsyncPopen(s, shell=True).wait()


def convertPdfPageToPngAsync(pdfPath, pageNum, outputPngPath):
  gsCmd = [
            GS, '-q', '-dQUIET', '-dSAFER', '-dBATCH', '-dNOPAUSE',
            '-dNOPROMPT', '-sDEVICE=pngalpha', '-dMaxBitmap=500000000',
            '-dAlignToPixels=0', '-dGridFitTT=2', '-r150',
            '-o', outputPngPath, '-dFirstPage=%s' % pageNum,
            '-dLastPage=%s' % pageNum, pdfPath
          ]

  task = asynclib.AsyncPopen(gsCmd, shell=False, env=os.environ, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  return task


class ComparePngsAsyncTask(asynclib.AsyncTask):
  def __init__(self, pngPathFirst, pngPathSecond, outputDiffPath):
    cmpCmd = [CMP, '-metric', 'ae', pngPathFirst, pngPathSecond, outputDiffPath]
    self.__cmpProc = subprocess.Popen(cmpCmd, shell=False, env=os.environ, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

  def wait(self):
    self.__cmpProc.wait()
    lines = self.__cmpProc.stderr.readlines()
    assert self.__cmpProc.returncode <= 1

    # Needed because lines[0] could be something like "1.33125e+006"
    self.__result = int(float(lines[0]))

  # Result is diff (0 means equal)
  @property
  def result(self):
    return self.__result


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
  def getPngForPageAsync(self, pageNum, outputPngPath):
    assert pageNum >= 1
    assert pageNum <= self.numPhysicalPages()

    return convertPdfPageToPngAsync(self.path, pageNum, outputPngPath)

  # Generate PNG for given page number in PDF
  def getPngForPage(self, pageNum, outputPngPath, callback):
    task = self.getPngForPageAsync(pageNum, outputPngPath)
    task.await(callback)


class TestPdfPagePair(asynclib.AsyncTask):
  def __init__(self, testPdfObj, protoPdfObj, pageNum, testPngPath, protoPngPath):
    self.pageNum = pageNum
    self.testPngPath = testPngPath
    self.protoPngPath = protoPngPath

    self.testPngPagePath = "%s_%s.png" % (self.testPngPath, self.pageNum)
    self.protoPngPagePath = "%s_%s.png" % (self.protoPngPath, self.pageNum)
    self.diffPath = "%s/diff_%s_%s.png" % (DIFFDIR, os.path.basename(self.testPngPath), self.pageNum)

    # Start processes for generating PNGs
    self.testPdfTask = testPdfObj.getPngForPageAsync(pageNum, self.testPngPagePath)
    self.protoPdfTask = protoPdfObj.getPngForPageAsync(pageNum, self.protoPngPagePath)

    # Wait asynchronously for PNG processes to complete
    # Note: we start a worker thread with await(), because we want to initiate the
    # compare operation as soon as possible, rather than after self.wait() has been
    # called.
    self.joinedPdfTask = asynclib.JoinedAsyncTask(self.testPdfTask, self.protoPdfTask)
    self.joinedPdfTask.await(self._compare)

    # Wait routine for this task is thread-join for joined task
    self.wait = self.joinedPdfTask.wait

  def _compare(self, results):
    genPngProcs = results

    genTestPngProc, genProtoPngProc = genPngProcs
    assert genTestPngProc.returncode == 0, "Failed to generate PNG %s" % (self.testPngPagePath,)
    assert genProtoPngProc.returncode == 0, "Failed to generate PNG %s" % (self.protoPngPagePath,)

    task = ComparePngsAsyncTask(self.testPngPagePath, self.protoPngPagePath, self.diffPath)

    # Wait synchronously since we're already executing in separate thread
    task.wait()
    aeDiff = task.result

    self.__pngsAreEqual = (aeDiff == 0)

    if self.__pngsAreEqual:
      os.remove(self.testPngPagePath)
      os.remove(self.protoPngPagePath)
      os.remove(self.diffPath)

    self.__result = (self.pageNum, self.__pngsAreEqual)

  # Result is on the form (pagenum, PNGs are equal)
  @property
  def result(self):
    return self.__result


# Use file name of PDF to determine which pages we want to test
def determineListOfPagesToTest(pdfObj):
  numPages = pdfObj.numPhysicalPages()
  basename = os.path.basename(pdfObj.path)
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
      assert pageNum <= numPages
  else:
    pageList = range(1, numPages + 1)

  return pageList


class TestPdfPair(asynclib.AsyncTask):
  def __init__(self, testName):
    self.testName = testName

    testPdfPath = "%s/%s.pdf" % (PDFSDIR, testName)
    protoPdfPath = "%s/%s.pdf" % (PROTODIR, testName)

    testPngPath  = "%s/%s" % (TMPDIR, testName)
    protoPngPath = "%s/%s_%s" % (TMPDIR, PROTOFILEPREFIX, testName)

    testPdfObj = PdfFile(testPdfPath)
    protoPdfObj = PdfFile(protoPdfPath)

    pageList = determineListOfPagesToTest(testPdfObj)

    testTasks = []
    for pageNum in pageList:
      task = TestPdfPagePair(testPdfObj, protoPdfObj, pageNum, testPngPath, protoPngPath)
      testTasks.append(task)

    self.__joinedTestTask = asynclib.JoinedAsyncTask(*testTasks)
    self.wait = self.__joinedTestTask.wait

  # Result is on the form (testname, list of failed pages)
  @property
  def result(self):
    pngResults = self.__joinedTestTask.result

    failedPages = []
    for pageNum, pngsAreEqual in pngResults:
      if not pngsAreEqual:
        failedPages.append(pageNum)

    return (self.testName, failedPages)


def makeTestTask(testName):
  cmd = ['make', '--no-print-directory', '_file', 'RETAINBUILDFLD=y', 'FILE=%s.tex' % testName]
  task = asynclib.AsyncPopen(cmd, shell=False, env=os.environ, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  return task


class TestTask(asynclib.AsyncTask):
  def __init__(self, testName):
    self.testName = testName

    task = makeTestTask(self.testName)
    task.await(self._makeTaskComplete)
    self.wait = task.wait

  def _makeTaskComplete(self, proc):
    if proc.returncode != 0:
      self.__result = (self.testName, False, proc)
      return

    task = TestPdfPair(self.testName)
    task.wait()
    _, failedPages = task.result

    testPassed = (len(failedPages) == 0)

    self.__result = (self.testName, True, failedPages)

  # Result is on the form
  #  (test name, Build succeeded = TRUE, list of failed pages)
  # or
  #   (test name, Build succeeded = FALSE, build proc)
  @property
  def result(self):
    return self.__result


def testGenerator():
  for fileName in os.listdir(TEXTESTDIR):
    # Ignore files that contain spaces
    if " " in fileName:
      continue

    if not fileName.startswith(TESTFILEPREFIX):
      continue

    if not fileName.endswith(".tex"):
      continue

    yield os.path.splitext(fileName)[0]


class TestRunner():
  testResultLock = threading.Lock()
  numTestsCompleted = 0
  failedTests = []
  tasks = []

  @classmethod
  def __testCallback(cls, result):
    testName, buildSucceeded, failedPages = result
    testPassed = buildSucceeded and (len(failedPages) == 0)

    with cls.testResultLock:
      if cls.numTestsCompleted % NUM_DOTS_PER_LINE == 0:
        echo(debug.WHITE, "\n")

      cls.numTestsCompleted += 1

      if testPassed:
        echo(debug.GREEN, ".")
      else:
        echo(debug.ERROR, "F" if buildSucceeded else "B")
        cls.failedTests.append(result)

  @classmethod
  def run(cls, testNames):
    for testName in testNames:
      task = TestTask(testName)
      task.await(cls.__testCallback)
      cls.tasks.append(task)

  @classmethod
  def waitForSummary(cls):
    asynclib.JoinedAsyncTask(*cls.tasks).wait()
    
    resultMap = {}

    with cls.testResultLock:
      with open(os.path.join(TESTDIR, "test_result.json").replace("\\", "/"), 'wb') as fp:
        resultMap['num_tests'] = cls.numTestsCompleted
        resultMap['failed_tests'] = []
        echo(debug.WHITE, "\n\n\nRan %s tests, " % (cls.numTestsCompleted,))

        if len(cls.failedTests) == 0:
          echo(debug.GREEN, "all succeeded!\n\n")
          json.dump(resultMap, fp)
          sys.exit(0)
        else:
          echo(debug.ERROR, "%s failed" % (len(cls.failedTests),))
          echo(debug.WHITE, ".\n\nError summary:\n\n")

          for testName, buildSucceeded, arg in cls.failedTests:
            failedTestMap = {}
            failedTestMap['test_name'] = testName
            failedTestMap['build_succeeded'] = buildSucceeded
            echo(debug.WHITE, "  %s\n" % (testName,))
            if not buildSucceeded:
              proc = arg
              failedTestMap['proc'] = {}
              failedTestMap['proc']['returncode'] = proc.returncode
              failedTestMap['proc']['stdout'] = []
              failedTestMap['proc']['stderr'] = []
              echo(debug.ERROR, "    Build failed!\n")
              echo(debug.ERROR, "    stdout output:\n")
              for line in proc.stdout:
                line = line.rstrip('\n')
                failedTestMap['proc']['stdout'].append(line)
                echo(debug.NORMAL, "      %s\n" % (line,))
              echo(debug.ERROR, "\n    stderr output:\n")
              for line in proc.stderr:
                line = line.rstrip('\n')
                failedTestMap['proc']['stderr'].append(line)
                echo(debug.NORMAL, "      %s\n" % (line,))
              latexLogFile = ".build/%s/output.log" % (testName,)
              if os.path.exists(latexLogFile):
                failedTestMap['log_file'] = latexLogFile
                echo(debug.WHITE, "\n    see %s for more info.\n\n" % (latexLogFile,))
              else:
                echo(debug.WHITE, "\n\n")
            else:
              failedPages = arg
              failedTestMap['failed_pages'] = failedPages
              failedPagesString = ", ".join(str(x) for x in failedPages)
              echo(debug.ERROR, "    Pages with diff: %s.\n\n" % (failedPagesString,))
            resultMap['failed_tests'].append(failedTestMap)

          echo(debug.YELLOW, "PNGs containing diffs are available in '%s'\n\n" % (DIFFDIR,))
          json.dump(resultMap, fp)
          sys.exit(1)


if __name__ == '__main__':
  TestRunner.run(testGenerator())
  TestRunner.waitForSummary()
