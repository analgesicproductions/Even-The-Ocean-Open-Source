import sys
import random

tmx_path = "../../../assets/sprites/bg/"+sys.argv[1]+".tmx"
tmeta_path = "../../../assets/tile_meta/"+sys.argv[2]+".tilemeta"
bcsv_path = "../../../assets/csv/"+sys.argv[3]+".bcsv"
skiprawinput = False
if len(sys.argv) > 4:
	skiprawinput = sys.argv[4] == "yes"

# E.g. - python autotmx.py basin/BASIN_G1 BASIN BASIN_G1

# Reads mappings from the tilemeta, reads the csv data, then modifies the TMX by mapping solid tiles to the tmx tileset (which is hardcoded)

#response = raw_input("Confirm:\n"+tmx_path+"\n"+tmeta_path+"\n"+bcsv_path+"\n\n(y) to continue\n>>> ")
response = "y"
if response == "y" or response == "Y":
	pass
else:
	exit()

def str_array_plus_1(s):
	a = s.split(",")
	b = ""
	for aa in a:
		b += str(int(aa)+1)
		b += ","
	
	return b[:-1]
	
	
	
print "If results look funny: double check that:\n"
print "1) The .bcsv exported is not in invis tiles."
print "2) The target .tmx file, "+sys.argv[1]+" has two layers, in the order Tile Layer 2, Tile Layer 1, Image Layer 1."
print "3) The source .tilemeta file, "+sys.argv[2]+" is the correct tilemeta file."
print "4) Looking for .bcsv "+sys.argv[3]

f = open(tmeta_path,"r")
m = 0
valid_anim_k = []
for l in f.readlines():
	if m == 0:
		if "ANIMS" in l:
			m = 1
	elif m == 1:
		if "END" in l:
			break
		else:
			if len(l) > 3 and l[0] not in ["#"," ","/"]:
				valid_anim_k.append(int(l.split(" ")[0]))
		
f.close()

# Get randomization metadata chances.
f = open("autotmx_data.txt","r")
mode = 0
r = {}
r4 = {}
r_anim_k = []
r_anim_v = []
bg2_lift = []
flag_floor_ceil_butt = False

for line in f.readlines():
	if "/" in line:
		continue
	if line.strip() == "":
		continue
	if mode == 0:
		if "START" == line.strip():
			mode = 1
	elif mode == 1:
		if sys.argv[3] in line.strip().split(","):
			print "found "+sys.argv[3]
			mode = 2
		else:
			mode = 3
	elif mode == 2:
		if "END" == line.strip():
			mode = 0
		else:
			a = line.strip().split(" ")
			if a[0] == "set":
				a[1] = str_array_plus_1(a[1])
				v = int(a[1].split(",")[0])
				r4[v] = {}
				r4[v]["p"] = {}
				r4[v]["orig"] = a[1]
				r4[v]["val"] = {}
				r4[v]["len"] = len(a)/2 - 1
				for i in range(0,(len(a)/2) - 1):
					r4[v]["p"][i] = int(a[3+i*2])
					if a[2+i*2] != "no_change":
						r4[v]["val"][i] = str_array_plus_1(a[2+i*2])
					else:
						r4[v]["val"][i] = a[2+i*2]
					#parse animations
			elif a[0] == "anim":
				aa = []
				for vs in a[2].split(","):
					if int(vs) not in valid_anim_k:
						print "Anim pair not present in tilemeta: "+vs	
					else:
						aa.append(vs)
				
				# k (in tiled) -> [v1,...] (in-game)
				if aa != []:
					r_anim_k.append(int(a[1])+1)
					r_anim_v.append(aa)
			elif a[0] == "bg2":
				bg2_lift = a[1].split(",")
				for aa in range(0,len(bg2_lift)):
					bg2_lift[aa] = int(bg2_lift[aa])+1
			elif a[0] == "floor_ceil_butt":
				flag_floor_ceil_butt = True
			else:
				# Random data
				rankey = int(a[0])+1
				r[rankey] = {}
				r[rankey][0] = int(a[1])
				r[rankey][1] = int(a[2])
				r[rankey][2] = int(a[3])
				r[rankey][3] = int(a[4])
				r[rankey][4] = int(a[1])+int(a[2])+int(a[3])+int(a[4])
	elif mode == 3:
		if "END" == line.strip():
			mode = 0
		
f.close()
	

# Get the tile data we need from the tilemeta which will be mapped to tmx-tileset data
f = open(tmeta_path,"r")
bcsv_solid = []
fl45 = []
fr45 = []
cl45 = [] 
cr45 = []
water = [] 
water_surface = []
permeable = []
noclimb = []
ice = []
top = []
ar = []
bgall = []
bgfl = []
bgfr = []
bgcl = []
bgcr = []
nat_bgall = []
nat_bgfl = []
nat_bgfr = []
nat_bgcl = []
nat_bgcr = []
bgbutt = []
althard = []
molebg = []
gaslight = []
gaslightlo = []
gaslighthi = []
gasdark = []
gasdarklo = []
gasdarkhi = []
gasedge = []

diff_normal = []
diff_cloud = []

hard_gasdark = []
hard_gaslight = []

solidToInvis = {}
invisToSolid = {}

for l in f.readlines():
	if l.split(" ")[0] == "solid":
		ar = bcsv_solid
	elif l.split(" ")[0] == "diff_cloud":
		ar = diff_cloud
	elif l.split(" ")[0] == "diff_normal":
		ar = diff_normal
	elif l.split(" ")[0] == "alt_hard":
		ar = althard
	elif l.split(" ")[0] == "fl45":
		ar = fl45
	elif l.split(" ")[0] == "nat_bgall":
		ar = nat_bgall
	elif l.split(" ")[0] == "nat_bgfr":
		ar = nat_bgfr
	elif l.split(" ")[0] == "nat_bgfl":
		ar = nat_bgfl
	elif l.split(" ")[0] == "nat_bgcr":
		ar = nat_bgcr
	elif l.split(" ")[0] == "nat_bgcl":
		ar = nat_bgcl
	elif l.split(" ")[0] == "bgall":
		ar = bgall
	elif l.split(" ")[0] == "bgfr":
		ar = bgfr
	elif l.split(" ")[0] == "bgfl":
		ar = bgfl
	elif l.split(" ")[0] == "bgcr":
		ar = bgcr
	elif l.split(" ")[0] == "bgcl":
		ar = bgcl
	elif l.split(" ")[0] == "floor_ice":
		ar = ice
	elif l.split(" ")[0] == "top":
		ar = top
	elif l.split(" ")[0] == "noclimb":
		ar = noclimb
	elif l.split(" ")[0] == "permeable":
		ar = permeable
	elif l.split(" ")[0] == "fr45":
		ar = fr45
	elif l.split(" ")[0] == "cl45":
		ar = cl45
	elif l.split(" ")[0] == "cr45":
		ar = cr45
	elif l.split(" ")[0] == "water":
		ar = water
	elif l.split(" ")[0] == "water_surface":
		ar = water_surface
	elif l.split(" ")[0] == "hard_gasdark":
		ar = hard_gasdark
	elif l.split(" ")[0] == "hard_gaslight":
		ar = hard_gaslight
	elif l.split(" ")[0] == "bgbutt":
		ar = bgbutt
	elif l.split(" ")[0] == "molebg":
		ar = molebg
	elif l.split(" ")[0] == "gasedge":
		ar = gasedge
	elif l.split(" ")[0] == "gaslightlo":
		ar = gaslightlo
	elif l.split(" ")[0] == "gaslight":
		ar = gaslight
	elif l.split(" ")[0] == "gaslighthi":
		ar = gaslighthi
	elif l.split(" ")[0] == "gasdark":
		ar = gasdark
	elif l.split(" ")[0] == "gasdarklo":
		ar = gasdarklo
	elif l.split(" ")[0] == "gasdarkhi":
		ar = gasdarkhi
	else:
		if l.split(" ")[0] == "solid_invis_map" or l.split(" ")[0] == "flip_map":
			parts = l.strip().split(" ")
			for part in parts:
				if "," not in part:
					continue
				solidToInvis[part.split(",")[0]] = part.split(",")[1]
				invisToSolid[part.split(",")[1]] = part.split(",")[0]
		continue
	l = l.strip()
	cs = l.split(" ")
	for i in range(1,len(cs)):
		if "." in cs[i]:
			for j in range(int(cs[i].split(".")[0]),1+int(cs[i].split(".")[1])):
				ar.append(j)
		else:
			ar.append(int(cs[i]))
