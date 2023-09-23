from os import listdir, remove
from os.path import isfile, join, exists
mypath = "../../../assets/csv/"
onlyfiles = [ f for f in listdir(mypath) if isfile(join(mypath,f)) ]

skip = ["SHORE_1","SHORE_2","SHORE_3","SHORE_4"]


for i in range(0,len(onlyfiles)):
	s = onlyfiles[i]
	
	s = s.replace("_BG.csv","")
	s = s.replace("_BG2.csv","")
	s = s.replace("_FG.csv","")
	s = s.replace("_FG2.csv","")
	onlyfiles[i] = s
	
onlyfiles = list(set(onlyfiles))

for filename in onlyfiles:
	if ".bcsv" in filename or ".csv" in filename:
		continue
	if exists(mypath+filename+".bcsv"):
		print "Skip "+filename
		continue
	else:
		print "Deleting old / making bcsv for "+filename
		s = open(mypath+filename+"_BG.csv","r").read()
		lines = s.split("\n")
		line = lines[0]
		w = len(line.split(","))
		h = len(lines)
		s = ""
		print str(w)+","+str(h)+"\n"
		s += str(w)+","+str(h)+"\n"
		s += "BG\n"
		s += open(mypath+filename+"_BG.csv","r").read().rstrip()
		s += "\nBG2\n"
		s += open(mypath+filename+"_BG2.csv","r").read().rstrip()
		s += "\nFG\n"
		s += open(mypath+filename+"_FG.csv","r").read().rstrip()
		s += "\nFG2\n"
		s += open(mypath+filename+"_FG2.csv","r").read().rstrip()
		try:
			remove("../../../export/windows/cpp/bin/assets/csv/"+filename+"_BG.csv")
		except IOError:
			pass
		try:
			remove("../../../export/windows/cpp/bin/assets/csv/"+filename+"_BG2.csv")
		except IOError:
			pass
		try:
			remove("../../../export/windows/cpp/bin/assets/csv/"+filename+"_FG.csv")
		except IOError:
			pass
		try:
			remove("../../../export/windows/cpp/bin/assets/csv/"+filename+"_FG2.csv")
		except IOError:
			pass
		f = open(mypath+filename+".bcsv","w")
		f.write(s)
		f.close()

#	print onlyfiles


#os.path.exists


raw_input("press any key to exit")