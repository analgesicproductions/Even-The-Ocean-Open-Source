from os import listdir
from os.path import isfile, join
import sys
import random
import png
mypath = "D:/shield/assets/csv/"
onlyfiles = [sys.argv[1]+".bcsv"]


#
patch_w = 1
patch_h = 1
chunk_w = 40
chunk_h = 40
#patch_w = 20
#patch_h = 10
#chunk_w = 8
#chunk_h = 8
scaling = 1
margin = 0
patch_data = []

outname = "D:/output/"+sys.argv[1]+".png"
print outname


w = 0
h = 0
patchctr = -1
while True:
	print patchctr
	if patchctr == patch_w*patch_h-1:
		break
	r = random.randint(0,len(onlyfiles)-1)
	print onlyfiles[r]
	f = open(mypath+onlyfiles[r],"r")
	ls = f.readlines()
	
	f.close()
	dim = ls[0]
	w = int(dim.split(",")[0])
	h = int(dim.split(",")[1])
	
	
	chunk_h = h
	chunk_w = w
	
	
	for i in range(0,chunk_h*scaling*patch_h):
		patch_data.append(())
	#print w
	#print h
	
	m = 0
	csv = []
	for l in ls:
		l = l.strip()
		if m == 1:
			if "BG2" in l:
				break
			if len(l) < 3:
				break
			row = []
			vals = l.split(",")
			for val in vals:
				row.append(val)
			csv.append(row)
			
		else:
			if "BG" in l:
				m = 1
	if len(csv) < 2:
		continue
	# pick random x/y coords
	if chunk_w > w:
		continue
		chunk_w = int(w * 0.7)
	if chunk_h > h:
		continue
		chunk_h = int(h * 0.7)
	
		
	# inclusive e.g. w = 10, chunk = 5, will give start of 0,1,2,3,4
	x_start = 0
	y_start = 0
	
	data = []
	r1 = random.randint(0,200)
	r2 = random.randint(0,255)
	print (x_start,y_start,chunk_h,chunk_w,w,h)
	solid_ctr = 0
	for i in range(y_start,y_start+chunk_h):
		#row = ()
		row = []
		for j in range(x_start,x_start + chunk_w):
			if csv[i][j] == "20" or csv[i][j] == "60":
				row.append(1)
				#row += (255,r1,0,)
			else:
				row.append(0)
				solid_ctr += 1
				#row += (0,0,r2,)
				
		data.append(row)
	if solid_ctr < 16 or solid_ctr >= chunk_w*chunk_h-16:
		continue
	patchctr += 1	
	scaled_data = []
	# random values
	rs1 = []
	rs2 = []
	# create a 'random' array for fast access
	i1 = 0
	i2 = 0
	# loop every 20
	rslen = 1
	for i in range(0,rslen):
		rs1.append(random.randint(0,200))
		rs2.append(random.randint(0,200))
	
	# use int casting to 'scale' the image
	xc = 0
	yc = 0
	xcc = 0
	ycc = 0
	for i in range(0,scaling*chunk_h):	
		row = ()
		for j in range(0,scaling*chunk_w):	
			if i < margin*scaling:
				#row += (255,255,110)
				row += (0,0,0)
			elif j < margin*scaling:
				#row += (255,255,150)
				row += (0,0,0)
			elif i > scaling*chunk_h - margin*scaling:
				#row += (255,255,190)
				row += (0,0,0)
			elif j > scaling*chunk_w - margin*scaling:
				#row += (255,255,255)
				row += (0,0,0)
			elif data[yc][xc] == 0:
				#row += (255,r1,rs1[i1],)
				#row += (r1,r1,r1)
				#rrr = random.randint(0,40)
				#row += (rrr,rrr,rrr)
				row += (0,0,0)
			else:
				#row += (rs2[i2],255,r2,)
				#row += (255,0,100-int(100*(float(i)/(scaling*chunk_h))),)
				row += (255,255,255)
			i1 += 1
			i2 += 1
			if i1 >= rslen:
				i1 = 0
				i2 = 0
				
			xcc += 1
			if xcc >= scaling:
				xc += 1
				xcc = 0
		xc = 0
		scaled_data.append(row)
		ycc += 1
		if ycc >= scaling:
			yc += 1
			ycc = 0
	
	print patchctr
	px = patchctr % patch_w
	py = int(patchctr / patch_w)
	print (px,py)
	
	for i in range(0,len(scaled_data)):
		patch_data[i + chunk_h*scaling*py] += scaled_data[i]
		
			
	
	
	
#print "D:/output/"+onlyfiles[r]+str(x_start)+"_"+str(y_start)+"_"+str(chunk_w)+"_"+str(chunk_h)+".png"
#print (chunk_w*scaling*patch_h,chunk_h*scaling*patch_w)


#f = open("D:/output/"+onlyfiles[r]+str(x_start)+"_"+str(y_start)+"_"+str(chunk_w)+"_"+str(chunk_h)+".png", 'wb')
f = open(outname, 'wb')
writer = png.Writer(chunk_w*scaling*patch_w,chunk_h*scaling*patch_h)
# Glitch if patch dims unequal
#writer = png.Writer(chunk_w*scaling*patch_h,chunk_h*scaling*patch_w)
writer.write(f, patch_data)
f.close()
	

exit()