bcsv_solid += noclimb
bcsv_solid += molebg
bcsv_solid += hard_gaslight
bcsv_solid += hard_gasdark
#print bcsv_solid
# remove permealbe from solids
permNoTop = filter(lambda i: i not in top, permeable)
bcsv_solid = filter(lambda i: i not in permNoTop, bcsv_solid)
#print bcsv_solid
#print permeable
bgall += bgbutt			
#print gasedge
f.close()

#print solidToInvis
#print invisToSolid
print "SOLID TILES: "+str(bcsv_solid)

# cut out the csv data from the tmx (which is csv, but aways ends with comma)
f = open(tmx_path,"r")
broken_tmx_bottom = ""
broken_tmx_mid = ""
broken_tmx_top = ""
mode = 0
for l in f.readlines():
	if mode == 0:
		broken_tmx_top = broken_tmx_top + l
		if "csv" in l:
			mode = 1
	elif mode == 1:
		if "data" in l:
			broken_tmx_mid += l
			mode = 2
	elif mode == 2:
		broken_tmx_mid += l
		if "data" in l:
			mode = 3
	elif mode == 3:
		if "data" in l:
			broken_tmx_bottom += l
			mode = 4;
	else:
		broken_tmx_bottom += l
		

#print broken_tmx_top
#print broken_tmx_bottom

f.close()

# Replace gas edges with nothing
invisCtr = 0
allCtr = 0 
f = open(bcsv_path,"r"); mode = 0; str_out = ""
for l in f.readlines():
	if mode == 0:
		if "BG" in l: mode = 1
	elif mode == 1:
		if "BG2" in l: 
			mode = 2
		else:
			l = l.strip()
			vals = l.split(",")
			for i in range(0,len(vals)):
				if vals[i] != "0":
					allCtr += 1
				if int(vals[i]) in gasedge:
					vals[i] = "0"
				# Before autotiler runs flip all invis to debug
				elif vals[i] in invisToSolid:
					vals[i] = invisToSolid[vals[i]]
					invisCtr += 1
			l = ','.join(map(str,vals)) + "\n"
	elif mode == 2:
		if "FG" in l: 
			mode = 3
		else:
			l = l.strip()
			vals = l.split(",")
			for i in range(0,len(vals)):
				if int(vals[i]) in gasedge:
					vals[i] = "0"
			l = ','.join(map(str,vals)) + "\n"
	str_out += l
f.close(); f = open(bcsv_path,"w"); f.write(str_out); f.close()

# Replace turn csvs into manipulable arrays
# 2-dim arrays - where gcsv[i][j] is row_i,col_j
f = open(bcsv_path,"r"); mode = 0
gcsv = []
gcsv2 = []
for l in f.readlines():
	if mode == 0:
		if "BG" in l: mode = 1
	elif mode == 1:
		if "BG2" in l: mode = 2
		else:
			l = l.strip()
			gcsv.append(l.split(","))
	elif mode == 2: 
		if "FG" in l: mode = 3
		else:
			l = l.strip()
			if l == "0":
				print "stick something in bg2 lol"
				raw_input()
				exit
			gcsv2.append(l.split(","))
	elif mode == 3: pass
f.close()

# ADDING GAS...
# now we have the csvs as an array. so we can look thru them like needed.
# 2 passes, one for "fill" gas tiles, then the one for edges.
all_animfillgas = ["480","481","482","483","980","981","982","983","1480","1481","1482","1483","1980","1981","1982","1983"]
for m in range (0,2):
	for y in range(0,len(gcsv)):
		for x in range(0,len(gcsv[0])):
		
			val = int(gcsv[y][x])
			val2 = int(gcsv2[y][x])
			# Create an array so a tile in the .bcsv can be checked if it is a gas tile.
			allgas = gaslight+gaslightlo+gasdark+gasdarklo
			if val in allgas or val2 in allgas:
				# 480 - 483
				animfillgas = ["480","481","482","483"]
				gas_off = 0
				# Initialize the correct .tmx tile values, based on the .bcsv tile.
				if val in gaslightlo or val2 in gaslightlo:
					for i in range(0,4): animfillgas[i] = str(int(animfillgas[i])+500)
					gas_off = 500
				elif val in gasdark or val2 in gasdark:
					for i in range(0,4): animfillgas[i] = str(int(animfillgas[i])+1000)
					gas_off = 1000
				elif val in gasdarklo or val2 in gasdarklo:
					for i in range(0,4): animfillgas[i] = str(int(animfillgas[i])+1500)
					gas_off = 1500
					
				# Pass 1: Place all the fill tiles	
				if m == 0:
					if val in allgas:
						if x%2 == 0 and y %2 == 0: gcsv[y][x] = animfillgas[0]
						if x%2 == 1 and y %2 == 0: gcsv[y][x] = animfillgas[1]
						if x%2 == 0 and y %2 == 1: gcsv[y][x] = animfillgas[2]
						if x%2 == 1 and y %2 == 1: gcsv[y][x] = animfillgas[3]
					if  val2 in allgas:
						if x%2 == 0 and y %2 == 0: gcsv2[y][x] = animfillgas[0]
						if x%2 == 1 and y %2 == 0: gcsv2[y][x] = animfillgas[1]
						if x%2 == 0 and y %2 == 1: gcsv2[y][x] = animfillgas[2]
						if x%2 == 1 and y %2 == 1: gcsv2[y][x] = animfillgas[3]
				# Pass 2: Place the edges, up to two overlapping.
				if m == 1:
					if gcsv[y-1][x] == "0" and gcsv2[y-1][x] not in all_animfillgas:
						gcsv[y-1][x] = str(484 + gas_off + x%2)
					elif gcsv[y-1][x] not in all_animfillgas and int(gcsv[y-1][x]) not in bcsv_solid and gcsv2[y-1][x] == "0":
						gcsv2[y-1][x] = str(484 + gas_off +  x%2)
					if gcsv[y+1][x] == "0" and gcsv2[y+1][x] not in all_animfillgas:
						gcsv[y+1][x] = str(488 + gas_off + x%2)
					elif gcsv[y+1][x] not in all_animfillgas and int(gcsv[y+1][x]) not in bcsv_solid and gcsv2[y+1][x] == "0":
						gcsv2[y+1][x] = str(488 + gas_off + x%2)
					if gcsv[y][x+1] == "0" and gcsv2[y][x+1] not in all_animfillgas:
						gcsv[y][x+1] = str(490 + gas_off + y%2)
					elif gcsv[y][x+1] not in all_animfillgas and int(gcsv[y][x+1]) not in bcsv_solid and gcsv2[y][x+1] == "0":
						gcsv2[y][x+1] = str(490 + gas_off + y%2)
					if gcsv[y][x-1] == "0" and gcsv2[y][x-1] not in all_animfillgas:
						gcsv[y][x-1] = str(486 + gas_off + y%2)
					elif gcsv[y][x-1] not in all_animfillgas and int(gcsv[y][x-1]) not in bcsv_solid and gcsv2[y][x-1] == "0":
						gcsv2[y][x-1] = str(486 + gas_off + y%2)

# Reconstruct the .bcsv file and overwrite it.
f = open(bcsv_path,"r"); mode = 0; str_out = ""; y = 0
for l in f.readlines():
	if mode == 0:
		if "BG" in l: mode = 1
	elif mode == 1:
		if "BG2" in l: mode = 2; y = 0
		else:
			l = l.strip()
			vals = l.split(",")
			for i in range(0,len(vals)):
				vals[i] = gcsv[y][i]
			l = ','.join(map(str,vals)) + "\n"
			y += 1
	elif mode == 2:
		if "FG" in l: mode = 3
		else:
			l = l.strip()
			vals = l.split(",")
			for i in range(0,len(vals)):
				vals[i] = gcsv2[y][i]
			l = ','.join(map(str,vals)) + "\n"
			y += 1
			
	elif mode == 3: pass
	str_out += l
f.close(); 
f = open(bcsv_path,"w"); f.write(str_out); f.close()

# Read the .bcsv file into a 2-dim array. 
print "tilemeta anim tiles: "+str(r_anim_v)
f = open(bcsv_path,"r")
mode = 0
tmx_csv = ""
# orig_csv = untouched BCSV data
orig_csv = [] 
orig_csv2 = [] 
csv = []
fgcsv = []
csv2 = []
csv_idx = 0
prevval = 0

