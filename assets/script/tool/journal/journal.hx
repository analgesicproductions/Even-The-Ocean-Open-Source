// tested 2016 4 1 - reloading this script, reloading the journal.txt file.

// INTRO Rouge + i0 City
var s = "intro,1\n";
if (this.get_ss("intro", "earthquake", 1) == 1) {
	s += "intro,2\n";
}

if (this.get_event_state(23)) {
	s += "intro,3\n";
}


if (this.get_ss("city", "aliph_fades", 1) != 0) {
	s += "i0,1\n";
	s += "i0,2\n";
	s += "i0,3\n";
}

if (this.get_ss("city", "mayor_intro", 1) != 0) {
	s += "i0,4\n";
	s += "i0,5\n";
	s += "i0,6\n";
}


if (this.get_ss("city", "intro_aliph_home", 2) != 0) {
	s += "i0,7\n";
	s += "i0,8\n";
	s += "i0,9\n";
	s += "i0,10\n";
}

if (this.get_ss("city", "intro_armor", 1) != 0) {
	s += "i0,11\n";
}

if (this.get_ss("city", "intro_yara", 1) != 0) {
	s += "i0,12\n";
}

// 26 27 28
// 34 35 36
// 40 41 42

// These IDs are:
// G1_1 G1_2 G1_3 FINISHED..
// g2...
// g3...

// get ID of first gauntlet. 
// check for events for that particular one, push entries
// next loop iteration is 'area finished'm which will sum it up?
// order matters

var s3firstdone = false;

