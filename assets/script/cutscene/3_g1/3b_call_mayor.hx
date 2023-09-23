//
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	
	// DEBUG: G1_1 begin
	//this._trace("DEBUG g1_1 3b_call_mayor");
	//this.set_event(49, false);
	//this.set_scene_state("city", "intro_yara", 1, 1);
	//this.set_event(26, false);
	//this.set_event(27, false);
	//this.set_event(28, false);
	
	//  DEBUG: G1_2 beginning. shore beat first
	//this._trace("g1_2 3b_call_mayor DEBUBG");
	
	
	//this.set_ss("city", "intro_yara", 1, 1);
	//this.set_ss("nature", "g1_1_call_mayor", 1, 1);
	
	//this.set_event(9); 
	//this.set_event(26, true, 1);
	//this.set_event(27, true, 0);
	//this.set_event(29, true);
	//this.set_event(32, true, 3);
	//this.set_event(33, true, 2);
	//this.set_scene_state("city_i1", "debrief", 1, 1);
	//this.set_scene_state("nature_g1_2", "checkin", 1, 0);
	
	this.s1 = -1;
	

	// check if this area already done, so that during G1_2,  if you go to g1_1, then the g1_2 sequence doesnt fire
	var area_id = -1;
	if (R.TEST_STATE.MAP_NAME.indexOf("SHORE") != -1) {
		area_id = 1;
	} else if (R.TEST_STATE.MAP_NAME.indexOf("CANYON") != -1) {
		area_id = 2;
	} else {
		area_id = 3;
	}
	if (this.get_event(26, true) == area_id || this.get_event(27, true) == area_id || (this.get_ss("nature_g1_3","checkin",1) == 1 && this.get_event(28, true) == area_id)) {
		this.SCRIPT_OFF = true;
		return;
	}
	
	
	if (this.get_scene_state("city", "intro_yara", 1) == 1 && this.get_event(29) == false && this.get_scene_state("nature", "g1_1_call_mayor", 1) == 0) {
		this.s1 = 0;
	} else if (this.get_scene_state("city_i1", "debrief", 1) == 1 && this.get_event(30) == false && this.get_scene_state("nature_g1_2", "checkin", 1) == 0) {
		this.s1 = 100;
	} else if (this.get_event(30) && this.get_scene_state("nature_g1_3", "checkin", 1) == 0) {
		this.s1 = 100;
		this.s3 = 1;
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	
	
	this.has_trigger = true;
	this.make_trigger(this.x, this.y, 20, 200);
}


if (this.s1 == 0) {
	if (this.trigger.overlaps(R.player)) {
		this.s1 = 1;
	}
} else if (this.s1 == 1) {
	if (this.player_freeze_help()) {
		R.player.energy_bar.dont_move_cutscene_bars = true;
		this.dialogue("nature", "g1_1_call_mayor", 0);
		this.s1 = 2;
	}
} else if (this.s1 == 2) {
	if (this.d_last_yn() > -1) {
		
	//public static inline var g1_lopez_ID:Int = 32; // auto assigned after #1 (Lopez)
	//public static inline var g1_paxton_ID:Int = 33; // auto assigned after g1_1 picked
		// Call mayor - set this area to g1_1 and set states
		if (this.d_last_yn() == 0) {
			this.s1 = 3;
			if (R.TEST_STATE.MAP_NAME.indexOf("SHORE") != -1) {
				this._trace("shore");
				this.set_event(26, true, 1);
				// Lopez -> Hill Pax -> Canyon
				this.set_event(32, true, 3);
				this.set_event(33, true, 2);
			} else if (R.TEST_STATE.MAP_NAME.indexOf("CANYON") != -1) {
				this._trace("canyon");
				this.set_event(26, true, 2);
				// Lopez -> Shore Pax -> Hill
				this.set_event(32, true, 1);
				this.set_event(33, true, 3);
			} else {
				this._trace("hill");
				this.set_event(26, true, 3);
				// Lopez -> Shore Pax -> Canyon
				this.set_event(32, true, 1);
				this.set_event(33, true, 2);
			}
			this.set_scene_state("nature", "g1_1_call_mayor", 1, 1);
		} else {
			this.s1 = 10;
		}
	}
} else if (this.s1 == 3) {
	if (this.doff()) {
		this.s1 = 4;
		var s = this.get_event_state(26, true);
		if (s == 1) {
			this.dialogue("nature", "g1_1_call_mayor", 7,false);
		} else if (s == 2) {
			this.dialogue("nature", "g1_1_call_mayor", 8,false);
		} else if (s == 3) {
			this.dialogue("nature", "g1_1_call_mayor", 9,false);
		}
		
	}
} else if (this.s1 == 4 && this.doff()) {
	this.broadcast_to_children("energize_tick_l");
	this.s1 = 5;
}