# Also, undo animated tiles placed by previous passes
for l in f.readlines():
	if mode == 0:
		if "BG" in l:
			mode = 1
	elif mode == 1:
		if "BG2" in l:
			mode = 2
			csv_idx = 0
		else:
			csv.append([])
			vals = l.split(",")
			for val in vals:
				# replace existing animated tiles with blank solid (so they can be re-randomized)
				appended = False
				for ranim in r_anim_v:
					if val in ranim:
					#60 is the invis tile here.
						if int(val) in bcsv_solid:
							if prevval == 60:
								csv[csv_idx].append(60)
							else:
								csv[csv_idx].append(20)
							#print len(csv)
						elif int(val) in water_surface:
							if prevval == 60 or prevval in [1281,1285]:
								csv[csv_idx].append(71)
							else:
								csv[csv_idx].append(31)
						elif int(val) in water:
							if prevval == 60 or prevval in [1301,1305,1309,1313]:
								csv[csv_idx].append(72)
							else:
								csv[csv_idx].append(32)
						else:
							csv[csv_idx].append(1)
						appended = True
						break
				if appended == False:
					csv[csv_idx].append(int(val))
				prevval = int(val)
			csv_idx += 1
	elif mode == 2:
		if "FG" in l:
			csv_idx = 0
			mode = 3
		else:
			#no data for BG2 so just put in all zeros
			if len(l) < 5:
				mode = 3
				csv_idx = 0
				for i in range(0,len(csv)):
					csv2.append([])
					for j in range(0,len(csv[0])):
						csv2[i].append(0)
			else:
				csv2.append([])
				vals = l.split(",")
				for val in vals:
					csv2[csv_idx].append(int(val))
				csv_idx += 1
	elif mode == 3:
		if "FG2" in l:
			mode = 4
		else:
			#no data for FG1 so just put in all zeros
			if len(l) < 5:
				mode = 3
				for i in range(0,len(csv)):
					fgcsv.append([])
					for j in range(0,len(csv[0])):
						fgcsv[i].append(0)
			else:
				fgcsv.append([])
				vals = l.split(",")
				for val in vals:
					fgcsv[csv_idx].append(int(val))
				csv_idx += 1
			

f.close()

# Alt-hard are the 'exterior' tiles in River and Radio that should look different later.
# Also here, cloud tile are lifted from BG to BG2 and a bgtile is ptut underneath
althard_c = []
tx = 0
ty = 0
for row in csv:
	tx = 0
	for val in row:
		if val in althard:
			althard_c.append([tx,ty])
		if val in top:
			if csv[ty+1][tx] in bgall and csv[ty-1][tx] in bgall:
				csv2[ty][tx] = val
				csv[ty][tx] = bgall[0]
			if csv[ty+1][tx] in nat_bgall and csv[ty-1][tx] in nat_bgall:
				csv2[ty][tx] = val
				csv[ty][tx] = nat_bgall[0]
		tx += 1
	ty += 1

orig_csv = list(csv)	
orig_csv2 = list(csv2)	

# Maximum x and y vals of the map
mx = len(csv[0])-1
my = len(csv)-1
in_bgall = False
in_bgnat = False

# START FUNCTION #
# a = array of what dirs need to be _SOLID_ - 0 to 7, [U]p to [U]p-[L]-eft, clockwise
# x,y = coord of tile thats checked
#mach = is machine bg, nat = is nature
# mach will be true when this is a mach bg, so mach and collide count as solid. nat is anything is solid (nat bg, mach, or collide)
# othercsv is if you want to check a differnet array other than csv for the solidness
def is_solid(a,x,y,mach=False,nat=False,othercsv=0):
	_mach = []
	if mach or nat:
		_mach = bgall + fr45 + fl45 + cl45 + cr45 + water_surface
		
	_nat = []
	if nat:
		#Add the BG slopes bc these should be treated as solid for nature BG (whch will appear under the bg slopes_)
		_nat = nat_bgall + bgcl + bgcr + bgfl + bgfr
		
	tiles = bcsv_solid + _mach + _nat
	
	if othercsv == 0:
		othercsv = csv
	
	for d in a:
		if d == 0 and y > 0 and othercsv[y-1][x] not in tiles:
			return False
		if d == 2 and x < mx and othercsv[y][x+1] not in tiles:
			return False
		if d == 4 and y < my and othercsv[y+1][x] not in tiles:
			return False
		if d == 6 and x > 0 and othercsv[y][x-1] not in tiles:
			return False
			# else it's at border, so treat as solid, or True
		if d == 1 and y > 0 and x < mx and othercsv[y-1][x+1] not in tiles:
			return False
		if d == 3 and y < my and x < mx and othercsv[y+1][x+1] not in tiles:
			return False
		if d == 5 and y < my and x > 0 and othercsv[y+1][x-1] not in tiles:
			return False
		if d == 7 and y > 0 and x > 0 and othercsv[y-1][x-1] not in tiles:
			return False
	return True
# END FUNCTION #


# This function takes in an x and y coordinate, and returns the corresponding generic solid tile (out of a 2x2 pattern)
#bg = if this is a BG wall tile, nat if it's a nature one and not machinery
def get_solid(x,y,bg=False,nat=False):
	if x % 2 == 0 and y % 2 == 0:
		if nat:
			# Todo
			return "961,"
		elif bg:
			return "721,"
		else:
			return "361,"
	elif x % 2 == 1 and y % 2 == 0:
		if nat:
			return "965,"
		elif bg:
			return "725,"
		else:
			return "365,"
	elif x % 2 == 0 and y % 2 == 1:
		if nat:
			return "969,"
		elif bg:
			return "729,"
		else:
			return "369,"
	elif x % 2 == 1 and y % 2 == 1:
		if nat:
			return "973,"
		elif bg:
			return "733,"
		else:
			return "373,"
	if nat:
		return "961,"
	elif bg:
		return "721,"
	else:
		return "361,"
	
# is there a tile of type TILES at either layer in pos x or y
def csv_has(y,x,tiles,tiles2):
	tiles3 = []
	# lol global
	if tiles2 == bgall:
		tiles3 = nat_bgall
	if tiles2 == bgfl:
		tiles3 = nat_bgfl
	if tiles2 == bgfr:
		tiles3 = nat_bgfr
	if tiles2 == bgcr:
		tiles3 = nat_bgcr
	if tiles2 == bgcl:
		tiles3 = nat_bgcl
	
	if in_bgnat:
		return csv[y][x] in tiles+tiles2+tiles3 or csv2[y][x] in tiles+tiles2+tiles3
	elif in_bgall:
		return csv[y][x] in tiles+tiles2 or csv2[y][x] in tiles+tiles2
	else:
		return csv[y][x] in tiles or csv2[y][x] in tiles
		
# 4 - permeable
# 5 - noclimb
# 6 - cloud
# 7 - ice

tmx_csv = ""
tmx_csv2 = ""
tx = 0
ty = 0

def get_top(tx,ty,a):
	if tx-1 >= 0 and a[ty][tx-1] not in top and (csv2[ty][tx-1] in bcsv_solid or csv[ty][tx-1] in bcsv_solid):
		return "481"
	elif tx+1 < mx and a[ty][tx+1] not in top and (csv2[ty][tx+1] in bcsv_solid or csv[ty][tx+1] in bcsv_solid):
		return "489"
	# Detect gas edgs here too (they were addd into the csv array after being-readded at start of autotiler)
	# these are lifted clouds over bg tilest hat were spaced/autofilled in
	# End cloud tiles will draw if the adjacent tile is not solid on bg1 or bg2, or if it is a top tile. 
	elif tx+1 < mx and ((not is_solid([2],tx,ty,False,False,csv2) and not is_solid([2],tx,ty) and a[ty][tx+1] not in top) or csv2[ty][tx+1] in diff_normal+diff_cloud):
		return "493"
	elif tx-1 >= 0 and ((not is_solid([6],tx,ty,False,False,csv2) and not is_solid([6],tx,ty) and a[ty][tx-1] not in top) or csv2[ty][tx-1] in diff_normal+diff_cloud):
		return "497"
	return "485"
	
# pull down fg clouds to bg2, visually. will not overwrite anything most of the time
for row in fgcsv:
	for val in row:
		if fgcsv[ty][tx] in [292,293]:
			csv2[ty][tx] = fgcsv[ty][tx]
		tx += 1
	tx = 0
	ty += 1

tx = 0
ty = 0
# using the mappings below, map each number into a tmx tileset number, constructing a new csv.
# FIRST, do this for the BG2 data
# BG2 only has: slopes, permeable, cloud/top
for row in csv2:
	for val in row:
		if val in top:
			tmx_csv2 += get_top(tx,ty,csv2)+","
		elif val in permeable:
			tmx_csv2 += "441,"
		elif val in fl45:
			tmx_csv2 += "189,"
		elif val in fr45:
			tmx_csv2 += "185,"
		elif val in cl45:
			tmx_csv2 += "169,"
		elif val in cr45:
			tmx_csv2 += "165,"
		else:
			tmx_csv2 += "0,"
		tx += 1
	tx = 0
	ty += 1
	tmx_csv2 += "\n"
			
