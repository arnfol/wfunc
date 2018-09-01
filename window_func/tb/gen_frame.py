import random
import re

def randComplex():
	im = random.randrange(-1<<15,1<<15)
	re = random.randrange(-1<<15,1<<15)
	return complex(re,im)

def hexp(a,bits=16):
	return (int(a) & (2**bits - 1))

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
					f.write("_{0:04x}{1:04x}".format(hexp(data.real),hexp(data.imag)))
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
			f.write("{0:04x}{1:04x}\n".format(hexp(data.real),hexp(data.imag)))

	return window

def genReference(outDataList,busNum=2,file="axis_o_check.txt"):
	with open(file,"w+") as f:
		for l in outDataList:
			ltmp = l.copy()
			while len(ltmp) > busNum:
				f.write("0_")
				for b in range(busNum):
					transPart = ltmp.pop(0)
					f.write("{0:08x}{1:08x}".format(hexp(transPart.real,32),hexp(transPart.imag,32)))
				f.write("\n")
			else:
				f.write("1_")
				for b in range(busNum):
					transPart = ltmp.pop(0)
					f.write("{0:08x}{1:08x}".format(hexp(transPart.real,32),hexp(transPart.imag,32)))
				f.write("\n")


def readPacket(busNum=2, file="axis_i.txt"):
	packetList = []
	packet = []
	p = 0
	with open(file,"r") as f:
		for line in f:
			line = re.sub('_','',line)

			# get new values
			last = line[0]
			packet.extend([int(i,16) for i in re.findall("([0-9a-fA-F]{8})",line[1:])])

			# check TLAST
			if(int(last) == 1):
				packetList.append(packet.copy())
				packet.clear()
			elif(int(last) == 0):
				pass
			else:
				raise ValueError('Unexpected value %s in TLAST position, should be 1 or 0.' % last)
	return packetList


packetSize = 8
inp = genInput(packetSize,4)
print(inp)
win = genWindow(packetSize)
print(win)

result = []
for p in inp:
	rp = []
	for i in range(len(p)):
		rp.append(p[i]*win[i])
	result.append(rp)

genReference(result)
print(result)
