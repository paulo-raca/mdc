import os
with open("test/MO444_dogs_test.txt", "r") as f:
	lines = f.readlines()
 
idx = 1
curLabel = 'x'
for line in lines:
	imgPath, label = line.strip().split()
	
	if label != curLabel:
		idx = 1
		curLabel = label
		print imgPath, label, "./test/" + label.zfill(2) + "_" + str(idx).zfill(4) + imgPath[-4:]

	newPath = "./test/" + label.zfill(2) + "_" + str(idx).zfill(4) + imgPath[-4:]

	os.system("mv " + imgPath + " " + newPath)
	idx+=1 	
