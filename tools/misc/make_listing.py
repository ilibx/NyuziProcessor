import sys, struct

class DebugInfo:
	# a run is (start addr, length, filename index, startLine)
	def __init__(self, filename):
		file = open(filename, 'r')
		magic, numRuns, stringTableSize = struct.unpack('III', file.read(12))
		self.runs = [ struct.unpack('IIII', file.read(16)) for x in range(numRuns) ]
		stringData = file.read(stringTableSize)
		rawStrings = stringData.split('\0')
		index = 0
		self.strings = {}
		for str in rawStrings:
			self.strings[index] = str
			index += len(str) + 1

	def lineForAddress(self, addr):
		for startAddr, length, filename, startLine in self.runs:
			if addr >= startAddr and addr < startAddr + length * 4:
				return self.strings[filename], (addr - startAddr) / 4 + startLine

		return None, None

	# Binary search doesn't work :)
	def oldlineForAddress(self, addr):
		low = 0
		high = len(self.runs) - 1
		while low <= high:
			mid = (low + high) / 2
			startAddr, length, filename, startLine = self.runs[mid]
			if addr < startAddr:
				high = mid - 1
			elif addr > startAddr + length * 4:
				low = mid + 1
			else:
				return ( self.strings[filename], ((addr - startAddr) / 4) + startLine )

		return None, None

def endianSwap(val):
	return ((val & 0xff) << 24) | ((val & 0xff00) << 8) | ((val & 0xff0000) >> 8) | ((val & 0xff000000) >> 24)
	
if len(sys.argv) != 2:
	print 'enter a hex filename'
	sys.exit(1)

sourceCodes = {}
path = sys.argv[1]
ext = path.rfind('.')
if ext == -1:
	print 'no extension'
	sys.exit(1)

debug = DebugInfo(path[:ext] + '.dbg')
file = open(path, 'r')
pc = 0
lastFilename = None
lastLineno = None

for line in file:
	filename, lineno = debug.lineForAddress(pc)
	if filename == None:
		src = ''
	elif filename == 'start.asm':
		src = '\t\tgoto\t_start'
	else:
		if filename not in sourceCodes:
			sourceCodes[filename] = open(filename).readlines()

		if filename == lastFilename and lineno > lastLineno + 1:
			# Lines without code.  Display them
			for x in range(lastLineno + 1, lineno):
				print '\t\t\t' + sourceCodes[filename][x - 1].strip('\n').replace('\t', '    ')

		src = sourceCodes[filename][lineno - 1].strip('\n').replace('\t', '    ')
		lastLineno = lineno
		lastFilename = filename

	print '%08x %08x\t%s' % (pc, endianSwap(int(line, 16)), src)	
	pc += 4
	
