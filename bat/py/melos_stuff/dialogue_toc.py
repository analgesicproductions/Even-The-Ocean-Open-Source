import sys

_in = sys.argv[1]
f = open("../../../txt/etc/localizations/"+_in,"r")

s = ""
for line in f:
	
	if line[0:3] == "MAP":
		s = s+ line
	if line[0:5] == "SCENE":
		s = s+"\t"+line
		

		
f.close()

f = open("../../../txt/etc/localizations/out.txt","w")

f.write(s)
f.close()
