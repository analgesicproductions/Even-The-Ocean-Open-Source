# from  http://coreygoldberg.blogspot.com/2013/01/python-verify-png-file-and-get-image.html

import struct

def is_png(data):
    return (data[:8] == '\211PNG\r\n\032\n'and (data[12:16] == 'IHDR'))

def get_image_info(data):
    if is_png(data):
        w, h = struct.unpack('>LL', data[16:24])
        width = int(w)
        height = int(h)
    else:
        raise Exception('not a png image')
    return width, height



import os
clear = lambda: os.system('cls')

w = 64
h = 164
bg_name = ""
map_name = ""
tileset_name = ""

# First check for a valid PNG
while 1 == 1:
	clear()
	print "This will add a BG image's BG_LIST and PARALLAX_SETS metadata into world.map, and optionally, add a new map entry to world.map.\n\n"
	bg_name = raw_input("Enter the BG name. e.g. river/BG_1\n\n>>> ")
	clear()
	a = raw_input("Is this \""+bg_name+"\" correct?\n\n(y/n/q)\n\n>>> ")
	if a == "y":
		try:
			with open("../../assets/sprites/bg/"+bg_name+'.png', 'rb') as f:
				data = f.read()
			w, h = get_image_info(data)
		except IOError:
			raw_input("Error - assets/sprites/bg/"+bg_name+".png does not exist. Enter any key to try again.")
			clear()
			continue
		clear()
		break
	if a == "q":
		exit()
		

#Then ask for the map name (RIVER_1) and its tileset (RIVER)		
while 1 == 1:
	map_name = raw_input("Also add a map entry to world.map?\n\n(y/n)\n\n>>> ")
	if map_name == "y":
		clear()
		while 1 == 1:
			map_name = raw_input("What is the map name? (e.g. RIVER_1)\n\n>>> ")
			clear()
			tileset_name = raw_input("What is the tileset name? (e.g. RIVER)\n\n>>> ")
			clear()
			a = raw_input("Confirm: Map = "+map_name+" Tileset = "+tileset_name+"\n\n(y/n)\n\n>>> ")
			if a == "y":
				break
			clear()
	else:
		map_name = ""
	break
			
#print bg_name + " "+ map_name + " " + tileset_name			


# Create the new BG_LIST entry for the background tile,
# The entry for the map name to parallax set / tileset,
# And the entry for the new parallalx set
set_name = ""
if map_name != "":
	if "/" in bg_name:
		set_name = "SET_"+bg_name.replace("/","_").upper()
	else:
		set_name = "SET_"+bg_name
else:
	set_name = "SET_"+bg_name.replace("/","_").upper() 

bg_entry_name = bg_name.replace("/","_")
new_bg_entry = bg_entry_name + " " + bg_name + "\t\t\t\t"+"("+str(w)+","+str(h)+","+"\t\t\t"+"1,1,"+"\t\t\t"+"0,0,"+"\t\t\t"+"0,0)"
new_map_entry = map_name + " " + set_name + " "+ tileset_name
new_set_entry = set_name + " " + bg_entry_name + " none"
if map_name == "":
	new_map_entry = ""

print new_bg_entry
print new_map_entry
print new_set_entry


f = open("../../assets/world.map","r")

s = ""
mode = 0

# Insert BG_LIST entry
for line in f:
	if mode == 0:
		s += line
		if "BG_LIST" in line:
			mode = 1
			continue;
	if mode == 1:
		if len(line) <= 2:
			s += new_bg_entry+"\n"
			mode = 2;
		s += line
	if mode == 2:
		s += line

f.close()
f = open ("../../assets/world.map","w")
f.write(s)
f.close()
f = open ("../../assets/world.map","r")
mode = 0
s = ""

# Add the map name (optionally)
if map_name != "":
	for line in f:
		if mode == 0:
			s += line
			if "BG_HASH" in line:
				mode = 1
				continue;
		if mode == 1:
			if len(line) <= 2:
				s += new_map_entry+"\n"
				mode = 2;
			s += line
		if mode == 2:
			s += line
	f.close()
	f = open ("../../assets/world.map","w")
	f.write(s)
	f.close()
	f = open ("../../assets/world.map","r")
	mode = 0
	s = ""

# Add set name
for line in f:
	if mode == 0:
		s += line
		if "PARALLAX_SETS" in line:
			mode = 1
			continue;
	if mode == 1:
		if len(line) <= 2:
			s += new_set_entry+"\n"
			mode = 2;
		s += line
	if mode == 2:
		s += line
f.close()
f = open ("../../assets/world.map","w")
f.write(s)
f.close()
