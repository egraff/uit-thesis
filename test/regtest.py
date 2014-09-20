
import os
from os.path import join
import re
import subprocess



SCRIPTDIR = os.path.relpath(os.path.dirname(os.path.realpath(__file__))).replace("\\", "/")
PDFSDIR   = join(SCRIPTDIR, "pdfs").replace("\\", "/")
PROTODIR  = join(SCRIPTDIR, "proto").replace("\\", "/")
TMPDIR    = join(SCRIPTDIR, "tmp").replace("\\", "/")
DIFFDIR   = join(SCRIPTDIR, "diffs").replace("\\", "/")

TESTFILEPREFIX  = "test"
PROTOFILEPREFIX = "proto"

class debug:
	INFO	= "\\033[1;34m"
	DEBUG	= "\\033[0;32m"
	WARNING = "\\033[1;33m"
	ERROR = "\\033[1;31m"
	FUCK = "\\033[1;41m"
	GREEN = "\\033[1;32m"
	WHITE = "\\033[1;37m"
dlvl = [debug.INFO, debug.DEBUG, debug.WARNING, debug.ERROR, debug.FUCK, debug.WHITE, debug.GREEN]

DEBUGLEVEL = debug.ERROR


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
	s = "echo -e \"" + color + " ".join([str(x) for x in string]) + "\\033[0m"
	subprocess.Popen(s).wait()

def printDict(dict):
	for k in dict:
		print k,":",dict[k]	

def genFileList():
	FILES = {}
	for f in os.listdir(PDFSDIR):
		if f.startswith(TESTFILEPREFIX) and f.endswith(".pdf"):
			try:
				file =  join(PDFSDIR, f).replace("\\","/")
				if " " in file:
					raise Exception("Filename cannot contain space")
				protofile = join(PROTODIR, f).replace("\\","/").replace(TESTFILEPREFIX, PROTOFILEPREFIX)
				if not os.path.exists(protofile):
					raise Exception("Protofile '" + protofile + "' does not exist")
				FILES[file] = _genRange(file)
			except Exception as e:
				echo(debug.ERROR, "FILE: ", file)
				echo(debug.ERROR, "EXCEPTION: ", e)
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
		if gs is '':
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
		if cmp is '':
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
		raise Exception("Dir '" + "', '".join(dirstodelete) + "' must be deleted or renamed")
	for dir in dirs:
		echo(debug.INFO, "mkdir", dir)
		os.makedirs(dir)

def _cleanup(*dirs):
	echo(debug.INFO, "Cleanup dir")
	for dir in dirs:
		echo(debug.INFO, "DIR:",dir)
		for file in os.listdir(dir):
			echo(debug.INFO, "rm FILE:",join(dir,file).replace("\\","/"))
			os.remove(join(dir,file).replace("\\","/"))
		echo(debug.INFO, "rmdir", dir)
		os.rmdir(dir)
		
def _cleanupIfEmpty(*dirs):
	echo(debug.INFO, "Cleanup if empty dir")
	for dir in dirs:
		echo(debug.INFO, "Cleanup dir:",dir)
		if len(os.listdir(dir)) is 0:
			for file in os.listdir(dir):
				echo(debug.INFO, "rm FILE:",join(dir,file).replace("\\","/"))
				os.remove(join(dir,file).replace("\\","/"))
			echo(debug.INFO, "rmdir", dir)
			os.rmdir(dir)
		else:
			echo(debug.INFO, dir, "is not empty, will not cleanup")
	
def testFiles(FILES):
	controlAndCreateDirs(TMPDIR, DIFFDIR)
	for file in FILES:
		_testFile(file, FILES[file])
	_cleanup(TMPDIR)
	_cleanupIfEmpty(DIFFDIR)

def _testFile(file, range):
	protofile = join(PROTODIR, os.path.basename(file)).replace("\\","/").replace(TESTFILEPREFIX, PROTOFILEPREFIX)
	echo(debug.WHITE, "Comparing '" + file + "' with '" + protofile + "'")
	_genPNG(range, file, protofile)
	_compare(file, protofile, range)

def _genPNG(range, *srcfiles):
	echo(debug.WHITE, "Creating PNG pages")
	__PNGProcs = []
	for file in srcfiles:
		basename = os.path.basename(file)
		noext = os.path.splitext(basename)[0]
		for page in range:
			__PNGProcs.append(__genPNGPageProc(file, page, noext))
	for proc in __PNGProcs:
		proc.wait()
	
def __genPNGPageProc(srcfile, page, noext):
	outfile = join(TMPDIR, noext+"_"+ str(page) + ".png").replace("\\","/")
	outfilecmd = GS + GSOPTS + "-o " + outfile + " -dFirstPage=" + str(page) + " -dLastPage=" + str(page) + " " + srcfile
	echo(debug.INFO, "CMD: ", outfilecmd)
	return subprocess.Popen(outfilecmd, env=os.environ, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

def _compare(srcfile, protofile, range):
	echo(debug.WHITE, "Comparing pages")
	__CMPProcs = []
	srcfilenoext = os.path.basename(os.path.splitext(srcfile)[0])
	protofilenoext = os.path.basename(os.path.splitext(protofile)[0])
	
	for page in range:
		__CMPProcs.append(__compareProc(srcfilenoext, protofilenoext, page))
		
	errorpages = []
	errors = 0
	for page, noext, src, proto, diff, proc in __CMPProcs:
		proc.wait()
		diffnum = proc.stderr.readlines()[0]

		if int(diffnum) is 0:
			echo(debug.INFO, "Page", "{:>4}".format(page), "in document '" + noext + "' is OK!")
			os.remove(diff)
		else:
			errors += 1
			errorpages.append(page)
			echo(debug.WARNING, "Page", "{:>4}".format(page), "in document '" + noext + "' has diff: ", "{:>10}".format(diffnum))
		os.remove(src)
		os.remove(proto)
	if errors is not 0:
		echo(debug.ERROR, "'" + srcfile + "' and '" + protofile + "' has diffs in '" + str(errors) +"' pages:")
		echo(debug.ERROR, errorpages)
		echo(debug.ERROR, "PNGs containing diffs are avilable in '" + DIFFDIR + "'\n")
	else:
		echo(debug.GREEN, "'" + srcfile + "' and '" + protofile + "' has no diffs!\n")

def __compareProc(srcfilenoext, protofilenoext, page):
	src =  join(TMPDIR, srcfilenoext+"_"+str(page)+".png").replace("\\","/")
	proto =  join(TMPDIR, protofilenoext+"_"+str(page)+".png").replace("\\","/")
	diff =  join(DIFFDIR, "diff_"+srcfilenoext+"_"+str(page)+".png").replace("\\","/")
	cmpcmd = CMP + CMPOPTS + src + " " + proto + " " + diff
	echo(debug.INFO, "cmpcmd: ", cmpcmd)
	return (page, srcfilenoext, src, proto, diff, subprocess.Popen(cmpcmd, env=os.environ, stdout=subprocess.PIPE, stderr=subprocess.PIPE))
		
if __name__ == '__main__':
	try:
		GS  = _getGhostScript()
		CMP = _getCompare()
		f = genFileList()
		testFiles(f)
	except Exception as e:
		echo(debug.FUCK, e)

