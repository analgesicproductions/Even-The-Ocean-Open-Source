from os import listdir, remove
from os.path import isfile, join, exists
mypath = "../../../assets/map_ent/"
onlyfiles = [ f for f in listdir(mypath) if isfile(join(mypath,f)) ]


p = open("../../../Project.xml","r")
f = open("../../../assets/mp3/songtriggers.txt")

song_list = []
for line in f:
	song_list = line.split(" ")[1].split(",")
	break
f.close()

s = p.read()
for song in song_list:
	if song not in s:
		print "Not found in Project.xml: "+song


p.close()

p = open("../../../Project.xml","r")
for line in p:
	if "<music" in line:
		s = line.split("id=")[1]
		end = s.index("\"",1)
		s = s[1:end]
		if s not in song_list:
			print "Not found in songtriggers.txt: ."+s+"."
		
p.close()

f = open("../../../assets/mp3/songtriggers.txt")

maplist = []
for line in f:
	if len(line.split(" ")) > 0 and line.split(" ")[0] == "map":
		maplist.append(line.split(" ")[1].rstrip().upper())
#print line.split(" ")[1].rstrip()


ignorelist = ["WOODS_TOP","WOODS_TOWER","WOODS_UP2","WOODS_G2_2","WOODS_G2_1","WOODS_COURTYARD","WOODS_CORE","WOODSTEST","WINDHILLBOSS","WHITE_TUNNEL","TWITCH","TOWN_THING","TOWN_IN","TOWN_ENTER","TEST_SMALL","TEST_CAM","TESTTWO","TESTCLIFF","TEST5","TEST3","SHORETEST","SHOREROUTER","SHOREPLACE_CORE","SHOREPLACE_BOSS","SEA_BOSS","SEA_2","SEA_3","SEA_4","SEA_5","SEA_6","SEA_7","SEANLET","SEAN1","RIVER_TUBE","RIVER_TOP","RIVER_R","RIVER_TEST","RIVER_PATH","RIVER_L","RIVER_G1_5","RIVER_G1_4","RIVER_G1_3","RIVER_G1_2","RIVER_G1_1","AIR_1","AIR_2","AIR_3","AIR_4","AIR_5","AIR_6","AIR_7","AIR_8","AIR_OUT","BIGCLIFF_SHORE","BLUEROCKOUT","BOSSTEST","JUMPTEST","LOOKTEST","PASS_ARTIST","PASS_BASEMENT","PASS_BUILDING_1","PASS_ENTER","PASS_PLATEAU","PASS_RIVERSIDE","PASS_TOWER_2","REALHOME","RIVER","RIVERTEST","RIVER_A","RIVER_TOWER","WF_TRAIN_L","CANYONIN1","CANYONIN2","CANYONOUT1","CANYONOUT2","JONLET","JONTEST02","JONTEST03","MAPONE","NPC_CANYON","NPC_CITY","WOODS_TEST","INTRO_ITEM"]

for i in range(0,len(onlyfiles)):
	fname = onlyfiles[i].replace(".ent","")
	if fname.upper() not in maplist and fname.upper() not in ignorelist:
		print fname

raw_input()