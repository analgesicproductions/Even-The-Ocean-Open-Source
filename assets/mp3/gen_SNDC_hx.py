import os

s = "package autom;\n//AUTOMATICALLY GENERATED\nclass SNDC\n{\n"
fin = open("sound.meta","r")
for line in fin:
	name = line.split(" ")[0]
	if name[0] == "#":
		continue
	
	s += "public static inline var "
	if name[1] == "rg":
		s += "rg_"
	s += name.split(".")[0].replace("/","_")
	s += ":String = \""
	s += name
	s += "\";\n"

s += "}"

f = open("../../source/autom/SNDC.hx","w")
f.write(s)
	