tmx_csv2 = tmx_csv2[:-2]+"\n"

tx = 0
ty = 0

hard_d_pos = []
hard_l_pos = []

# Now, do it for BG1. At the start of each iteration, check if it's in hard_gas, bc that's important for later when those tiles are visually repassed over
for row in csv:
	for val in row:
		# 63 62 43 42
		if val in hard_gaslight:
			hard_l_pos.append([tx,ty])
		elif val in hard_gasdark:
			hard_d_pos.append([tx,ty])
	
		# Now do special, non-slope and non-solid tiles.
		if val in top:
			if tx-1 >= 0 and (is_solid([6],tx,ty) or (csv[ty][tx-1] in permeable and csv[ty][tx-1] not in top)):
				tmx_csv += "481,"
			elif tx+1 < mx and (is_solid([2],tx,ty) or (csv[ty][tx+1] in permeable and csv[ty][tx+1] not in top)):
				tmx_csv += "489,"
			elif tx+1 < mx and (0 == csv[ty][tx+1] or csv[ty][tx+1] in gasedge or csv[ty][tx+1] in diff_normal+diff_cloud):
				tmx_csv += "493,"
			elif tx-1 >= 0 and (0 == csv[ty][tx-1] or csv[ty][tx-1] in gasedge or csv[ty][tx-1] in diff_normal+diff_cloud):
				tmx_csv += "497,"
			else:
				tmx_csv += "485,"
		elif val in water:
			if tx % 2 == 0 and ty % 2 == 0: tmx_csv += "1301,"
			if tx % 2 == 1 and ty % 2 == 0: tmx_csv += "1305,"
			if tx % 2 == 0 and ty % 2 == 1: tmx_csv += "1309,"
			if tx % 2 == 1 and ty % 2 == 1: tmx_csv += "1313,"
		elif val in water_surface:
			if tx % 2 == 0: tmx_csv += "1281,"
			else: tmx_csv += "1285,"
		elif val in molebg:
			tmx_csv += "1281,"
		elif val in ice:
			#1361 65 69 73 77 mid lground rground lair rair
			if tx-1 >= 0 and tx+1 <= mx:
				ice_l = csv[ty][tx-1]
				ice_r = csv[ty][tx+1]
				if ice_l in ice and ice_r in ice:
					tmx_csv += "1361,"
				elif ice_l in bcsv_solid and ice_r in ice:
					tmx_csv += "1365,"
				elif ice_r in bcsv_solid and ice_l in ice:
					tmx_csv += "1369,"
				elif ice_r in ice:
					tmx_csv += "1373,"
				else:
					tmx_csv += "1377,"
			else:
				tmx_csv += "1361,"
		elif val in permeable:
			if csv[ty][tx-1] in permeable and csv[ty][tx+1] in permeable:
				tmx_csv += "449,"
			elif csv[ty][tx-1] in permeable and csv[ty-1][tx] not in permeable:
				tmx_csv += "453,"
			elif csv[ty][tx+1] in permeable and csv[ty-1][tx] not in permeable:
				tmx_csv += "445,"
			elif csv[ty-1][tx] in permeable and csv[ty+1][tx] in permeable:
				tmx_csv += "469,"
			elif csv[ty-1][tx] in permeable:
				tmx_csv += "473,"
			elif csv[ty+1][tx] in permeable:
				tmx_csv += "465,"
			else:
				tmx_csv += "441,"
		elif val in noclimb:
			if is_solid([2],tx,ty) or (tx+1 < mx and csv[ty][tx+1]) in fr45:
				if is_solid([0],tx,ty) == False:
					tmx_csv += "501,"
				elif is_solid([4],tx,ty) == False and csv[ty+1][tx] not in cl45:
					tmx_csv += "509,"
				else:
					tmx_csv += "521,"
				
			# R-facing slime
			else:
				if is_solid([0],tx,ty) == False:
					tmx_csv += "505,"
				elif is_solid([4],tx,ty) == False and csv[ty+1][tx] not in cr45:
					tmx_csv += "513,"
				else:
					tmx_csv += "541,"
					
		# Slopes
		elif val in fl45 or val in bgfl or val in nat_bgfl:
			if val in nat_bgfl:
				tmx_csv += "829,"
			elif val in bgfl:
				tmx_csv += "589,"
			else:
				tmx_csv += "189,"
		elif val in fr45 or val in bgfr or val in nat_bgfr:
			if val in nat_bgfr:
				tmx_csv += "825,"
			elif val in bgfr:
				tmx_csv += "585,"
			else:
				tmx_csv += "185,"
		elif val in cl45 or val in bgcl or val in nat_bgcl:
			if val in nat_bgcl:
				tmx_csv += "809,"
			elif val in bgcl:
				tmx_csv += "569,"
			else:
				tmx_csv += "169,"
		elif val in cr45 or val in bgcr or val in nat_bgcr:
			if val in nat_bgcr:
				tmx_csv += "805,"
			elif val in bgcr:
				tmx_csv += "565,"
			else:
				tmx_csv += "165,"
		
		# The below looks complicated, but it's just doing the solid tile stylings.
		elif val in bcsv_solid or val in bgall or val in nat_bgall:
			in_bgall = val in bgall
			#in bg nature
			in_bgnat = val in nat_bgall
			
			# 101 - solid-all 
			if is_solid([0,1,2,3,4,5,6,7],tx,ty,in_bgall,in_bgnat):
				# fetch corretct tiletyoe
				tmx_csv += get_solid(tx,ty,in_bgall,in_bgnat)
				
			# 105 - solid-!3 106 - solid-!5
			# 125 - solid-!1 126 - solid-!7 (corner of d/r walls)
			elif is_solid([0,1,2,4,5,6,7],tx,ty,in_bgall,in_bgnat):
				if csv_has(ty+1,tx+1,cr45,bgcr):
					tmx_csv += get_solid(tx,ty,in_bgall,in_bgnat)
				else:
					if in_bgnat: tmx_csv += "861,"
					elif in_bgall: tmx_csv += "621,"
					else: tmx_csv += "261,"
			elif is_solid([0,1,2,3,4,6,7],tx,ty,in_bgall,in_bgnat):
				if csv_has(ty+1,tx-1,cl45,bgcl):
					tmx_csv += get_solid(tx,ty,in_bgall,in_bgnat)
				else:
					if in_bgnat: tmx_csv += "865,"
					elif in_bgall: tmx_csv += "625,"
					else: tmx_csv += "265,"
			elif is_solid([0,2,3,4,5,6,7],tx,ty,in_bgall,in_bgnat):
				if csv_has(ty-1,tx+1,fr45,bgfr):
					tmx_csv += get_solid(tx,ty,in_bgall,in_bgnat)
				else:
					if in_bgnat: tmx_csv += "869,"
					elif in_bgall: tmx_csv += "629,"
					else: tmx_csv += "269,"
			elif is_solid([0,1,2,3,4,5,6],tx,ty,in_bgall,in_bgnat):
				if csv_has(ty-1,tx-1,fl45,bgfl):
					tmx_csv += get_solid(tx,ty,in_bgall,in_bgnat)
				else: 
					if in_bgnat: tmx_csv += "873,"
					elif in_bgall: tmx_csv += "633,"
					else: tmx_csv += "273,"
			# 100 - solid-01234 102 - solid-45670 81 solid-23456 (top flat) 121 - solid-67012 
			elif is_solid([2,4,5,6,7,0],tx,ty,in_bgall,in_bgnat):
				if in_bgall:
					tmx_csv += "701,"
				else:
					tmx_csv += "341,"
				#Maybe need case for up and down as well later
			elif is_solid([0,1,2,3,4,6],tx,ty,in_bgall,in_bgnat):
				if in_bgall:
					tmx_csv += "661,"
				else:
					tmx_csv += "301,"
			elif not in_bgall and not in_bgnat and is_solid([2,3,4,5,6,0],tx,ty,in_bgall,in_bgnat):
				tmx_csv += "281,"
			elif not in_bgall and not in_bgnat and is_solid([6,7,0,1,2,4],tx,ty,in_bgall,in_bgnat):
				tmx_csv += get_solid(tx,ty,in_bgall,in_bgnat)
			elif is_solid([2,3,4,5,6],tx,ty,in_bgall,in_bgnat):
				if csv_has(ty-1,tx,fr45,bgfr):
					if in_bgnat: tmx_csv += "821,"
					elif in_bgall: tmx_csv += "581,"
					else: tmx_csv += "181,"
				elif csv_has(ty-1,tx,fl45,bgfl):
					if in_bgnat: tmx_csv += "833,"
					elif in_bgall: tmx_csv += "593,"
					else: tmx_csv += "193,"
				else:
					if is_solid([0],tx,ty,in_bgall,in_bgnat):
						tmx_csv += get_solid(tx,ty,in_bgall,in_bgnat)
					else:
						if in_bgnat: tmx_csv += "881,"
						elif in_bgall: tmx_csv += "641,"
						else: tmx_csv += "281,"
			elif is_solid([0,1,2,3,4],tx,ty,in_bgall,in_bgnat):
				if csv_has(ty,tx-1,cl45,bgcl):
					if in_bgnat: tmx_csv += "813,"
					elif in_bgall: tmx_csv += "573,"
					else: tmx_csv += "173,"
				elif csv_has(ty,tx-1,fl45,bgfl):
					if in_bgnat: tmx_csv += "833,"
					elif in_bgall: tmx_csv += "593,"
					else: tmx_csv += "193,"
				else:
					# OK will be replaced below
					if is_solid([6],tx,ty,in_bgall,in_bgnat):
						tmx_csv += get_solid(tx,ty,in_bgall,in_bgnat)
					else:
						if in_bgnat: tmx_csv += "901,"
						elif in_bgall: tmx_csv += "661,"
						else: tmx_csv += "101,"
			elif is_solid([4,5,6,7,0],tx,ty,in_bgall,in_bgnat):
				if csv_has(ty,tx+1,cr45,bgcr):
					if in_bgnat: tmx_csv += "801,"
					elif in_bgall: tmx_csv += "561,"
					else: tmx_csv += "161,"
				elif csv_has(ty,tx+1,fr45,bgfr):
					if in_bgnat: tmx_csv += "821,"
					elif in_bgall: tmx_csv += "581,"
					else: tmx_csv += "181,"
				else:
					if is_solid([2],tx,ty,in_bgall,in_bgnat):
						tmx_csv += get_solid(tx,ty,in_bgall,in_bgnat)
					else:
						# OK will be replaced below
						if in_bgnat: tmx_csv += "941,"
						elif in_bgall: tmx_csv += "701,"
						else: tmx_csv += "103,"
			elif is_solid([6,7,0,1,2],tx,ty,in_bgall,in_bgnat):
			
				if ty+1 < my and csv_has(ty+1,tx,cr45,bgcr):
					if in_bgnat: tmx_csv += "801,"
					elif in_bgall: tmx_csv += "561,"
					else: tmx_csv += "161,"
				elif csv_has(ty+1,tx,cl45,bgcl):
					if in_bgnat: tmx_csv += "813,"
					elif in_bgall: tmx_csv += "573,"
					else: tmx_csv += "173,"
				else:
					if in_bgnat: tmx_csv += "921,"
					elif in_bgall: tmx_csv += "681,"
					else: 
						if is_solid([4],tx,ty,in_bgall,in_bgnat):
							tmx_csv += get_solid(tx,ty,in_bgall,in_bgnat)
						else:
							tmx_csv += "321,"
			# Cross pattern
			elif in_bgall and is_solid([0,2,4,6],tx,ty,in_bgall,in_bgnat):
				if in_bgall: 
					if is_solid([1],tx,ty,in_bgall,in_bgnat) or is_solid([7],tx,ty,in_bgall,in_bgnat):
						tmx_csv += get_solid(tx,ty,in_bgall,in_bgnat)
					else:
						tmx_csv += "753,"
				else: tmx_csv += "753,"
			# 80 - solid-234 (UL corner) 82 solid-456  (UR corner)
			elif is_solid([2,3,4],tx,ty,in_bgall,in_bgnat):
				if csv_has(ty,tx-1,fl45,bgfl) and csv_has(ty-1,tx,fl45,bgfl):
					if in_bgnat: tmx_csv += "833,"
					elif in_bgall: tmx_csv += "593,"
					else: tmx_csv += "193,"
				elif csv_has(ty,tx-1,fl45,bgfl):
					if in_bgnat: tmx_csv += "881,"
					elif in_bgall: tmx_csv += "641,"
					else: tmx_csv += "281,"
				elif csv_has(ty-1,tx,fl45,bgfl):
					# OK will be replaced below
					if in_bgnat: tmx_csv += "901,"
					elif in_bgall: tmx_csv += "661,"
					else: tmx_csv += "101,"
				else: 
					if in_bgnat: tmx_csv += "841,"
					elif in_bgall: tmx_csv += "601,"
					else: 
						if is_solid([0],tx,ty,in_bgall,in_bgnat):
							if is_solid([6,7],tx,ty,in_bgall,in_bgnat):
								tmx_csv += get_solid(tx,ty,in_bgall,in_bgnat)
							else:
								tmx_csv += "301,"
						elif is_solid([6],tx,ty,in_bgall,in_bgnat):
							tmx_csv += "281,"
						else:
							tmx_csv += "241,"
			elif is_solid([4,5,6],tx,ty,in_bgall,in_bgnat):
				if csv_has(ty-1,tx,fr45,bgfr) and csv_has(ty,tx+1,fr45,bgfr):
					if in_bgnat: tmx_csv += "821,"
					elif in_bgall: tmx_csv += "581,"
					else: tmx_csv += "181,"
				elif csv_has(ty,tx+1,fr45,bgfr):
					if in_bgnat: tmx_csv += "881,"
					elif in_bgall: tmx_csv += "641,"
					else: tmx_csv += "281,"
				elif csv_has(ty-1,tx,fr45,bgfr):
					# OK will be replaced below
					if in_bgnat: tmx_csv += "941,"
					elif in_bgall: tmx_csv += "701,"
					else: tmx_csv += "103,"
				else:
					if in_bgnat: tmx_csv += "845,"
					elif in_bgall: tmx_csv += "605,"
					else: 
						if is_solid([0],tx,ty,in_bgall,in_bgnat):
							tmx_csv += "349,"
						elif is_solid([2],tx,ty,in_bgall,in_bgnat):
							tmx_csv += "281,"
						else:
							tmx_csv += "245,"
			# 120 - solid-012 321 - solid 670 (bottom right corner exterior)
			elif is_solid([0,1,2],tx,ty,in_bgall,in_bgnat):
				if csv_has(ty+1,tx,cl45,bgcl):
					if csv_has(ty,tx-1,cl45,bgcl):
						if in_bgnat: tmx_csv += "813,"
						elif in_bgall: tmx_csv += "573,"
						else: tmx_csv += "173,"
					elif False == csv_has(ty,tx-1,bcsv_solid,bgall):
						# OK will be replaced below
						if in_bgnat: tmx_csv += "901,"
						elif in_bgall: tmx_csv += "661,"
						else: tmx_csv += "101,"
					else:
						if in_bgnat: tmx_csv += "813,"
						elif in_bgall: tmx_csv += "573,"
						else: tmx_csv += "173,"
				elif csv_has(ty,tx-1,cl45,bgcl):
					if in_bgnat: tmx_csv += "921,"
					elif in_bgall: tmx_csv += "681,"
					else: tmx_csv += "321,"
				else:
					if in_bgnat: tmx_csv += "849,"
					elif in_bgall: tmx_csv += "609,"
					else: tmx_csv += "249,"
			elif is_solid([6,7,0],tx,ty,in_bgall,in_bgnat):
				if csv_has(ty,tx+1,cr45,bgcr) and csv_has(ty+1,tx,cr45,bgcr):
					if in_bgnat: tmx_csv += "801,"
					elif in_bgall: tmx_csv += "561,"
					else: tmx_csv += "161,"
				elif csv_has(ty,tx+1,cr45,bgcr):
					if in_bgnat: tmx_csv += "861,"
					elif in_bgall: tmx_csv += "621,"
					else: tmx_csv += "321,"
				elif csv_has(ty+1,tx,cr45,bgcr):
					# OK will be replaced below
					if in_bgnat: tmx_csv += "941,"
					elif in_bgall: tmx_csv += "701,"
					else: tmx_csv += "103,"
				else:
					if in_bgnat: tmx_csv += "853,"
					elif in_bgall: tmx_csv += "613,"
					else: tmx_csv += "253,"
			# 89 - solid-4 109 - solid-04 129 - solid-0
			# 112 - solid-2 113 - solid-26 114 - solid-6
			# 385 389 381 / 110 90 130 - single thick vertical
			elif is_solid([0,4],tx,ty,in_bgall,in_bgnat):
				if in_bgnat: tmx_csv += "985,"
				elif in_bgall: 
					if csv_has (ty,tx-1,cl45,bgcl) or csv_has (ty,tx+1,cr45,bgcr):
						tmx_csv += get_solid(tx,ty,in_bgall,in_bgnat)
					else:
						tmx_csv += "745,"
				else: tmx_csv += "385,"
			elif is_solid([2,6],tx,ty,in_bgall,in_bgnat):
			# 401 405 409
				if in_bgnat: tmx_csv += "1005,"
				elif in_bgall: 
					if csv[ty+1][tx] in water_surface:
						tmx_csv += "641,"
					else:
						tmx_csv += "765,"
				else: tmx_csv += "405,"
			elif is_solid([6],tx,ty,in_bgall,in_bgnat):
			
				if csv_has(ty-1,tx,fr45,bgfr):
					if in_bgnat: tmx_csv += "941,"
					elif in_bgall: tmx_csv += "701,"
					else: tmx_csv += "341,"				
				else:
					if in_bgnat: tmx_csv += "1009,"
					elif in_bgall: 
						if is_solid([0],tx,ty,in_bgall,in_bgnat):
							tmx_csv += get_solid(tx,ty,in_bgall,in_bgnat)
						else:
							tmx_csv += "769,"
					else: 
						if csv[ty+1][tx] in cl45:
							tmx_csv += "241,"
						elif csv[ty+1][tx] in cr45:
							tmx_csv += "245,"
						else:
							tmx_csv += "409,"
			elif is_solid([4],tx,ty,in_bgall,in_bgnat):
				if csv_has(ty,tx-1,fl45,bgfl) and csv_has(ty,tx+1,fr45,bgfr):
					if in_bgnat: tmx_csv += "889,"
					elif in_bgall: tmx_csv += "649,"
					else: tmx_csv += "289,"
				else:
					if in_bgnat: tmx_csv += "981,"
					elif in_bgall: 
						if csv_has (ty,tx-1,cl45,bgcl) or csv_has(ty,tx-1,fl45,bgfl) :
							tmx_csv += get_solid(tx,ty,in_bgall,in_bgnat)
						else:
							tmx_csv += "741,"
					else: 
						if csv_has(ty,tx+1,fr45,bgfr):
							tmx_csv += "241,"
						elif csv_has(ty,tx-1,fl45,bgfl):
							tmx_csv += "245,"
						else:
							tmx_csv += "381,"
			elif is_solid([2],tx,ty,in_bgall,in_bgnat):
				
				if csv_has(ty-1,tx,fl45,bgfl):
					if in_bgnat: tmx_csv += "901,"
					elif in_bgall: tmx_csv += "661,"
					else: tmx_csv += "301,"				
				else:
					if in_bgnat: tmx_csv += "1001,"
					elif in_bgall: tmx_csv += "761,"
					else:
						if csv[ty+1][tx] in cl45:
							tmx_csv += "241,"
						elif csv[ty+1][tx] in cr45:
							tmx_csv += "245,"
						else:
							tmx_csv += "401,"
			elif is_solid([0],tx,ty,in_bgall,in_bgnat):
				if in_bgnat: tmx_csv += "989,"
				elif in_bgall: tmx_csv += "749,"
				else: 
					#//169 165
					if csv_has(ty,tx-1,cl45,bgcl) and csv_has(ty,tx+1,cr45,bgcr):
						tmx_csv += "321,"
					else:
						tmx_csv += "389,"
			else:
				# Not sure what to do with it, so just make it an all-solid
				tmx_csv += get_solid(tx,ty,in_bgall,in_bgnat)
			
		else:
			tmx_csv += "0,"
		
		tx += 1
	tmx_csv += "\n"
	tx = 0
	ty += 1

