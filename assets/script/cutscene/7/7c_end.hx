// End of sequence for S3 gauntlets
if (!this.child_init) {
	this.child_init = true;
	this.ignore_parent_dialogue = true;
	//var g2_1_done = this.get_event_state(37);
	// by default teh whole sequence plays bc the golem becomes inacessible after winning
	
	this.has_trigger = true;
	this.make_trigger(this.x - 48, this.y, 96, 32);
	this.state_1 = 0;
	this.height = 64;
	this.width = 80;
	
	this.only_visible_in_editor = true;
	//this.set_event(40, false);
	//this.set_event(43, false);
	//this.set_event(41, false);
	//this.set_event(44, false);
	//this.set_event(42, false);
	//this.set_event(45, false);
	//this.set_ss("s3", "s3_boss_enter", 1, 1);
	//this.nr_LIGHT_received = 20;
	
	// IF didnt enter , play the 'this is the head' dialogue
	if (this.get_event_state(43) == false && this.get_ss("s3", "s3_boss_enter", 1) == 0) {
		//this._trace(123);
		this.s1 = -1;
	} else if (this.event(43) && this.get_ss("s3","s3_g2",1) == 0) {
		//this._trace(123444);
		this.s1 = -1;
	} else if (this.event(44) && this.get_ss("s3","s3_g3",1) == 0) {
		//this._trace(12344);
		this.s1 = -1;
	} else {
		//this._trace(1233);
		this.s1 = 0;
	}
	
	if (R.TEST_STATE.MAP_NAME.indexOf("PASS") != -1) {
		this.s2 = 6; // How many things to do
		this.s3 = 7;
		this.trigger.move(6 * 16, 11 * 16);
		this.set_event(17);
	} else if (R.TEST_STATE.MAP_NAME.indexOf("CLIFF") != -1) {
		this.s2 = 5;
		this.s3 = 8;
		this.trigger.move(5*16,116*16);
		this.set_event(18);
	} else { // falls
		this.s2 = 5;
		this.s3 = 9;
		this.trigger.move(42*16,45*16);
		this.set_event(19);
	}
	
	//this._trace(this.s3);
	//this._trace(this.get_event_state(40,true));
	// Skip if finished already (if the area's ID equals a finished aera)
	
	if (this.get_event_state(40, true) == this.s3 || this.get_event_state(41, true) == this.s3 || this.get_event_state(42, true) == this.s3) {
		this.s1 = 100;
		return;
	}	
	
	
	return;
}


if (this.state_1 < 3) {
	this.state_1 ++;
	if (this.state_1 == 3) {
		this.recv_message("RESTORE_PLANTBLOCK");
	}
}

if (this.s1 == -1) {
	if (R.player.overlaps(this.trigger)) {
		this.s1 = -2;
	}
} else if (this.s1 == -2) {
	if (this.player_freeze_help()) {
		if (this.event(43) && !this.event(44)) { // in geome 2. talk + warp
			this.dialogue("s3", "s3_boss_enter", 3);
			this.set_ss("s3", "s3_g2", 1, 1);
		} else if (this.event(44)) { // in geome 3
			this.dialogue("s3", "s3_boss_enter", 3);
			this.set_ss("s3", "s3_g3", 1, 1);
		} else {
			this.dialogue("s3", "s3_boss_enter", 0);
			this.set_ss("s3", "s3_boss_enter", 1, 1);
		}
		this.s1 = -3;
	}
} else if (this.s1 == -3 && this.doff()) {
	this.t_1 = -1;
	R.player.enter_cutscene();
	R.TEST_STATE.cutscene_handle_signal(0, [0.01]);
	this.s1 = -4;
} else if (this.s1 == -4) {
	if (this.t_1 == -1) {
		if (R.TEST_STATE.cutscene_just_finished(0)) {
			this.t_1 = 0;
		}
	} else {
		this.t_1++;
		//if (this.t_1 == 50) {
			R.player.x = R.player.last.x = this.x -16;
			R.player.y = R.player.last.y = this.y + this.height - R.player.height + 1;
			R.player.velocity.y = 0;
		//}
		
		if (this.t_1 > 60) {
			this.t_1 = 0;
			this.s1 = -5;
			this.camera_to_player();
			R.TEST_STATE.cutscene_handle_signal(2, [0.01]);
		}
	}
} else if (this.s1 == -5 && R.TEST_STATE.cutscene_just_finished(2)) {
	if (this.event(43) == false) {
		this.dialogue("s3", "s3_boss_enter", 2);
	}
	this.s1 = -6;
} else if (this.s1 == -6 && this.doff()) {
	R.player.enter_main_state();
	this.s1 = 0;
}

