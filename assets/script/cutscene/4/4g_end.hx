// End of sequence for S2 gauntlets
if (!this.child_init) {
	this.child_init = true;
	this.s1 = -1;
	// 3h_nature_blocker needs to update
	
	// DEBUG RIVER for G2_1 (unset this and every one will paly 3 in a row)
	//this._trace("4g end debug");
	//this.set_event(34, true, 4); // So dialogue shows name
	//this.nr_LIGHT_received = 10; // Skip the boss part
	
	//this.set_event(37, false);
	//this.set_event(37, true);
	//this.set_event(38, false);
	
	// DEBUG woods G2_2
	//this.set_event(35, true, 5); // So dialogue shows name
	//this.set_event(37, true);
	
	// Debug basin g2_3
	//this.set_event(36, true, 6); // So dialogue shows name
	//this.set_event(38, true);
	//this.nr_LIGHT_received = 10;
	
	//public static inline var g2_1_DONE:Int = 37;
	//public static inline var g2_2_DONE:Int = 38;
	//public static inline var g2_3_DONE:Int = 39;
	// Play different event if this is gauntlet 1, 2 or 3.
	this.ignore_parent_dialogue = true;
	var g2_1_done = this.get_event_state(37);
	var g2_2_done= this.get_event_state(38);
	var ef_val = 0;
	if (g2_2_done) {
		ef_val = 36;
		this.s1 = 200;
	} else if (g2_1_done) {
		ef_val = 35;
		this.s1 = 100;
	} else {
		ef_val = 34;
		this.s1 = 0;
	}
	
	// s2 = # of energy to bedone
	// s3 = where to warp out to later
	//if (this.get_event_state(ef_val, true) == 4) {
	this.state_1 = 0;
	if (R.TEST_STATE.MAP_NAME.indexOf("RIVER") != -1) {
		this.s3 = 1;
		this.s2 = 4; // 2015 6 2
	} else if (R.TEST_STATE.MAP_NAME.indexOf("WOODS") != -1) {
	//} else if (this.get_event_state(ef_val, true) == 5) {
		this.s3 = 2;
		this.s2 = 5;
	} else {
		this.s3 = 3;
		this.s2 = 6; // 2015 10 28
	}
}

//this._trace(this.s1);

if (this.state_1 < 3) {
	this.state_1 ++;
	if (this.state_1 == 3) {
		this.recv_message("RESTORE_PLANTBLOCK");
	}
}

// s1 = 0: First gauntlet, 100 = 2nd, 200 = 3rd , 300 = this gauntlet finished
if (this.s1 == 0) {
	if (this.try_to_talk(0, this)) {
		R.player.animation.play("irn");
		R.player.facing = 0x10;
		if (this.nr_LIGHT_received >= this.s2) {
			this.s1 = 1;
			this.set_event(37, true); //g2_1_done
			this.checkpoint_off();
			this.t_1 = 0;
			R.player.energy_bar.dont_move_cutscene_bars = true;
			this.dialogue("nature", "s1_lasergame", 3, false);
			
		} else {
			this.dialogue("g2_1", "end", 0);
		}
	}
} else if (this.s1 == 1 && this.doff()) {
	
	this.do_laser_game(0);
	
		R.player.energy_bar.exit_extremes();
	this.s1 = 2;
	
} else if (this.s1 == 2) {
	if (this.do_laser_game(1)) {
		this.do_laser_game(2);
		
		this.dialogue("g2_1", "end", 1,false); 
		this.s1 = 3;
	}
} else if (this.s1 == 3 && this.doff()) {
	// play sound of callingW
	this.t_1++;
	if (this.t_1 > 30) {
		this.s1 = 98;
		
		//this.dialogue("g2_1", "end", 2); 
		this.dialogue("g2_1", "endgas", 0); 
		
		this.energy_bar_move_set(false);
	}
}


