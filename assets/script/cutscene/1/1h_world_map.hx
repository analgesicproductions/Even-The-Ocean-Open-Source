if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	if (R.gs1 == 245) { // Set by 8f_flood
		this.SCRIPT_OFF = true;
		return;
	}
	
	
	// TODO..
	R.ok_doors = "BRIDGE_1,BRIDGE_2,BRIDGE_HILL,BRIDGE_BASIN,BRIDGE_RIVER";
	
	
	//this._trace("1hWORLDMAP DEBUG Paxton at HILL, Canyon first, G1_2");
	//this.set_event(29); 
	//this.set_event(30);
	//this.set_event(32, true, 1);
	//this.set_event(33, true, 3);
	//this.set_event(26, true, 2);
	//this.set_event(27, true, 3);
	//this.set_event(10);
	//this.set_event(12);
	//
	if (R.inventory.is_item_found(30)) {
		this._trace("map1 blocker off bc have postgame transmitter 30");
		this.SCRIPT_OFF = true;
		return;
	}
	// DEBUG: go to I1 debrief
	//this._trace("DEBUG 1h_world_map");
	//this.set_event(31, true);
	
	// DEBUG: go to G1_1 debrief
	//this._trace("DEBUG 1h_world_map");
	//this.set_event(29, true);
	//this.set_scene_state("city_i1", "debrief", 1, 0);
	
	// DEBUG: after intro console
	//this._trace("DEBUG 1h_world_map introconsole");
	//this.set_ss("intro", "map", 1, 0);
	//this.set_event(23);
	
	this.s1 = -1;
	
	// TODO During rain (only allow WF)
	//this._trace("DEBUG 1h_world_map: THE RAIN");
	//this.set_ss("s3", "last_debrief", 1, 1);
	//this.set_ss("s3", "first_sleep", 1, 1);
	
	if (this.event(50)) {
		this._trace("MAP1 blocker off bc ending done");
		this.SCRIPT_OFF = true;
		return;
	}
	
	if (1 == this.get_ss("s3", "last_debrief", 1)) {
		this.s1 = 0;
		this.s2 = 2;
		this.s3 = 1;
		R.ignore_door = true;
		return;
	}
	
	//this._trace(this.get_event(39));
	//this._trace(this.get_event(39));
	// after g2_3, before I2 events
	if (this.get_event(39) && 0 == this.get_ss("i2", "cart_init", 1)) {
		this.s1 = 0;
		this.s2 = 2;	
		this.s3 = 1;
		R.ignore_door = true;
		return;
	}
	
	// Check after G2_2 before debrief
	if (this.get_event(38) && 0 == this.get_ss("g2_2", "debrief", 1)) {
		this.s1 = 0;
		this.s2 = 1;
		this.s3 = 1;
		R.ignore_door = true;
		return;
	}
	
	// Check after G2_1 before debrief
	if (this.get_event(37) && 0 == this.get_ss("g2_1", "debrief", 1)) {
		this.s1 = 0;
		this.s2 = 1;
		this.s3 = 1;
		R.ignore_door = true;
		return;
	}
	
	// after g1_3, b4 debrief
	
	if (this.get_event(31) && 0 == this.get_ss("i_1", "debrief", 1)) {
		this._trace("World Map Locked: Need to see I_1 Debrief");
		this.s1 = 0;
		this.s2 = 1;
		this.s3 = 1;
		R.ignore_door = true;
		return;
	}
	
	
	//this._trace("DEBUG 1h_world_map: paxton - canyon 2nd, hill 1st");
	//this.set_event(30);
	//this.set_event(32, true, 1);
	//this.set_event(33, true, 2);
	//this.set_event(27, true, 2);
	//this.set_event(28, true, 1);
	//this.set_ss("city_g1_2", "debrief", 1, 0);
	
	// Check after G1_2 before debrief
	if (this.get_event(30) && 0 == this.get_ss("city_g1_2", "debrief", 1)) {
		

		R.song_helper.permanent_song_name = "themesong";
		this._trace("World Map Locked: Need to see post g1_2 debrief");
		this.s1 = 0;
		this.s2 = 1;
		this.s3 = 1;
		R.ignore_door = true;
		return;
	}
	
	
	// Check for after G1_1: Warp to train (which warps to mayor) 
	if (this.get_event(29) && 1 != this.get_scene_state("city_i1", "debrief", 1)) {
		
		R.song_helper.permanent_song_name = "themesong";
		this._trace("World Map Locked: Need to see post g1_1 debrief");
		this.s1 = 0;
		this.s2 = 1;
		this.s3 = 1;
		R.ignore_door = true;
		return;
	}

	// Otherwise, if we are after the intro but before starting g1_1...
	if (this.get_scene_state("intro", "map", 1) == 1) {
		return;
	// If not, play intro song and only allow WF entry
	} else {
		//public static inline var INTRO_console_scene_done:Int = 23;
		if (this.get_event(23)) {
			R.ok_doors = ""; // Can't go anywhere but WF
			this.s1 = 0;
			this.play_music("map_intro",false);
			R.ignore_door = true;
		} else {
			this.SCRIPT_OFF = true;
			return;
		}
	}
}


if (this.s1 == 0) {
	
	if (this.dialogue_is_on()) {
		R.attempted_door = "";
		return;
	}
	
	if (R.attempted_door != null && R.attempted_door.length > 1) {
		if (R.attempted_door == "WF_ENTRY" || R.attempted_door == "NPC_CITY" || R.attempted_door == "WF_LO_0") {
			if (this.s2 >= 2 && this.s2 <= 5) {
				this.change_map("WF_LO_0", 74, 14, true);
			} else {
				if (this.s3 == 1) {
					
					this.change_map("WF_GOV_MAYOR", 0, 0, true);
				} else {
					/* AFTER ROUGE */
					
					//this.play_music("aliph_house_night",false);
					//R.song_helper.stop_song_changes = true;
					//this.change_map(this.get_map("train_to_apex"), 0, 0, true);
					this.change_map("WF_ALIPH", 15, 0, true);
					this.set_scene_state("intro", "map", 1, 1);
				}
			}
		} else {
			// Other doors, during endingg sequence.
			if (this.s2 == 2) {
				//this._trace(this.s2);
				//if (R.attempted_door == "transition place ok") {
					//if (R.player.x < 0 && false) { // TODO;... overlaps a certain door.. hack lol
						//this.change_map("transitionplace", 1, 1, true);
					//}
				//}
				//R.attempted_door = "";
				//return;
			} 
			
			// wrong door picked, play "cant go anywerE" or whatever
			if (this.s2 == 1) {
				this.dialogue("intro", "map", 0);
			} else if (this.s2 == 2) {
				this.dialogue("s3", "no_wf", 1);
			} else if (this.s2 == 5) {
				this.dialogue("s3", "no_wf", 1);
			} else {
				this.dialogue("intro", "map", 0);
			}
		}
		
		R.attempted_door = "";
	}
}