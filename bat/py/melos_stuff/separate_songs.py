# Separate songs for a build
# ran in bat/py/melos_stuff
import shutil

do_all = True
do_intro = True
list_all = ["null","title_2"]
list_intro = ["intro_scene_short","intro_scene_ambience","introcave_2","cassisdead","intro_plant_core"]

if do_all:
	for n in list_all:
		shutil.copy("../../../assets/mp3/song/"+n+".ogg","../../../_noncrypt_assets/mp3/")
if do_intro:
	for n in list_intro:
		shutil.copy("../../../assets/mp3/song/"+n+".ogg","../../../_noncrypt_assets/mp3/")
