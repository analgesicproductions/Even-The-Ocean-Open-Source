# -*- coding: utf-8 -*-
ZH = True
p = open("../../../assets/dialogue/RU.txt","r")

mode = 0

line_nr = 0
line_end = ""
char_end = ""
char_nr = 0
dbQuoteChar = 0

header_mode = 0
header_s = ""
headers = open("headers.txt","w")

mN = 0
emN = 0 
sN = 0
esN = 0


for line in p.readlines():

	if header_mode == 0:
		if len(line.split(" ")) > 0:
			if line[0:3] == "MAP":
				header_mode = 1
				header_s += line
				mN += 1
	elif header_mode == 1:
		if len(line) > 5:
			if line[0:6] == "ENDMAP":
				header_mode = 0
				#header_s += line
				emN += 1
			if line[0:5] == "SCENE":
				#header_s += line
				header_mode = 2
				sN += 1
	elif header_mode == 2:
		if len(line) > 8:
			if line[0:8] == "ENDSCENE":
				#header_s += line
				header_mode = 1
				esN += 1

	if mode == 1 or mode == 2 or mode == 3:
		s = line_end+ " Premature EOL"
		if mode == 1:
			s += " - Looking for start %% tag"
		if mode == 2 or mode == 3:
			s += " - Looking for close %% tag"
		print s
		mode = 0
	line_nr += 1
	line_end = "("+str(line_nr)+")"
	char_nr = 0
	
	
	if False == ZH:
		if "’" in line:
			print "Bad single quote "+line_end
		if "”" in line:
			print "Bad double quote "+line_end
		if "“" in line:
			print "Bad double quote "+line_end
		if "…" in line:
			print "Bad ... "+line_end
	for c in line:
		char_end = "("+str(char_nr)+")"
# Look for first percent		
		if mode == 0:
			if c == "%":
				mode = 1
# Look for second				
		elif mode == 1:
			if c == "%":
				mode = 2
				dbQuoteChar = char_nr
			else:
				print "ERROR: Non-wrapped % "+line_end+char_end
				mode = 0
				break
# 2: Look for single % or an exit %%				
		elif mode == 2:
			if c == "%":
				if dbQuoteChar == char_nr - 1:
					print "ERROR: triple (or more) % "+line_end+char_end
				mode = 3
#3:  Look for 2nd part of exit %% or return to 2.				
		elif mode == 3:
			if c != "%":
				mode = 2
			if c == "%":
				mode = 0
		char_nr += 1

p.close()


print mN,emN
print sN,esN

if header_mode == 1:
	print "ERROR: Missing an ENDMAP"
if header_mode == 2:
	print "ERROR: missing an ENDSCENE"
	
headers.write(header_s)
headers.close()
	
print "done press any key"
raw_input("Done")