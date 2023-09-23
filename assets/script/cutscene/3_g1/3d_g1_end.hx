// End of sequence for G1 gauntlets
if (!this.child_init) {
	this.child_init = true;
	this.s1 = -1;
	
	// s2 = # of energy to bedone
	if (R.TEST_STATE.MAP_NAME.indexOf("SHORE") != -1) {
		this.s3 = 1;
		this.s2 = 5;
	} else if (R.TEST_STATE.MAP_NAME.indexOf("CANYON") != -1) {
		this.s3 = 2;
		this.s2 = 6;
	} else {
		this.s3 = 3;
		this.s2 = 6;
	}
	
	// DEBUG SHORE for G1_1
	//this.set_event(26, true, 1); 
	//this.set_event(26, true, 2); 
	
	//this.set_event(26, true, 3); //hill 
	//this.set_event(29, false);
	//this.nr_LIGHT_received = 999; // Skip the boss part
	
	
	// DEBUG
	//this.set_event(29);
	//this.set_event(30,false);
	//this.set_event(31,false);
	//
	//this._trace("DEBUG g1_2 end: Paxton at hill, Lopez at shore");
	//this.set_event(26, true, 2);
	//this.set_event(27, true, 1); // what is g1 2
	//this.set_event(28, true, 3); // g1 3
	//this.set_event(32, true, 1); // where did find lopez
	//this.set_event(33, true, 3); // where did find paxton
	//this.nr_LIGHT_received = 999; // Skip the boss part
	
	//this._trace("DEBUG g1_3 end: pax still at HILL");
	//this.set_event(29);
	//this.set_event(30);
	//this.set_event(31,false);
	//this.set_event(26, true, 2);
	//this.set_event(27, true, 1); // what is g1 2
	//this.set_event(28, true, 3); // g1 3
	//this.set_event(32, true, 1); // where did find lopez
	//this.set_event(33, true, 3); // where did find paxton
	//this.nr_LIGHT_received = 999; // Skip the boss part	
	
	this.only_visible_in_editor = true;
	
	
	//public static inline var g1_1_DONE:Int = 29;
	// Play different event if this is gauntlet 1, 2 or 3.
	var g1_1_done = this.get_event_state(29);
	var g1_2_done = this.get_event_state(30);
	
	this.state_1 = 0;
	if (g1_2_done) {
		this.s1 = 200;
	} else if (g1_1_done) {
		this.s1 = 100;
	} else {
		this.s1 = 0;
		return;
	}
	
	
}

if (this.state_1 < 3) {
	this.state_1 ++;
	if (this.state_1 == 3) {
		this.recv_message("RESTORE_PLANTBLOCK");
	}
}