// Go somewhere else
if (this.s1 == 10) {
	
	if (this.doff()) {
		
		R.player.enter_main_state();
		R.there_is_a_cutscene_running = false;
		R.player.enter_cutscene();
		R.player.velocity.x = -80;
		R.player.animation.play("wll");
		this.energy_bar_move_set(true);
		this.s1 = 11;
	}
} else if (this.s1 == 11) {
	
	if (R.player.x < this.trigger.x - 32) {
		R.player.velocity.x = 0;
		R.player.animation.play("iln");
		R.player.facing = 0x0001;
		if (this.doff()) {
			this.s1 = 0;
			if (this.s2 == 1) {
				this.s1 = 100;
			}
			R.player.enter_main_state();
		}
	}
}


// G1_2 and G1_3 checkin. Set the variable for whatever this is after confirming
if (this.s1 == 100) {
	if (this.trigger.overlaps(R.player)) {
		this.s1 = 101;
	}
} else if (this.s1 == 101) {
	if (this.player_freeze_help()) {
		R.player.energy_bar.dont_move_cutscene_bars = true;
		if (this.s3 == 1) {
			this.dialogue("nature_g1_3", "checkin", 0,false);
		} else {
			this.dialogue("nature_g1_2", "checkin", 0,false);
		}
		this.s1 = 102;
	}
} else if (this.s1 == 102) {
	if (this.d_last_yn() > -1) {
		// Call mayor - set this area to G1_2
		if (this.d_last_yn() == 0) {
			this.s1 = 3;
			var e = 27;
			if (this.s3 == 1) {
				e = 28;
			}
			
			// Need to set the ID of the 3rd gauntlet here so that the 2nd debriefing is correct
			if (e == 27) {
				
					
				if (R.TEST_STATE.MAP_NAME.indexOf("SHORE") != -1) {
					this.set_event(e, true, 1);
				} else if (R.TEST_STATE.MAP_NAME.indexOf("CANYON") != -1) {
					this.set_event(e, true, 2);
				} else {
					this.set_event(e, true, 3);
				}
				
				if (this.event(9)) {
					if (this.get_event(27, true) == 2) { // finished shore, currently at canyon, set 3rd to hill
						this.set_event(28, true,3);
					} else  { // currently at hill, set to canyon
						this.set_event(28, true,2);
					}
				} else if (this.event(12)) { // did canyon
					if (this.get_event(27, true) == 1) {  // at shore, set hill
						this.set_event(28, true,3);
					} else  {
						this.set_event(28, true,1); // at hill, set shore
					}
				} else { // did hill
					if (this.get_event(27, true) == 1) {  // at shore, set to canyon
						this.set_event(28, true,2);
					} else  {
						this.set_event(28, true,1); // at canyon, set to shore
					}
				}
			}
			
			if (this.s3 == 1) {
				this.set_scene_state("nature_g1_3", "checkin", 1, 1);
			} else {
				this.set_scene_state("nature_g1_2", "checkin", 1, 1);
			}
			this.s1 = 103;
		} else {
			this.s1 = 10;
			this.s2 = 1;
		}
	}
} else if (this.s1 == 103 && this.doff()) {
	this.broadcast_to_children("energize_tick_l");

	this.s1 = 5;
}
