import random
import re
import subprocess, os
import filecmp

def randComplex():
	im = random.randrange(-1<<15,1<<15)
	re = random.randrange(-1<<15,1<<15)
	return complex(re,im)

def hexp(a,bits=16):
	return (int(a) & (2**bits - 1))

def htoi(h):
	x = int(h,16)
	if x > 0x7FFFFFFF:
	    x -= 0x100000000

	return x

def genInput(size, packNum=1, busNum=2, file="axis_i.txt"):
	transNum = int(size/busNum)
	packetList = []
	with open(file,"w+") as f:
		for p in range(packNum):
			# generate packet
			packet = []
			for i in range(transNum):
				# generate tlast
				f.write("{0:b}".format(i==transNum-1))
				# generate data
				for b in range(busNum):
					data = randComplex()
					packet.append(data)
					f.write("_{0:04x}{1:04x}".format(hexp(data.imag),hexp(data.real)))
				f.write("\n")

			# add packet to list
			packetList.append(packet)

	return packetList

def genWindow(size, file="window.txt"):
	window = []
	with open(file,"w+") as f:
		for i in range(size):
			data = randComplex()
			window.append(data)
			f.write("{0:04x}{1:04x}\n".format(hexp(data.imag),hexp(data.real)))

	return window

def genReference(outDataList,busNum=2,file="axis_o_check.txt"):
	with open(file,"w+") as f:
		for l in outDataList:
			ltmp = l.copy()
			while len(ltmp) > busNum:
				f.write("0_")
				for b in range(busNum):
					transPart = ltmp.pop(0)
					f.write("{0:08x}{1:08x}".format(hexp(transPart.imag,32),hexp(transPart.real,32)))
				f.write("\n")
			else:
				f.write("1_")
				for b in range(busNum):
					transPart = ltmp.pop(0)
					f.write("{0:08x}{1:08x}".format(hexp(transPart.imag,32),hexp(transPart.real,32)))
				f.write("\n")

def readPacket(busNum=2, file="axis_o.txt"):
	packetList = []
	packet = []
	p = 0
	with open(file,"r") as f:
		for line in f:
			line = re.sub('_','',line)

			# get new values
			last = line[0]
			packet.extend([htoi(i) for i in re.findall("([0-9a-fA-F]{8})",line[1:])])

			# check TLAST
			if(int(last) == 1):
				packetList.append(packet.copy())
				packet.clear()
			elif(int(last) == 0):
				pass
			else:
				raise ValueError('Unexpected value %s in TLAST position, should be 1 or 0.' % last)
	return packetList

# --------------------------------------------------------------
# main
# --------------------------------------------------------------
def runTest(packetSize=64,packetNum=5,busNum=2,revertAddr=False,randInput=False,randOutput=False):
	# generate input transactions
	inp = genInput(packetSize,packetNum)
	win = genWindow(packetSize)

	# generate reference result
	math_log = open('check.log','w')
	math_log.write('data * window = result\n')
	result = []
	for p in inp:
		rp = []
		for i in range(len(p)):
			rp.append(p[i]*win[i])
			math_log.write(str(p[i]) + ' * ' + str(win[i]) + ' = ' + str(p[i]*win[i]) + '\n')
		result.append(rp)

	genReference(result)

	# run vsim
	vsim = 'cd ../../../sim/modelsim && \
	/home/wazah/intelFPGA/18.0/modelsim_ase/bin/vsim -c \
	-do "do ../../src/window_func/tb/run.tcl'

	vsim += ' {}'.format(packetSize)
	vsim += ' {}'.format(busNum)
	vsim += ' 1' if revertAddr else ' 0'
	vsim += ' 1' if randInput else ' 0'
	vsim += ' 1' if randOutput else ' 0'
	vsim += '"' 

	vsim = vsim + ' > ../../src/window_func/tb/vsim.log'
	# print(vsim)

	subprocess.Popen('cat > axis_o.txt',shell=True) # delete old result
	subprocess.call(vsim,shell=True)
	
	# print parameters from testbench
	with open('vsim.log','r') as log:
		for line in log:
			if 'CONFIG' in line:
				print(re.sub('^.*:\s+|\s+\n','',line),end=', ')


	# check results
	if filecmp.cmp('axis_o.txt','axis_o_check.txt'):
		print('Check passed!')
		math_log.write('Check passed!')
	else:
		print('Files do not match!')
		math_log.write('Files do not match!')

	math_log.close()


packetSizeCases = [128, 512, 2048, 4096, 8192]
busNumCases = [2]#[2, 4, 8]
revertAddrCases = [True,False]
randInputCases = [True,False]
randOutputCases = [True,False]


if __name__ == '__main__':
	# runTest()

	for bnum in busNumCases:
		for size in packetSizeCases:
			for i in randInputCases:
				for o in randOutputCases:
					runTest(packetSize=size,packetNum=10,busNum=bnum,revertAddr=False,randInput=i,randOutput=o)

# runTest(packetSize=2048,packetNum=30,busNum=2,revertAddr=False,randInput=True,randOutput=True)

