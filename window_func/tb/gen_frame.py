import random
import re

def randComplex():
	im = random.randrange(0,1<<16)
	re = random.randrange(0,1<<16)
	return complex(re,im)


def genFile(size, packNum=1, busNum=2, file="axis_i.txt"):
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
					f.write("_{0:0{2}x}{1:0{2}x}".format(int(data.real),int(data.imag),4))
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
			f.write("{0:0{2}x}{1:0{2}x}\n".format(int(data.real),int(data.imag),4))

	return window

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
inp = genFile(packetSize,4)
print(inp)
win = genWindow(packetSize)
print(win)

result = []
for p in inp:
	rp = []
	for i in range(len(p)):
		rp.append(p[i]*win[i])
	result.append(rp)

print(result)