# remove last newline
tmx_csv = tmx_csv[:-1]
tmx_csv2 = tmx_csv2[:-1]
tmx_csv2 += ","
	
# reconvert into a 2-dim array so we can do repeating patterns
csv = []
csv_idx = 0
for l in tmx_csv.split("\n"):
# remove last comma in each line
	l = l[:-1]
	csv.append([])
	vals = l.split(",")
	#print (csv_idx,len(vals))
	for val in vals:
		csv[csv_idx].append(int(val))
	csv_idx += 1
	
csv2 = []
csv_idx = 0
for l in tmx_csv2.split("\n"):
# remove last comma in each line
	l = l[:-1]
	csv2.append([])
	vals = l.split(",")
	for val in vals:
		csv2[csv_idx].append(int(val))
	csv_idx += 1
	

# Do the repeating patterns by passing over the CSV, as an array

# repeating floors
for y in range(0,len(csv)):
	for x in range(0,len(csv[0])):
		# find tiles that need to be lifted to bg2 - might need to put this above later
		

				
		if csv[y][x] == 281:
			if x+1 < mx and csv[y][x+1] == 281 and x % 2 == 0:
				csv[y][x] = 281
				csv[y][x+1] = 285
			else:
				if x % 2 == 0: csv[y][x] = 281
				else: csv[y][x] = 289
		elif csv[y][x] == 321:
			if x+1 < mx and csv[y][x+1] == 321 and x % 2 == 0:
				csv[y][x] = 321
				csv[y][x+1] = 325
			else:
				if x % 2 == 0: csv[y][x] = 321
				else: csv[y][x] = 329
		if csv[y][x] == 641:
			if x+1 < mx and csv[y][x+1] == 641 and x % 2 == 0:
				csv[y][x] = 641
				csv[y][x+1] = 645
			else:
				if x % 2 == 0: csv[y][x] = 641
				else: csv[y][x] = 649
				#ceil nature
		elif csv[y][x] == 681:
			# back tiles, but different if one is against a wall?
			if x+1 < mx and csv[y][x+1] == 681 and x % 2 == 0:
				csv[y][x] = 681
				csv[y][x+1] = 685
			else:
				if x % 2 == 0: csv[y][x] = 681
				else: csv[y][x] = 689
				#floor nature
		if csv[y][x] == 881:
			if x+1 < mx and csv[y][x+1] == 881 and x % 2 == 0:
				csv[y][x] = 881
				csv[y][x+1] = 885
			else:
				if x % 2 == 0: csv[y][x] = 881
				else: csv[y][x] = 889
				#ceil nature
		elif csv[y][x] == 921:
			if x+1 < mx and csv[y][x+1] == 921 and x % 2 == 0:
				csv[y][x] = 921
				csv[y][x+1] = 925
			else:
				if x % 2 == 0: csv[y][x] = 921
				else: csv[y][x] = 929
				
			