for (i in [26, 29, 27, 30, 28, 31, 34, 37, 35, 38, 36, 39, 40, 43, 41, 44, 42, 45]) {
	if (this.get_event_state(i) || i == 26 || i == 27 || i == 28 || i == 34 || i == 35 || i == 36  || i == 40 || i == 41 || i == 42) {
		var p = 0;
		
		// if beat g1_1...
		if (i == 29) {
			// find what the ID of the area was.
			p = this.get_event_state(26, true);
		} else if (i == 30) {
			p = this.get_event_state(27, true);
		} else if (i == 31) {
			p = this.get_event_state(28, true);
		} else if (i == 37) {
			p = this.get_event_state(34, true);
		}else if (i == 38) {
			p = this.get_event_state(35, true);
		}else if (i == 39) {
			p = this.get_event_state(36, true);
		}else if (i == 43) {
			p = this.get_event_state(40, true);
		}else if (i == 44) {
			p = this.get_event_state(41, true);
		}else if (i == 45) {
			p = this.get_event_state(42, true);
		}
		
		
		// add the events *of* the nature areas
			// if say, G1_1 is set, then
		if (i == 26 || i == 27 || i == 28 || i == 34 || i == 35 || i == 36  || i == 40 || i == 41 || i == 42 ) {
			p = 10 + this.get_event_state(i,true);
			if (p == 11) {
				// check for shore flaggos
				if (this.get_ss("shore", "starfish_center", 1) != 0) {
					s += "shore,3\n";
				}
			} else if (p == 12) {
				if (this.get_ss("canyon", "moonderful_first", 1) > 0) {
					s += "canyon,2\n";
				}
				if (this.get_ss("canyon", "didney", 1) > 0) {
					s += "canyon,3\n";
				}
			} else if (p == 13) {
				if (this.get_ss("hill", "wilbert", 1) > 0) {
					s += "hill,2\n";
				}
				if (this.get_ss("hill", "room_vera_after_bay", 1) > 0) {
					s += "hill,3\n";
				}
			} else if (p == 14) { // river
				// after talking to jr gatekeper
				if (this.get_ss("river", "jr_1",1) > 0) {
					s += "river,2\n";
				}
			} else if (p == 15) { // woods 
				// doesnt really need hints
			} else if (p == 16) { // forest
				// afer seeing closed lifto
				if (this.get_ss("forest", "aliph_lift", 1) > 0) {
					s += "basin,2\n";
				}
			}
				
			// this is harder, since these arent set till the end of the geome
			// they'll mostly be in the right order if they're all pushed here
			// and *not* pushed if the respective area is done
			
			// s3firstdone enforces that this segment of code only adds ONCE.
			if ((i == 40 || i == 41 || i == 42) && !s3firstdone) {
				
				if (this.get_event_state(i, true) >= 7) {
					
				} else {
					if (this.get_event_state(17, true) != 1) { // if pass not done
						if (this.get_ss("pass", "jane_init", 1) > 0) {
						// after meeting jane
							s += "pass,3\n";
							s3firstdone = true;
						}
					} 
					if (this.get_event_state(18, true) != 1) {
						// after seeing air geome cutsene
						if (this.get_event_state(49,true) & (1 << 8) > 0) {
						//if (this.get_ss("cliff", "aliph_alone", 1) > 0) {
							s += "cliff,3\n";
							s3firstdone = true;
						}
					}
					if (this.get_event_state(19, true) != 1) {
						// after meeting hsaron
						if (this.get_ss("falls", "sharon", 1) > 0) {
							s += "falls,1\n";
							s3firstdone = true;
						}
					}
				}
			}
				
		}
		// push shore things
		if (p == 1) {
			s += "shore,1\n";
			s += "shore,2\n";
		}
		// push CANYON things
		if (p == 2) {
			s += "canyon,1\n";
		}
		// push HILL things
		if (p == 3) {
			s += "hill,1\n";
		}
		// push river things
		if (p == 4) {
			s += "river,1\n";
		}
		// push  woods things
		if (p == 5) {
			s += "woods,1\n";
		}
		// push  forest basin things
		if (p == 6) {
			s += "basin,1\n";
		}
		// push  pass things
		if (p == 7) {
			s += "pass,3\n";
			s += "pass,1\n";
			s += "pass,2\n";
		}
		// push  cliff things
		if (p == 8) {
			s += "cliff,3\n";
			s += "cliff,1\n";
			s += "cliff,2\n";
		}
		// push  falls things
		if (p == 9) {
			s += "falls,1\n";
			s += "falls,2\n";
		}
		
		// IF JUST FINISHED G1_1 THEN DEPEDNGIN ON EVENTS AFTER PUSH THOSE INFOS
		if (i == 29) {
			if (this.get_ss("city_i1", "debrief", 1) != 0) {
				s += "g1_1,1\n";
				s += "g1_1,2\n";
			}
		
			if (this.get_ss("city_i1", "yara", 1) != 0) {
				s += "g1_1,3\n";
				s += "g1_1,4\n";
			}
		
		} else if (i == 30) {
			
			// 32 33 lop/pax ID
			if (this.get_event_state(32,true) == p) {
				s += "g1_2,1\n";
			} else {
				s += "g1_2,2\n";
			}
			
			if (this.get_ss("city_g1_2", "debrief", 1) != 0) {
				s += "g1_2,3\n";
				s += "g1_2,4\n";
			}
			
			if (this.get_ss("city_g1_2", "yara", 1) != 0) {
				s += "g1_2,5\n";
				s += "g1_2,6\n";
			}
		} else if (i == 31) { // i_1 events
			// 32 33 lop/pax ID
			if (this.get_event_state(32,true) == p) {
				s += "g1_2,1\n";
			} else {
				s += "g1_2,2\n";
			}
			
			if (this.get_ss("i_1", "debrief", 1) != 0) {
				s += "i1,1\n";
			}
			
			if (this.get_ss("i_1", "only_humus", 1) != 0) {
				s += "i1,3\n";
			}
			
			if (this.get_ss("i_1", "yara", 1) != 0) {
				s += "i1,4\n";
				s += "i1,5\n";
				s += "i1,6\n";
			}
			
			// Change the entry based on te first piced place
			if (this.get_ss("i_1", "gate_exit", 1) != 0) {
				if (4 == this.get_event_state(34, true)) {
					s += "i1,7\n";
				} else if (5 == this.get_event_state(34, true)) {
					s += "i1,8\n";
				} else if (6 == this.get_event_state(34, true)) {
					s += "i1,9\n";
				} 
			}
		} else if (i == 37) { // post g2_1 events
			s += "g2_1,1\n";
			
			if (this.get_ss("g2_1", "debrief", 1) != 0) {
				s += "g2_1,2\n";
				s += "g2_1,3\n";
				s += "g2_1,4\n";
				s += "g2_1,5\n";
			}
			
			if (this.get_ss("g2_1","hi_res", 1) != 0) {
				s += "g2_1,6\n";
			}
			
			if (this.get_ss("g2_1", "yara", 1) != 0) {
				s += "g2_1,7\n";
				s += "g2_1,8\n";
			}
			
		} else if (i == 38) { // post g2_2
			if (this.get_ss("g2_2", "debrief", 1) != 0) {
				s += "g2_2,1\n";
			}
			
		} else if (i == 39) { // i_2 events, karavold things
			if (this.get_ss("i2", "mayor_sad", 1) != 0) {
				s += "i2,1\n";
				s += "i2,2\n";
			}
			
			if (this.get_ss("i2","yara",1) != 0) {
				s += "i2,3\n";
				s += "i2,4\n";
				s += "kv,1\n";
			}
			
			if (this.get_ss("s3", "kv_contact_wf", 1) != 0) {
				s += "kv,2\n";
			}
			if (this.get_ss("s3", "kv_gotmaps_wf", 1) != 0) {
				s += "kv,3\n";
				s += "kv,4\n";
			}
			
		} else if (i == 43) { // post g3_1
			s += "g3_1,1\n";
		} else if (i == 44) { // post g3_2
			s += "g3_2,1\n";
		} else if (i == 45) { // ending events
			s += "g3_3,1\n";
			if (this.get_ss("s3","last_debrief",1) != 0) {
				s += "ending,1\n";
			}
			
			if (this.get_ss("ending","mayor",1) != 0) {
				s += "ending,2\n";
				s += "ending,3\n";
			}
			
			if (this.get_ss("ending", "radio_end", 1) != 0) {
				s += "ending,4\n";
			}
			
			if (this.get_ss("ending", "final", 1) != 0) {
				s += "ending,5\n";
			}
		}
	}
}
return s;