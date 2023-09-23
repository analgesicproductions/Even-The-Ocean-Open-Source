print "this will make the .bcsv and .ent files. make sure to add the new map to world.map!\n note: if you give a comma list, then this will make all of those maps"

while 1 == 1:
	new_name = raw_input("name?").upper()
	w = int(raw_input("width?"))
	h = int(raw_input("height?"))
	a = raw_input("confirm (y/n/q): "+new_name+" "+str(w)+" "+str(h))
	if a == "y":
		break
	if a == "q":
		exit()

if "," in new_name:
	li = new_name.split(",")
	for name in li:
		f = open ("../../assets/map_ent/"+name+".ent","w")
		f.write("BBG START\nBG1 START\nBG2 START\nFG2 START")
		f.close()

		s = ""

		f = open("../../assets/csv/"+name+".bcsv","w")
		f.write(str(w)+","+str(h)+"\n"+"BG\n"+"0"+"\nBG2\n"+"0"+"\nFG\n"+"0"+"\nFG2\n"+"0")
		print "made "+name
		f.close()
else:
	f = open ("../../assets/map_ent/"+new_name+".ent","w")
	f.write("BBG START\nBG1 START\nBG2 START\nFG2 START")
	f.close()

	s = ""

	f = open("../../assets/csv/"+new_name+".bcsv","w")
	f.write(str(w)+","+str(h)+"\n"+"BG\n"+"0"+"\nBG2\n"+"0"+"\nFG\n"+"0"+"\nFG2\n"+"0")
	f.close()
raw_input()