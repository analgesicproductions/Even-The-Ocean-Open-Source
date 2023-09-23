# -*- coding: utf-8 -*-

# formatter for things like !i %%name%NAME%% %%pic%PICNAME%% %%speaker%NONE%% 
# Also replaces angled single, double quotes and the condesned ellipses character

#why  didnt i do this earlier

# Enter Data like

# aliph,s=none
# n=Violet,s=g0
# START
# Aliph line 1
# Aliph line 2
# blank
# Response
# END
#Outputs:
#!i %%aliph%% %%speaker%none%Aliph line 1
#!i %%aliph%% %%speaker%none%Aliph line 2
#%%pic%Violet%% %%speaker%none%Response


p = open("df_in.txt","r")

meta0 = []
meta1 = []
meta2 = []
meta3 = []
meta4 = []
mode = 0
sp = 0
out_s = ""
lines = []

# format each line - replace bad characters and remove line endings
for l in p.readlines():
	l = l.replace("…","...")
	l = l.replace("“","\"")
	l = l.replace("”","\"")
	l = l.replace("’","'")
	lines.append(l.strip())

for l in lines:
	# Mode 0, Parse metadata
	if mode == 0:
		if "START" in l:
			#2 speaker case... TODO modify later?
			if meta2 == []:
				mode = 1
		else:
			if meta0 == []:
				meta0 = l.split(",")
			elif meta1 == []:
				meta1 = l.split(",")
			elif meta2 == []:
				meta2 = l.split(",")
			elif meta3 == []:
				meta3 = l.split(",")
			elif meta4 == []:
				meta4 = l.split(",")
	#2 speaker case
	elif mode == 1:
			
		# blank line denotse speaker change
		if l == "":
		
			# TODO: Add a conditonal here for more than 2 speakers
			sp = (sp + 1) % 2
		else:
			# Add immediate thing
			if l != lines[-1]:
				out_s = out_s + "!i "
			meta = []
			meta_s = ""
			
			
			if sp == 0:
				meta = list(meta0)
			if sp == 1:
				meta = list(meta1)
				
			# aliph,s=none
			# p=Violet,s=g0
			# Add the metadata
			#print meta	
			for s in meta:
				if s == "aliph":
					meta_s = meta_s + "%%aliph%%"
				if "=" in s:
					pts = s.split("=")
					# s for speaker
					if pts[0] == "s":
						if pts[1] == "none":
							meta_s = meta_s + "%%speaker%none%%"
						elif pts[1][0] == "g":
							meta_s = meta_s + "%%speaker%g%"+pts[1][1]+"%%"
					# p for pic
					if pts[0] == "p":
						meta_s = meta_s + "%%pic%"+pts[1]+"%%"
					if pts[0] == "n":
						meta_s = meta_s + "%%name%"+pts[1]+"%%"
					
				if s != meta[-1]:
					meta_s = meta_s + " "
			out_s = out_s + meta_s
			out_s = out_s + l
			if l != lines[-1]:
				out_s = out_s + "\n"

p.close()
p = open("df_out.txt","w")
p.write(out_s)
p.close()