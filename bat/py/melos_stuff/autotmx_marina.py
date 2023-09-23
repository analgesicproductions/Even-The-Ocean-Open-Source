from subprocess import call
# must exist in bg folder
#tmx = "rouge/BG_G1"
#tmx = "rouge/BG_G2"
#tmx = "canyon/BG_G1"
#tmx = "canyon/BG_G2"
#tmx = "canyon/BG_G3"
#tmx = "canyon/BG_G4"
#tmx = "canyon/BG_B"
#tmx = "shore/BG_G1"
#tmx = "hill/BG_G1"
#tmx = "river/BG_G1"
#tmx = "basin/BG_G1"
#tmx = "woods/BG_G1"
#tmx = "cliff/BG_G2"
#tmx = "pass/BG_G1"
#tmx = "falls/BG_G1"
#tmx = "radio/BG_G1"
#tmx = "radio/BG_G3"
#tmx = "/BG_G1"

# must exist in tilemeta folder
#tmeta = "DEBUG4"
#tmeta = "ROUGE"
#tmeta = "CANYON"
#tmeta = "SHOREPLACEA"
#tmeta = "HILL"
#tmeta = "RIVER"
#tmeta = "BASIN"
#tmeta = "WOODS"
#tmeta = "CLIFF"
#tmeta = "PASS"
#tmeta = "FALLS"
#tmeta = "RADIO"
#tmeta = "RADIO2"

# must exist in csv/ folder
#csv = "ROUGE_G1"
#csv = "ROUGE_G2"
#csv = "CANYON_G1"
#csv = "CANYON_G2"
#csv = "CANYON_G3"
#csv = "CANYON_G4"
#csv = "CANYON_B"
#csv = "SHORE_G1"
#csv = "HILL_G1"
#csv = "RIVER_G1"
#csv = "BASIN_G1"
#csv = "WOODS_G1"
#csv = "CLIFF_G2"
#csv = "PASS_G1"
#csv = "FALLS_G1"
#csv = "RADIO_G1"
#csv = "RADIO_G3"

