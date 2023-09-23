
import os

old_list = []
new_list = []

while 1 == 1:
	a = raw_input("Rename from the contents of rename_map.txt? (y/n) >>> ")
	if a == "y":
		f = open("rename_map.txt","r")
		for line in f:
			if len(line) < 2: 
				continue
			line = line.strip()
			old_list.append(line.split(",")[0])
			new_list.append(line.split(",")[1])
		f.close()
	else:
		exit()
	break
		
ent_path = "../../assets/map_ent/"
csv_path = "../../assets/csv/"

for i in range(0,len(old_list)):
	try:
		os.rename(ent_path+old_list[i]+".ent",ent_path+new_list[i]+".ent")
		
		print "Renamed "+old_list[i]+" to "+new_list[i]
	except WindowsError:
		print new_list[i]+" already exists, skipping."
		pass
	
	
	try:
		os.rename(csv_path+old_list[i]+".bcsv",csv_path+new_list[i]+".bcsv")
		print "Renamed "+old_list[i]+" to "+new_list[i]
	except WindowsError:
		print new_list[i]+" already exists, skipping."
		pass

f = open("../../assets/world.map","r")

mode = 0
s = ""
for line in f:
	if mode == 0:
		if line[0:7] == "BG_HASH":
			mode = 1
	elif mode == 1:
		if line[0:12] == "TILESET_LIST":
			mode = 2
		else:
			if len(line) > 6:
				if line.split(" ")[0] in old_list:
					i = old_list.index(line.split(" ")[0])
					line = line.replace(old_list[i],new_list[i],1)
	s += line

f.close()
f = open("../../assets/world.map","w")
f.write(s)
f.close()


raw_input("\n\nDone! Press any key to exit.")