# Now do the repeating walls , as well as a bunch of other edge case things like MOle BGs, stair things, pillar tops/bottoms
for x in range(0,len(csv[0])):
# 103 341 345 349 - r-facing wall. top, bottom, unit.
	for y in range(0,len(csv)):
		
		# molebg
		if molebg != [] and csv[y][x] <= 1333 and csv[y][x] >= 1281 and csv[y][x] not in [1285,1289]:
			ma = range(1281,1333+1)
			if y-1 >= 0: m_u = csv[y-1][x] 
			else: m_u = 0
			if y+1 <= my: m_d = csv[y+1][x] 
			else: m_d = 0
			if x-1 >= 0: m_l = csv[y][x-1] 
			else: m_l = 0
			if x+1 <= mx: m_r = csv[y][x+1] 
			else: m_r = 0
			
			if m_r in ma and m_l in ma:
				if x % 2 == 0: csv[y][x] = 1281 
				else: csv[y][x] = 1282
			elif m_u in ma and m_d in ma:
				csv[y][x] = 1301
			elif m_u in ma and m_r in ma:
				csv[y][x] = 1329
			elif m_d in ma and m_r in ma:
				csv[y][x] = 1321
			elif m_d in ma and m_l in ma:
				csv[y][x] = 1325
			elif m_u in ma and m_l in ma:
				csv[y][x] = 1333
			elif m_r in ma:
				if x % 2 == 0: csv[y][x] = 1281 
				else: csv[y][x] = 1282
				if x -1 >= 0:
					csv[y][x-1] = 1285
			elif m_l in ma:
				if x % 2 == 0: csv[y][x] = 1281 
				else: csv[y][x] = 1282
				
				# add endpt
				if x +1 <= mx:
					csv[y][x+1] = 1289
			elif m_u in ma:
				csv[y][x] = 1309
			elif m_d in ma:
				csv[y][x] = 1305
			# error?
			else:
				csv[y][x] = 1333
			
			#print 123
	
		# Stair extend
		if csv[y][x] in [185] or csv2[y][x] in [185]:
			csv2[y][x+1] = 177
		elif csv[y][x] in [189] or csv2[y][x] in [189]:
			csv2[y][x-1] = 197
		
		tval = csv[y][x]
		# mechbg pillar top/botom
		if csv[y][x] in [745]:
			if csv[y-1][x] not in [0,745,741,753]: csv[y][x] = 741	
			elif y+1 <= my and csv[y+1][x] not in [0,745,749,753]: csv[y][x] = 749	
		# mechbg hor-pillar left-rigth
		if csv[y][x] in [765]:
			if csv[y][x-1] not in [0,761,765,753]: csv[y][x] = 761	
			elif x+1 <= mx and csv[y][x+1] not in [0,765,769,753]: csv[y][x] = 769	
		
			
		#if flag_floor_ceil_butt and orig_csv[y][x] in bgbutt:
		if orig_csv[y][x] in bgbutt:
			innercorner = [633,629]
			#tiled water surface
			tws = [1281,1285] 
			# inner mech bg top/bottom
			# if in the left column of the 2x2 normal bg square:
			
			if tval in [721,729]:
				# Don't change it if the above tile is a backgruond tile (this is done in cases where the solid
				# tile above is lifted visually to BG2 so there's a BG1 tile underneath it)
				if csv[y-1][x] not in [0,697,721,729,641,645,649,749]+innercorner: csv[y][x] = 697	
				# bottom
				elif y+1 <= my and csv[y+1][x] not in [0,737,721,729]+tws: 
					if csv[y-1][x] == 749:
						if x %2 == 0:
							csv[y][x] = 641
						else:
							csv[y][x] = 645
					else:
						if csv[y-1][x] not in [721,729]:
							csv[y][x] = 757
						else:
							csv[y][x] = 737
			if tval in [733,725]:
				if csv[y-1][x] not in [0,717,733,725,641,645,649,749]+innercorner: csv[y][x] = 717	
				elif y+1 <= my and csv[y+1][x] not in [0,757,733,725]+tws: 
					# short top wall and small pillar stouching
					if csv[y-1][x] == 749:
						if x %2 == 0:
							csv[y][x] = 641
						else:
							csv[y][x] = 645
					else:
						csv[y][x] = 757
			# rwall mech bottom/top
			if tval in [701,705]:
				if csv[y-1][x] not in [0,657,701,705]:
					if y % 2 == 0: csv[y+1][x] = 705
					csv[y][x] = 657
				elif y+1 <= my and csv[y+1][x] not in [0,677,701,629]: csv[y][x] = 677
			# lwall mechbottom/topp
			if tval in [661,665]:
				if csv[y-1][x] not in [0,617,665,661,669]: 
					if y % 2 == 0: csv[y+1][x] = 665
					csv[y][x] = 617
				elif y+1 <= my and csv[y+1][x] not in [0,637,661]: csv[y][x] = 637
			
				
		
		# slime walls
		if csv[y][x] == 521:
			if y + 1 < my and csv[y+1][x] == 521:
				csv[y][x] = 521
				csv[y+1][x] = 525
			else:
				csv[y][x] = 529
		if csv[y][x] == 541:
			if y + 1 < my and csv[y+1][x] == 541:
				csv[y][x] = 541
				csv[y+1][x] = 545
			else:
				csv[y][x] = 549
		if csv[y][x] == 103:
			if y + 1 < my and csv[y+1][x] == 103 and y % 2 == 0:
				csv[y][x] = 341
				csv[y+1][x] = 345
			else:
				if y % 2 == 0:
					csv[y][x] = 341
				else:
					csv[y][x] = 349
		if csv[y][x] == 101:
			if y + 1 < my and csv[y+1][x] == 101 and y % 2 == 0:
				csv[y][x] = 301
				csv[y+1][x] = 305
			else:
				if y % 2 == 0:
					csv[y][x] = 301
				else:
					csv[y][x] = 309
		# r wall mech
		if csv[y][x] == 701:
			if y + 1 < my and csv[y+1][x] == 701 and y % 2 == 0:
				csv[y][x] = 701
				csv[y+1][x] = 705
			else:
				if y % 2 == 0: csv[y][x] = 701
				else: csv[y][x] = 709
		# l wall mech
		if csv[y][x] == 661:
			if y + 1 < my and csv[y+1][x] == 661 and y % 2 == 0:
				csv[y][x] = 661
				csv[y+1][x] = 665
			else:
				if y % 2 == 0: csv[y][x] = 661
				else: csv[y][x] = 669
		# r wall nature
		if csv[y][x] == 941:
			if y + 1 < my and csv[y+1][x] == 941 and y % 2 == 0:
				csv[y][x] = 941
				csv[y+1][x] = 945
			else:
				if y % 2 == 0: csv[y][x] = 941
				else: csv[y][x] = 949
		# l wall nature
		if csv[y][x] == 901:
			if y + 1 < my and csv[y+1][x] == 901 and y % 2 == 0:
				csv[y][x] = 901
				csv[y+1][x] = 905
			else:
				if y % 2 == 0: csv[y][x] = 901
				else: csv[y][x] = 909
		# move mech/nat walls underneath (respectively) solid and mech slopes.
		if csv[y][x] in [721,725,729,733] or csv[y][x] in [961,965,969,973]:
			
			#slop = bgcr + bgcl + bgfr + bgfl - mech slopes
			slop = [565,569,585,589]
			vNat = True
			inmech = False
			# if bg tile is in mech wall, slide underneath solid slopes
			if csv[y][x] in [721,725,729,733]:
				slop = [165,169,185,189]
				inmech = True
				vNat = False
			else:
				slop += [165,169,185,189]
				
			if x > 0:
				if csv[y][x-1] in slop:
					csv2[y][x-1] = csv[y][x-1]
					csv[y][x-1] = int(get_solid(x-1,y,True,vNat)[:-1])
			if x + 1 <= mx:
				if csv[y][x+1] in slop:
					csv2[y][x+1] = csv[y][x+1]
					csv[y][x+1] = int(get_solid(x+1,y,True,vNat)[:-1])
			if y > 0:
				if csv[y-1][x] in slop:
					csv2[y-1][x] = csv[y-1][x]
					csv[y-1][x] = int(get_solid(x,y-1,True,vNat)[:-1])
			if y + 1 <= my:
				if csv[y+1][x] in slop:
					csv2[y+1][x] = csv[y+1][x]
					csv[y+1][x] = int(get_solid(x,y+1,True,vNat)[:-1])
			if inmech:
				if y-1 >= 0 and csv[y-1][x] == 749:
					if x % 2 == 0:
						csv[y][x] = 641
					else:
						csv[y][x] = 645
				if y+1 <= my and csv[y+1][x] == 741:
					if x % 2 == 0:
						csv[y][x] = 681
					else:
						csv[y][x] = 685
						
					
			
	
		# alt solid
		if althard_c != []:
			if [x,y] in althard_c:
				csv[y][x] -= 1
				csv[y][x] += 3 - (csv[y][x] % 4)
				csv[y][x] += 1
	
		#underwater slopes
		if csv[y][x] in [185,189]:
			_watr = [1301,1305,1309,1313]
			if csv[y][x] == 185:
				if csv[y][x+1] in _watr:
					csv2[y][x] = 185
					if tx % 2 == 0 and ty % 2 == 0: csv[y][x] = 1301
					if tx % 2 == 1 and ty % 2 == 0: csv[y][x] = 1305
					if tx % 2 == 0 and ty % 2 == 1: csv[y][x] = 1309
					if tx % 2 == 1 and ty % 2 == 1: csv[y][x] = 1313
			elif csv[y][x] == 189:
				if csv[y][x-1] in _watr:
					csv2[y][x] = 189
					if tx % 2 == 0 and ty % 2 == 0: csv[y][x] = 1301
					if tx % 2 == 1 and ty % 2 == 0: csv[y][x] = 1305
					if tx % 2 == 0 and ty % 2 == 1: csv[y][x] = 1309
					if tx % 2 == 1 and ty % 2 == 1: csv[y][x] = 1313
				
		
		# find tiles that need to be lifted to bg2 - might need to put this above later
		# but can't be put above for the need of repeating??
		if csv[y][x] in bg2_lift:
			csv2[y][x] = csv[y][x]
			csv[y][x] = 0
			# check if tile near it (depending on orientation of the edge tile) is next to a back tile
			# if so replace it, IF also, the tile near it is in the right range
			if x > 0 and csv[y][x-1] >= 561 and csv[y][x-1] <= 738 and csv2[y][x] in [301,305,309,249,241]:
				csv[y][x] = int(get_solid(x,y,True,False)[:-1])
			elif y > 0 and csv[y-1][x] >= 561 and csv[y-1][x] <= 738 and csv2[y][x] in [281,285,289,241,245]:
				csv[y][x] = int(get_solid(x,y,True,False)[:-1])
			elif y < my and csv[y+1][x] >= 561 and csv[y+1][x] <= 738 and csv2[y][x] in [321,325,329,249,253]:
				csv[y][x] = int(get_solid(x,y,True,False)[:-1])
			elif x < mx and csv[y][x+1] >= 561 and csv[y][x+1] <= 738 and csv2[y][x] in [341,345,349,245,253]:
				csv[y][x] = int(get_solid(x,y,True,False)[:-1])
			else:
				# 801 to 973+
				if x > 0 and csv[y][x-1] >= 801 and csv[y][x-1] <= 978 and csv2[y][x] in [301,305,309,249,241]:
					csv[y][x] = int(get_solid(x,y,True,True)[:-1])
				elif y > 0 and csv[y-1][x] >= 801 and csv[y-1][x] <= 978 and csv2[y][x] in [281,285,289,241,245]:
					csv[y][x] = int(get_solid(x,y,True,True)[:-1])
				elif y < my and csv[y+1][x] >= 801 and csv[y+1][x] <= 978 and csv2[y][x] in [321,325,329,249,253]:
					csv[y][x] = int(get_solid(x,y,True,True)[:-1])
				elif x < mx and csv[y][x+1] >= 801 and csv[y][x+1] <= 978 and csv2[y][x] in [341,345,349,245,253]:
					csv[y][x] = int(get_solid(x,y,True,True)[:-1])