print "Running autotiler..."
# The three arguments to this call are the tmx, the tilemeta, and the csv file.
#call(["python","autotmx.py","rouge/BG_G1","ROUGE","ROUGE_G1","yes"])
#call(["python","autotmx.py","rouge/BG_G2","ROUGE","ROUGE_G2","yes"])
#call(["python","autotmx.py","rouge/BG_B","ROUGE","ROUGE_B","yes"])
#call(["python","autotmx.py","canyon/BG_G1","CANYON","CANYON_G1","yes"])
#call(["python","autotmx.py","canyon/BG_G2","CANYON","CANYON_G2","yes"])
#call(["python","autotmx.py","canyon/BG_G3","CANYON","CANYON_G3","yes"])
#call(["python","autotmx.py","canyon/BG_G4","CANYON","CANYON_G4","yes"])
#call(["python","autotmx.py","canyon/BG_B","CANYON","CANYON_B","yes"])
#call(["python","autotmx.py","shore/BG_G1","SHOREPLACEA","SHORE_G1","yes"])
#call(["python","autotmx.py","shore/BG_G2","SHOREPLACEA","SHORE_G2","yes"])
#call(["python","autotmx.py","shore/BG_G3","SHOREPLACEA","SHORE_G3","yes"])
#call(["python","autotmx.py","shore/BG_G4","SHOREPLACEA","SHORE_G4","yes"])
#call(["python","autotmx.py","shore/BG_B","SHOREPLACEA","SHORE_B","yes"])
#MANUALLY_EDITED_call(["python","autotmx.py","hill/BG_G1","HILL","HILL_G1","yes"])
#MANUALLY_EDITED_CAUTIONcall(["python","autotmx.py","hill/BG_G2","HILL","HILL_G2","yes"])
#MANUALLY_EDITED_CAUTIONcall(["python","autotmx.py","hill/BG_G3","HILL","HILL_G3","yes"])
#MANUALLY_EDITED_CAUTIONcall(["python","autotmx.py","hill/BG_G4","HILL","HILL_G4","yes"])
#MANUALLY_EDITED_CAUTIONcall(["python","autotmx.py","hill/BG_B","HILL","HILL_B","yes"])
#call(["python","autotmx.py","woods/BG_G1","WOODS","WOODS_G1","yes"])
#call(["python","autotmx.py","woods/BG_G2","WOODS","WOODS_G2","yes"])
#call(["python","autotmx.py","woods/BG_G3","WOODS","WOODS_G3","yes"])
#call(["python","autotmx.py","woods/BG_G4","WOODS","WOODS_G4","yes"])
#call(["python","autotmx.py","woods/BG_B","WOODS","WOODS_B","yes"])
#call(["python","autotmx.py","basin/BG_G1","BASIN","BASIN_G1","yes"])
#call(["python","autotmx.py","basin/BG_G2","BASIN","BASIN_G2","yes"])
#call(["python","autotmx.py","basin/BG_G3","BASIN","BASIN_G3","yes"])
#call(["python","autotmx.py","basin/BG_G4","BASIN","BASIN_G4","yes"])
#call(["python","autotmx.py","basin/BG_B","BASIN","BASIN_B","yes"])
#call(["python","autotmx.py","river/BG_G1","RIVER","RIVER_G1","yes"])
#call(["python","autotmx.py","river/BG_G2","RIVER","RIVER_G2","yes"])
#call(["python","autotmx.py","river/BG_G3","RIVER","RIVER_G3","yes"])
#call(["python","autotmx.py","river/BG_G4","RIVER","RIVER_G4","yes"])
#call(["python","autotmx.py","river/BG_B","RIVER","RIVER_B","yes"])
#call(["python","autotmx.py","woods/BG_G1","WOODS","WOODS_G1","yes"])
#call(["python","autotmx.py","woods/BG_G2","WOODS","WOODS_G2","yes"])
#call(["python","autotmx.py","woods/BG_G3","WOODS","WOODS_G3","yes"])
#call(["python","autotmx.py","woods/BG_G4","WOODS","WOODS_G4","yes"])
#call(["python","autotmx.py","woods/BG_B","WOODS","WOODS_B","yes"])
#call(["python","autotmx.py","cliff/BG_G1","CLIFF","CLIFF_G1","yes"])
#call(["python","autotmx.py","cliff/BG_G2","CLIFF","CLIFF_G2","yes"])
#call(["python","autotmx.py","cliff/BG_G3","CLIFF","CLIFF_G3","yes"])
#call(["python","autotmx.py","cliff/BG_G4","CLIFF","CLIFF_G4","yes"])
#call(["python","autotmx.py","cliff/BG_B","CLIFF","CLIFF_B","yes"])
#call(["python","autotmx.py","pass/BG_G0","PASS","PASS_G0","yes"])
#Edited pass_g1 and g2 to fix a few edge cases. I can actually fix these in the autotiler if needed. - Melos
#MANUALLY_EDITED_BY_Melos_TO_FIX_A_FEW_EDGE_CASES call(["python","autotmx.py","pass/BG_G1","PASS","PASS_G1","yes"])
#MANUALLY_EDITED_BY_Melos_TO_FIX_A_FEW_EDGE_CASES call(["python","autotmx.py","pass/BG_G2","PASS","PASS_G2","yes"])
#call(["python","autotmx.py","pass/BG_G3","PASS","PASS_G3","yes"])
#call(["python","autotmx.py","pass/BG_G4","PASS","PASS_G4","yes"])
#call(["python","autotmx.py","pass/BG_B","PASS","PASS_B","yes"])
call(["python","autotmx.py","falls/BG_G1","FALLS","FALLS_G1","yes"])
#call(["python","autotmx.py","falls/BG_G2","FALLS","FALLS_G2","yes"])
#call(["python","autotmx.py","falls/BG_G3","FALLS","FALLS_G3","yes"])
#call(["python","autotmx.py","falls/BG_G4","FALLS","FALLS_G4","yes"])
#call(["python","autotmx.py","falls/BG_B","FALLS","FALLS_B","yes"])
#call(["python","autotmx.py","radio/BG_LOBBY","RADIO","RADIO_LOBBY","yes"])
#call(["python","autotmx.py","radio/BG_D1","RADIO","RADIO_D1","yes"])
#call(["python","autotmx.py","radio/BG_DB","RADIO","RADIO_DB","yes"])
#call(["python","autotmx.py","radio/BG_G1","RADIO","RADIO_G1","yes"])
#MANUALLY EDITED call(["python","autotmx.py","radio/BG_G2","RADIO","RADIO_G2","yes"])
#call(["python","autotmx.py","radio/BG_G3","RADIO2","RADIO_G3","yes"])
#call(["python","autotmx.py","radio/BG_G4","RADIO2","RADIO_G4","yes"])
#call(["python","autotmx.py","radio/BG_B","RADIO2","RADIO_B","yes"])

#MANUALLY_EDITED_CAUTION call(["python","autotmx.py","silo_sea/BG_1","SILOSEA","SEA_SILO_1","yes"])
#MANUALLY_EDITED_CAUTION call(["python","autotmx.py","silo_sea/BG_2","SILOSEA","SEA_SILO_2","yes"])
#call(["python","autotmx.py","silo_earth/BG_1","SILOEARTH","EARTH_SILO_1B","yes"])
#call(["python","autotmx.py","silo_earth/BG_2","SILOEARTH","EARTH_SILO_2B","yes"])
#call(["python","autotmx.py","silo_air/BG_1","SILOAIR","AIR_SILO_1","yes"])
#call(["python","autotmx.py","silo_air/BG_2","SILOAIR","AIR_SILO_2","yes"])
print "Done! Press any key to exit."
raw_input()