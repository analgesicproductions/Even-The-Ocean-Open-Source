

prompt = "\n\n>>> "


while 1 == 1:
	a = raw_input("What is the new tileset name?"+prompt)
	an = raw_input("Confirm: \""+a+"\""+prompt+" (y/n) ")
	if an == "y":
		break
	else:
		exit()
		
f = open("../../assets/tile_meta/"+a.upper()+".tilemeta","w")
af = open("../../assets/tile_meta/DEBUG4.tilemeta","r")

f.write(af.read())
f.close()
af.close()

import shutil
shutil.copyfile("../../assets/tile_meta/"+a.upper()+".tilemeta","../../export/windows/cpp/bin/assets/tile_meta/"+a.upper()+".tilemeta")


raw_input("Created "+a.upper()+".tilemeta in assets and also copied it to export/windows/cpp/bin/assets/tile_meta.")