# We cached the hard gas tiles, so now offset them so they use the hardgas visuals.
for pos in hard_l_pos:
	if csv2[pos[1]][pos[0]] != 0:
		csv2[pos[1]][pos[0]] += 1160
	else:
		csv[pos[1]][pos[0]] += 1160
	
for pos in hard_d_pos:
	if csv2[pos[1]][pos[0]] != 0:
		csv2[pos[1]][pos[0]] += 1280
	else:
		csv[pos[1]][pos[0]] += 1280

# Randomize tiles as needed, based on metadata.		
for y in range(0,len(csv)):
	for x in range(0,len(csv[0])):
		val = csv[y][x]
		
		#361 365 369 373 
		# randomize the 2x2 blocks.
		if r4.has_key(val):
			orig = r4[val]["orig"].split(",")
			if x+1 > mx or y+1 > my:
				continue
			if csv[y][x+1] != int(orig[1]) or csv[y+1][x+1] != int(orig[3])  or csv[y+1][x] != int(orig[2]):
				pass
			elif x+1 <= mx and y+1 <= my:
				# should check if all match, for now dont
				l = r4[val]["len"]
				p_sum = 0
				for i in range(0,l):
					p_sum += r4[val]["p"][i]
				res = random.randint(1,p_sum)
				p_next = 0
				for i in range(0,l):
					p_next += r4[val]["p"][i]
					if res <= p_next:
						newvals = r4[val]["val"][i]
						if newvals == "no_change":
							break
						else:
							# don't transofrm 2x2 if below some bg2 tiles
							if csv2[y][x] == 0 and csv2[y+1][x] == 0 and csv2[y][x+1] == 0 and csv2[y+1][x+1] == 0:
								csv[y][x] = int(newvals.split(",")[0])
								csv[y][x+1] = int(newvals.split(",")[1])
								csv[y+1][x] = int(newvals.split(",")[2])
								csv[y+1][x+1] = int(newvals.split(",")[3])
								val = csv[y][x]
								break
								
		# Randomize single tiles.
		if val > 141:
			if r.has_key(val):
				res = random.randint(1,r[val][4])
				old_v = csv[y][x]
				if res <= r[val][0]:
					pass
				elif res <= r[val][0] + r[val][1]:
					csv[y][x] += 1
				elif res <= r[val][0] + r[val][1] + r[val][2]:
					csv[y][x] += 2
				else:
					csv[y][x] += 3
				# Prevent slopes in bg2 from having anim under them, which would lead to the slope in BG1 in-game being replaced
				if csv[y][x] in r_anim_k:
					if csv2[y][x] != 0:
						csv[y][x] = old_v
						#print str(y) + "," + str(x)
			# If the randomized tile is in bg2_lift... wellllllllll
			if csv[y][x] in bg2_lift:
				csv2[y][x] = csv[y][x]
				if x > 0:
					if csv[y][x-1] in range(721,737):
						csv[y][x] = int(get_solid(x,y,True,False)[:-1])
					# Not sure what the deal is with the 685 alternate bottom-back-near-wall tile, but eh
					if csv[y][x-1] in [689,685]:
						csv[y][x] = 681
					if csv[y][x-1] in [681]:
						csv[y][x] = 685
					if csv[y][x-1] in [649,645]:
						csv[y][x] = 641
					if csv[y][x-1] in [641]:
						csv[y][x] = 649
				if x < mx:
					if csv[y][x+1] in range(721,737):
						csv[y][x] = int(get_solid(x,y,True,False)[:-1])
					if csv[y][x+1] in [689,685]:
						csv[y][x] = 681
					if csv[y][x+1] in [681]:
						csv[y][x] = 685
					if csv[y][x+1] in [649,645]:
						csv[y][x] = 641
					if csv[y][x+1] in [641]:
						csv[y][x] = 649


					
