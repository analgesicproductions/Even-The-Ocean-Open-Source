from os import listdir, remove
from os.path import isfile, join, exists
mypath = "../../../assets/map_ent/"
onlyfiles = [ f for f in listdir(mypath) if isfile(join(mypath,f)) ]



for i in range(0,len(onlyfiles)):
	fname = onlyfiles[i].replace(".ent","")
	if exists("../../../assets/csv/"+fname+".bcsv") == False:
		print fname+".bcsv doesnt exist"
	

mypath = "../../../assets/map_ent/"
onlyfiles = [ f for f in listdir(mypath) if isfile(join(mypath,f)) ]

#	print onlyfiles


#os.path.exists


raw_input("press any key to exit")