// s1 = 0: First gauntlet, 100 = 2nd, 200 = 3rd , 300 = this gauntlet finished
if (this.s1 == 0) {
	if (this.try_to_talk(0, this)) {
		if (this.nr_LIGHT_received >= this.s2) {
			this.s1 = -69;
			this.set_event(29, true); //g1_1_done
			this.checkpoint_off();
			R.player.energy_bar.dont_move_cutscene_bars = true;
			this.dialogue("nature", "s1_lasergame", 0, false);
		} else {
			this.dialogue("nature", "g1_1_end", 6);
		}
	}
} else if (this.s1 == -69 && this.doff()) {
		this.do_laser_game(0);
				
		R.player.energy_bar.exit_extremes();
		this.s1 = -70;
} else if (this.s1 == -70) {
	if (this.do_laser_game(1)) {
		this.do_laser_game(2);
		this.s1 = -1;
		this.dialogue("nature", "g1_1_end", 9,false);
	}
} else if (this.s1 == -1) {
	if (this.doff()) {
		// something something sounds
		this.dialogue("nature", "g1_1_end", 0, false);
		this.energy_bar_move_set(true);
		this.s1 = 2;
	}
} else if (this.s1 == 2) {
	if (this.doff()) {
		R.player.enter_cutscene();
		R.TEST_STATE.cutscene_handle_signal(0, [0.005]);
		this.s1 = 3;
	}
} else if (this.s1 == 3 && R.TEST_STATE.cutscene_just_finished(0)) {
	R.player.enter_main_state();
	this.dialogue("nature", "g1_1_end", 10);
	if (R.PREVIEW_BUILD_ON) {
		this.s1 = 4;
	} else {
		this.s1 = 1;
	}
} else if (this.s1 == 4 && this.doff()) {
	this.dialogue("nature", "g1_1_end", 12);
	this.s1 = 1;
} else if (this.s1 == 1 && this.doff()) {
		//warp somewhere
			R.there_is_a_cutscene_running = false;
		if (this.s3 == 1) {
			this.set_event(9, true); //shore_done
			R.player.pause_toggle(false);
			//this.change_map("SHORE_2", 141, 9, true);
			this.change_map("MAP1", 2075, 700);
			this.set_ss("test", "gstate", 1,0);
		} else if (this.s3 == 2) { 
			this.set_ss("canyon", "moonderful_first", 1, 0); // so moonderful dialogue changes. I did something weird so this needs to be set to 0 instead of the usual 1
			this.set_event(12, true); // canyon_done
			//this.change_map("CANYON_3", 108, 18, true);
			R.player.pause_toggle(false);
			this.change_map("MAP1", 1480,2105);
			this.set_ss("test", "gstate", 1,0);
		} else if (this.s3 == 3) {
			this.set_event(13, true); //hill_done
			//this.change_map("HILL_4", 209, 29, true);
			R.player.pause_toggle(false);
			this.change_map("MAP1", 1272, 855);
			this.set_ss("test", "gstate", 1,0);
		}
		
		if (R.gauntlet_mode) {
			this.change_map("GM_1", 28, 13, true);
		}
		this.s1 = 5;
}


// End of g1_2
if (this.s1 == 100) {
	if (this.try_to_talk(0, this)) {
		if (this.nr_LIGHT_received >= this.s2) {
			this.s1 = 101;
			this.set_event(30, true); //g1_2_done
			this.checkpoint_off();
			R.player.energy_bar.dont_move_cutscene_bars = true;
			this.dialogue("nature", "s1_lasergame", 1, false);
			
		} else {
			this.dialogue("nature", "g1_1_end", 6); // i need to fix
		}
	}
} else if (this.s1 == 101 && this.doff()) {
		this.do_laser_game(0);
				
		R.player.energy_bar.exit_extremes();
		this.s1 = 102;
} else if (this.s1 == 102) {
	if (this.do_laser_game(1)) {
		this.do_laser_game(2);
		this.s1 = 2;
		// If it's lopez
		if (this.get_event(32, true) == this.get_event(27, true)) {
			this.dialogue("nature_g1_2", "lopez_end", 0,false);
		} else {
			this.dialogue("nature_g1_2", "paxton_end", 0,false);
		}
			this.energy_bar_move_set(true);
	}
}

if (this.s1 == 200) {
	if (this.try_to_talk(0, this)) {
		if (this.nr_LIGHT_received >= this.s2) {
			this.set_event(31, true); //g1_3_done
			this.checkpoint_off();
			this.s1 = 201;
			R.player.energy_bar.dont_move_cutscene_bars = true;
			this.dialogue("nature", "s1_lasergame", 2, false);
		} else {
			this.dialogue("nature", "g1_1_end", 6); // i need to fix
		}
	}
} else if (this.s1 == 201 && this.doff()) {
	this.do_laser_game(0);
			
		R.player.energy_bar.exit_extremes();
	this.s1 = 202;
} else if (this.s1 == 202) {
	if (this.do_laser_game(1)) {
		this.do_laser_game(2);
		// If it's lopez
		if (this.get_event(32, true) == this.get_event(28, true)) {
			this.dialogue("nature_g1_2", "lopez_end", 0,false);
		} else {
			this.dialogue("nature_g1_2", "paxton_end", 0,false);
		}
			this.energy_bar_move_set(true);
		this.s1 = 2;
	}
}

if (this.s1 == 300) {
	if (this.try_to_talk(0, this)) {
		this.dialogue("nature", "g1_1_end", 7);
	}
}