// s1 = 0: First gauntlet, 100 = 2nd, 200 = 3rd , 300 = this gauntlet finished
if (this.s1 == 0 && this.doff()) {
	if (this.try_to_talk(0, this)) {
		if (this.nr_LIGHT_received >= this.s2) {
			this.s1 = 3;
		} else {
			this.dialogue("s3", "s3_boss_end", 2);
		}
	}
} else if (this.s1 == 1 && this.doff()) {
	
	//this.do_laser_game(0);
	//this.s1 = 2;
	
} else if (this.s1 == 2) {
	//if (this.do_laser_game(1)) {
		//this.do_laser_game(2);
		//
		//this.dialogue("g2_1", "end", 1,false); 
		//this.s1 = 3;
	//}
} else if (this.s1 == 3 && this.doff()) {
	this.s1 = 98;
	this.set_ss("test", "gstate", 1, 0);
	R.player.energy_bar.OFF = true;
	R.player.energy_bar.dont_move_cutscene_bars = true;
	
	
	if (this.get_event_state(44)) {
		this.dialogue("s3", "s3_boss_end", 4);
	} else if (this.get_event_state(43)) {
		this.dialogue("s3", "s3_boss_end", 3);
	} else {
		this.dialogue("s3", "s3_boss_end", 0);
	}
}


if (this.s1 == 98) {
	if (this.doff()) { 
		
			R.player.energy_bar.exit_extremes();
		// TODO: show cutscne based on this.s3 
		
	//public static inline var g3_1_ID:Int = 40; // has 7 through 9 - PASS / CLIFF / FALLS
	//public static inline var g3_2_ID:Int = 41;
	//public static inline var g3_3_ID:Int = 42;
	//public static inline var g3_1_DONE:Int = 43;
	//public static inline var g3_2_DONE:Int = 44;
	//public static inline var g3_3_DONE:Int = 45;
	//public static inline var ID_PASS:Int = 7;
	//public static inline var ID_CLIFF:Int = 8;
	//public static inline var ID_FALLS:Int = 9;
		this._trace("Settings post s3-gauntlet events: 789, Pas Cli Fal");
		this._trace(this.s3);
		if (this.get_event_state(44)) {
			this.set_event(45, true);
			this.set_event(42, true,this.s3);
		} else if (this.get_event_state(43)) {
			this.set_event(44, true);
			this.set_event(41, true, this.s3);
		} else {
			this.set_event(43, true);
			this.set_event(40, true, this.s3);
		}
		// Done so uh... now u can leave. 
		
		this.s1 = 94;
		
		
		R.player.enter_cutscene();
		R.TEST_STATE.cutscene_handle_signal(0, [0.02], true); 
		
		
	}
} else if (this.s1 == 94) {
	if (R.TEST_STATE.cutscene_just_finished(0)) {
		this.s1 = 95;
		
		if (this.s3 == 7) {
			R.easycutscene.activate("3l_earth_bomb");
		} else if (this.s3 == 8) {
			R.easycutscene.activate("3l_air_bomb");
		} else if (this.s3 == 9) {
			R.easycutscene.activate("3l_sea_bomb");
		}
		// start cutscene
	}
} else if (this.s1 == 95) {
	if (R.easycutscene.ping_1) {
		R.TEST_STATE.cutscene_handle_signal(2, [0.03], true); 
		this.s1 = 96;
	}
} else if (this.s1 == 96) {
	if (R.TEST_STATE.cutscene_just_finished(2)) {
		R.easycutscene.ping_1 = false;
		this.s1 = 97;
	}
} else if (this.s1 == 97) {
	if (R.easycutscene.ping_last) {
		// if done, go to 
		this.s1 = 99;
	}
} else if (this.s1 == 99) {
	R.player.enter_main_state();
	this.camera_to_player(true);
	
		if (!R.gauntlet_mode) {
			if (!this.get_event_state(44)) {
				R.TEST_STATE.insta_d = "s3,g7_after,0";
			} else if (!this.get_event_state(45)) {
				R.TEST_STATE.insta_d = "s3,g7_after,1";
			} else {
				R.TEST_STATE.insta_d = "s3,g7_after,2";
			}
		}
		if (this.s3 == 7) {
			this.change_map("PASS_2", 142, 48, true);
		} else if (this.s3 == 8) {
			this.change_map("CLIFF_2", 87, 14, true);
		} else {
			this.change_map("FALLS_2", 134, 45, true);
		}
		
		
		if (R.gauntlet_mode) {
			this.change_map("GM_1", 106, 13, true);
		}
		//this.broadcast_to_children("energize_d");
		this.s1 = 100;
}