# turn array back to csv string
tmx_csv = ""
tmx_csv2 = ""
for row in csv:
	for val in row:
		tmx_csv += str(val)+","
	tmx_csv += "\n"
for row in csv2:
	for val in row:
		tmx_csv2 += str(val)+","
	tmx_csv2 += "\n"
	
# remove the last comma so Tiled doesn't read it as corrupt
tmx_csv = tmx_csv[:-2]+"\n"
tmx_csv2 = tmx_csv2[:-2]+"\n"

# tmx csv 2 is the BG2 data, which is on top in-game . for somem reason it must be put at the end here fuck
# overwrite the existing tmx
f = open(tmx_path,"w")
f.write(broken_tmx_top+tmx_csv+broken_tmx_mid+tmx_csv2+broken_tmx_bottom)
f.close()


# Now that the .tmx is finalized, we can lookup the animated tiles in the TMX, and replace, in the .bcsv, any relevant '20' (background solid) tiles with the anims
f = open(bcsv_path,"r")
mode = 0
str_out = ""
x = 0
y = 0

print (invisCtr,allCtr,invisCtr/float(allCtr),"if ratio > 70%, reverting debug to invis because original csv was invis")


for l in f.readlines():
	if mode == 0:
		if "BG" in l:
			mode = 1
	elif mode == 1:
		if "BG2" in l:
			mode = 2
		else:
			x = 0
			#csv.append([])
			l = l.strip()
			# 1,2,3
			vals = l.split(",")
			invisexport = False
			for i in range(0,len(vals)):
				# replace existing animted tiles with blank solid 
				# e.g. anim 50 (Tiled) 200 (tilemeta, r_anim_v)
				for ranimv in r_anim_v:
					if vals[i] in ranimv:
						if int(vals[i]) in bcsv_solid:
							if prevval == 60 or invisexport:
								vals[i] = "60"
								invisexport = True
							else:
								vals[i] = "20"
						elif int(val) in water_surface:
							if prevval == 60 or prevval in [1281,1285]:
								vals[i] = "71"
							else:
								vals[i] = "31"
						elif int(val) in water:
							if prevval == 60 or prevval in [1301,1305,1309,1313]:
								vals[i] = "72"
							else:
								vals[i] = "32"
						else:
							if prevval == 240 or invisexport:
								vals[i] = "240"
							else:
								vals[i] = "1"
						#print vals[i]
						break
				prevval = int(vals[i])
				# replace Tiled thingies with bcsv values
				# Change all tiles under [anim] into some other tile
				
				# skip converting a tile to animated if it's BG BUTT tile, because those are special BG that need to be preserved
				if orig_csv[y][x] in bgbutt:
					pass
				else:
					for j in range(0,len(r_anim_k)):
						if str(csv[y][x]) == str(r_anim_k[j]):
							vals[i] = str(r_anim_v[j][random.randint(0,len(r_anim_v[j])-1)])
							#print str(r_anim_k[j])+"->"+vals[i]
					
				# Check the original csv's ratio of invis to all tiles. If greater than 70%, need to reconvert debug tile sto invis.
				if invisCtr/float(allCtr) > 0.7:
					#pass
					if vals[i] in solidToInvis:
						vals[i] = solidToInvis[vals[i]]
					
				x += 1
			# update the line
			l = ','.join(map(str,vals)) + "\n"
			y += 1
	elif mode == 2:
		pass
	str_out += l

f.close()
f = open(bcsv_path,"w")
f.write(str_out)
f.close()

	

print "\n.tmx file updated! Press any key to exit."
if skiprawinput == False:
	raw_input()