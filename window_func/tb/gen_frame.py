import random

packetSize = 10
packetNum = 3
busNum = 2
transNum = packetSize/busNum

with open('axis_i.txt','w') as f:
	for p in range(packetNum):
		for i in range(transNum):
			f.write("{0:b}".format(i==transNum-1))
			for j in range(busNum):
				data = random.randrange(0,1<<32)
				f.write("_{0:0{1}x}".format(data,8))
			f.write("\n")