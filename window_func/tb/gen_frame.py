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

# parameters
packetSize = 64
packetNum = 5
# randInput = False
# randOutput = False

# generate input transactions
inp = genInput(packetSize,packetNum)
win = genWindow(packetSize)

# generate reference result
f = open('check.log','w')
f.write('data * window = result\n')
result = []
for p in inp:
	rp = []
	for i in range(len(p)):
		rp.append(p[i]*win[i])
		f.write(str(p[i]) + ' * ' + str(win[i]) + ' = ' + str(p[i]*win[i]) + '\n')
	result.append(rp)

genReference(result)

# run vsim
vsim = 'cd ../../../sim/modelsim && \
/home/wazah/intelFPGA/18.0/modelsim_ase/bin/vsim -c \
-do ../../src/window_func/tb/run.tcl'

# vsim += ' -g IN_RAND=1' if randInput else ' -g IN_RAND=0'
# vsim += ' -g OUT_RAND=1' if randOutput else ' -g OUT_RAND=0'


vsim = vsim + ' > ../../src/window_func/tb/vsim.log'
print(vsim)
subprocess.Popen('cat > axis_o.txt',shell=True) # delete old result
subprocess.call(vsim,shell=True)

# check results
if filecmp.cmp('axis_o.txt','axis_o_check.txt'):
	print('Check passed!')
	f.write('Check passed!')
else:
	print('Files do not match!')
	f.write('Files do not match!')

f.close()
