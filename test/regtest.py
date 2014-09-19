
import os
from os.path import join
import re
import subprocess



class debug:
	INFO	= "\\033[1;34m"
	DEBUG	= "\\033[1;32m"
	WARNING = "\\033[1;33m"
	ERROR = "\\033[1;31m"
	FUCK = "\\033[1;41m"
dlvl = [debug.INFO, debug.DEBUG, debug.WARNING, debug.ERROR, debug.FUCK]

DEBUGLEVEL = debug.INFO
	
GS = None
GSOPTS = " -q -dQUIET -dSAFER -dBATCH -dNOPAUSE -dNOPROMPT -sDEVICE=pngalpha -dMaxBitmap=500000000 -dAlignToPixels=0 -dGridFitTT=2 "

CMP = None
CMPOPTS = " -metric ae "

SCRIPTDIR = os.path.relpath(os.path.dirname(os.path.realpath(__file__))).replace("\\", "/")

def echo(*string):
	color = ""
	if string[0] in dlvl:
		if dlvl.index(string[0]) < dlvl.index(DEBUGLEVEL):
			return
		color = string[0]
		string = string[1:]
	s = "echo -e \"" + color + " ".join([str(x) for x in string]) + "\\033[0m"
	subprocess.Popen(s).wait()

def genFileList(dir=join(SCRIPTDIR, "pdfs")):
	dir = dir.replace("\\", "/")
	FILES = {}
	for f in os.listdir(dir):
		if f.startswith("test") and f.endswith(".pdf"):
			try:
				file =  join(dir, f).replace("\\","/")
				FILES[file] = _getRange(file)
			except Exception as e:
				echo(debug.WARNING, "FILE: ", file)
				echo(debug.WARNING, "EXCEPTION: ", e)

	return FILES

def _getRange(file):
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
	for dir in dirs:
		if os.path.exists(dir):
			raise Exception(dir + " EXISTS, DELETE IT!")
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
	
def testFiles(FILES, protodir=join(SCRIPTDIR, "proto").replace("\\", "/"), tmpdir=join(SCRIPTDIR, "tmp").replace("\\", "/"), diffdir=join(SCRIPTDIR, "diffs").replace("\\", "/")):
	controlAndCreateDirs(tmpdir, diffdir)
	for file in FILES:
		protofile = join(protodir, os.path.basename(file)).replace("\\","/").replace("test", "proto")
		_testFile(file, FILES[file], protofile, tmpdir, diffdir)
	_cleanup(tmpdir)
	_cleanupIfEmpty(diffdir)
	
def _testFile(file, range, protofile, tmpdir, diffdir):
	basename = os.path.basename(file)
	echo(debug.INFO, "Testing file '" + basename + "'")
	noext = os.path.splitext(basename)[0]
	_genPNG(file, range, noext, tmpdir)
	_genPNG(protofile, range, "proto_" + noext ,tmpdir)
	_compare(noext, range, tmpdir, diffdir)

def _genPNG(srcfile, range, noext, tmpdir):	
	#for page in range:
		lastpage = _getPDFPages(srcfile)
		outfile = join(tmpdir, noext+"_%d.png").replace("\\","/")#%d.png").replace("\\","/")	
		#outfilecmd = GS + GSOPTS + "-o " + outfile + " -dFirstPage=" + str(page) + " -dLastPage=" + str(page) + " " + srcfile
		outfilecmd = GS + GSOPTS + "-o " + outfile + " -dFirstPage=1" + " -dLastPage=" + str(lastpage) + " " + srcfile
		echo(debug.INFO, "CMD: ", outfilecmd)
		gen = subprocess.Popen(outfilecmd, env=os.environ, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
		gen.wait()
		stderr = gen.stderr.readlines()
		if len(stderr) is not 0:
			raise Exception(stderr)
	
def _compare(noext, range, tmpdir, diffdir):
	for page in range:
		src =  join(tmpdir, noext+"_"+str(page)+".png").replace("\\","/")
		proto =  join(tmpdir, "proto_" + noext+"_"+str(page)+".png").replace("\\","/")
		diff =  join(diffdir, "diff_"+noext+"_"+str(page)+".png").replace("\\","/")
		
		cmpcmd = CMP + CMPOPTS + src + " " + proto + " " + diff
		echo(debug.INFO, "cmpcmd: ", cmpcmd)
		cmp = subprocess.Popen(cmpcmd, env=os.environ, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
		cmp.wait()
		
		stderr = cmp.stderr.readlines()
		diffnum = stderr[0]
		
		
		if int(diffnum) is 0:
			echo(debug.INFO, "Page", page, "in document '" + noext + "' is OK!")
			os.remove(diff)
		else:
			echo(debug.WARNING, "Page", page, "in document '" + noext + "' has diff: ", diffnum)
		os.remove(src)
		os.remove(proto)
		
def printDict(dict):
	for k in dict:
		print k,":",dict[k]
		
if __name__ == '__main__':
	try:
		GS  = _getGhostScript()
		CMP = _getCompare()
		f = genFileList()
		testFiles(f)
	except Exception as e:
		echo(debug.FUCK, e)