// Block for warping out (works for any gauntlet int he sequence)
if (this.s1 == 98 && this.doff()) {
	R.player.enter_cutscene();
		R.player.energy_bar.OFF = true;
	this.t_1 ++;
	if (this.t_1 > 60) {
	// cutsceneo
		if (this.s3 == 1) {
			R.easycutscene.activate("2g_earth",null,false,false,true);
		} else if (this.s3 == 2) {			
			R.easycutscene.activate("2g_air",null,false,false,true);
		} else {
			R.easycutscene.activate("2g_sea",null,false,false,true);
		}
		this.s1 = 99;
	}
} else if (this.s1 == 99 && R.easycutscene.is_off()) {
	this.s1 = 990;
} else if (this.s1 == 990) {
	this.energy_bar_move_set(true);
	if (R.event_state[39] == 1) {
		this.dialogue("g2_3", "end", 1);
	} else if (R.event_state[38] == 1) {
		this.dialogue("g2_2", "end", 0);
	} else {
		this.dialogue("g2_1", "end", 2); 
	}
	this.s1 = 300;
} else if (this.s1 == 300) {
	if (this.doff()) { 
		//warp somewhere
		
		R.player.energy_bar.OFF = false;
		R.player.enter_main_state();
		this.set_ss("test", "gstate", 1,0);
		if (this.s3 == 1) {
			this.set_event(15, true); //river done
			//this._trace("RIVERDEBUG!");
			//this.set_event(35, true, 5);
			this.change_map("MAP1", 953, 1390);
			//this.change_map(this.get_map("river_g_entrance"), 206, 56, true);
		} else if (this.s3 == 2) { 
			this.set_event(14, true); //woods done
			//this._trace("WOODS DEBUG!");
			//this.set_event(36, true, 6);
			this.change_map("MAP1", 1105, 1891);
			//this.change_map(this.get_map("woods_g_entrance"), 113,21, true);
		} else if (this.s3 == 3) {
			//this._trace("BASIN!");
			this.set_event(16, true); //forest_done
			this.change_map("MAP1", 109*16, 154*16);
			//this.change_map("BASIN_3", 46, 57, true);
		}
		if (R.gauntlet_mode) {
			this.change_map("GM_1", 54, 13, true);
		}
		this.s1 = 301;
	}
} else if (this.s1 == 301) {
	
}




// End of g2_2
if (this.s1 == 100) {
	if (this.try_to_talk(0, this)) {
		if (this.nr_LIGHT_received >= this.s2) {
			this.s1 = 101;
			this.set_event(38, true); //g2_2_done
			// end gauntlet 
			this.checkpoint_off();
			R.player.energy_bar.dont_move_cutscene_bars = true;
			this.dialogue("nature", "s1_lasergame", 4, false);
		} else {
			this.dialogue("g2_2", "end", 2);
		}
	}
} else if (this.s1 == 101) {
	if (this.doff()) {
		this.do_laser_game(0);
		
		R.player.energy_bar.exit_extremes();
		this.s1 = 102;
	}
} else if (this.s1 == 102) {
	if (this.do_laser_game(1)) {
		this.do_laser_game(2);
		//this.dialogue("g2_2", "end", 0);
		this.dialogue("g2_1", "endgas", 0); 

		this.energy_bar_move_set(false);
		
		this.s1 = 98;
	}
}

// end of g2_3
if (this.s1 == 200) {
	if (this.try_to_talk(0, this)) {
		if (this.nr_LIGHT_received >= this.s2) {
			this.s1 = 201;
			this.set_event(39, true); //g2_3_done
			// end gauntlet 
			this.checkpoint_off();
			R.player.energy_bar.dont_move_cutscene_bars = true;
			this.dialogue("nature", "s1_lasergame", 5, false);
		} else {
			this.dialogue("g2_3", "end", 0);
		}
	}
} else if (this.s1 == 201) {
	if (this.doff()) {
		this.do_laser_game(0);
		
		R.player.energy_bar.exit_extremes();
		this.s1 = 202;
	}
} else if (this.s1 == 202) {
	if (this.do_laser_game(1)) {
	//if (true) {
		this.do_laser_game(2);
		//this.dialogue("g2_3", "end", 1);
		this.dialogue("g2_1", "endgas", 0); 

		this.energy_bar_move_set(false);
		this.s1 = 98;
	}
}