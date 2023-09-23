	//{ g2_1_checkin
// Checking in at River, Woods or Forest/Basin
// 4,5,6 distinguish where you are (in context values - river, woods, forest/basin)
// g2_2 checkin
// g2_3 checkin
if (!this.child_init) {
	this.child_init = true;
	
	//this._trace("DEBUG 4e_checkin");
	//this.set_event(34, true, 4); //river 
	//this.set_event(34, true, 5); // woods
	//this.set_event(34, true, 6); // basin/forest
	
	//this.set_event(35, true, 4); //river 
	//this.set_event(35, true, 5); // woods
	//this.set_event(35, true, 6); // basin/forest
	
	//this.set_event(37, false);	
	//this.set_event(37, true);	 // g2_1 done
	
	//this.set_event(38, false);	
	//this.set_event(38, true); //  g2_2 done
	
	//this.set_ss("g2_1", "checkin", 1, 0);
	//this.set_ss("g2_1", "checkin", 1, 1);
	//this.set_ss("g2_2", "checkin", 1, 0);
	//this.set_ss("g2_2", "checkin", 1, 1);
	
	// Always set for testing
	//this.set_event(49, true,0);
	//this.set_ss("i_1", "gate_exit", 1, 1);
	//this.set_ss("g2_3", "checkin", 1, 0);
	
	/* END DEBUG STUFF */
	
	if (0 == R.dialogue_manager.get_scene_state_var("i_1", "gate_exit", 1)) {
		this.SCRIPT_OFF = true;
		this._trace("Turn off set 2 checkin bc havent finished I1");
	}
	
	
	// Figure out if g2_1 2 or 3
	// if g2_1, then if at WRONG power plant (since deteremined in earlier dialogue) play g2_1-checkin-5 and move back
	// if g2_2 or g2_3, if this is a NEW power plant then play msg. otherwise do nothing
	// EF.34 - 36 are G2_1 through G2_3 ID
	var g2_1_done = this.get_event_state(37);
	var g2_2_done = this.get_event_state(38);
	this.only_visible_in_editor = true;
	if (g2_2_done) {
		this.s1 = 200;
		this.s2 = 23;
		if (this.get_ss("g2_3", "checkin", 1) == 1) {
			this.SCRIPT_OFF = true;
			return;
		}
		// Don't checkin at the finished two power plants
		if (this.context_values[0] == this.get_event_state(34, true)) {
			this.SCRIPT_OFF = true;
			return;
		}
		if (this.context_values[0] == this.get_event_state(35, true)) {
			this.SCRIPT_OFF = true;
			return;
		}
	} else if (g2_1_done) {
		this.s1 = 100;
		this.s2 = 22;
		if (this.get_ss("g2_2", "checkin", 1) == 1) {
			this.SCRIPT_OFF = true;
			return;
		}
		// Don't checkin at the finished power plants
		if (this.context_values[0] == this.get_event_state(34, true)) {
			this.SCRIPT_OFF = true;
			return;
		}
	} else if (this.get_event_state(34,true) > 0) { // g2_1 chosen
		if (this.context_values[0] == this.get_event_state(34, true)) {
			this.s1 = 0;	 // go ahead to checkin
			this.s2 = 21;
		} else {
			this.s1 = 50; // no checkin - say 'paxton aint here..!!?!?"
		}
		if (this.get_ss("g2_1", "checkin", 1) == 1) {
			this.SCRIPT_OFF = true;
			return;
		}
	} else {
		this.s1 = 50;
	}
	this.has_trigger = true;
	this.make_trigger(this.x , this.y-130, 16, 200);
}

if (this.s1 == 6) {
	if (this.s2 == 21) {
		this._trace("g2_1");
		this.s1 = 3;
	} else if (this.s2 == 22) {
		this._trace("g2_2");
		this.s1 = 103;
	} else if (this.s2 == 23) {
		this._trace("g2_3");
		this.s1 = 203;
	}
	if (R.TEST_STATE.MAP_NAME == "RIVER_1") {
		this._trace("... in river");
		R.easycutscene.start("2f_checkin_earth");
	} else if (R.TEST_STATE.MAP_NAME == "WOODS_1") {
		this._trace("... in woods");
		R.easycutscene.start("2f_checkin_air");
	} else if (R.TEST_STATE.MAP_NAME == "BASIN_1") {
		this._trace("... in basin");
		R.easycutscene.start("2f_checkin_sea");
	}
}


// G2_1 checkin
if (this.s1 == 0 && R.player.overlaps(this.trigger)) {
	this.s1 = 1;
} else if (this.s1 == 1 && this.player_freeze_help()) {
		R.player.energy_bar.dont_move_cutscene_bars = true;
	this.dialogue("g2_1", "checkin", 6,false);
	this.s1 = 2;
} else if (this.s1 == 2) {
	if (this.d_last_yn() == 1) {
		this.s1 = 52;
		this.s3 = 0;
	} else if (this.d_last_yn() == 0) {
		this.s1 = 6;
		this.set_ss("g2_1", "checkin", 1, 1);
		R.player.enter_cutscene();
	}
} else if (this.s1 == 3) {
	if (R.easycutscene.is_off()) {
		this.dialogue("g2_1", "checkin", 7, false);
		this.s1 = 4;
	}
} else if (this.s1 == 4 && this.doff()) {
	this.broadcast_to_children("energize_tick_l");
	this.s1 = 5;
}

if (this.s1 == 50 && R.player.overlaps(this.trigger)) {
	this.s1 = 51;
} else if (this.s1 == 51 && this.player_freeze_help()) {
		this.energy_bar_move_set(true);
	if (this.get_event_state(34, true) == 0) { // if not set yet..(havent chosen)
		this.dialogue("g2_2", "checkin", 4); // shouldnt be here
	} else { 
		this.dialogue("g2_1", "checkin", 5); // paxtons not here..
	}
	this.s1 = 52;
	this.s3 = 50;
} else if (this.s1 == 52 && this.doff()) {
	R.player.enter_main_state();
	R.there_is_a_cutscene_running = false;
	R.player.enter_cutscene();
	R.player.velocity.x = -80;
	R.player.animation.play("wll");
		this.energy_bar_move_set(true);
	this.s1 = 53;
} else if (this.s1 == 53) {
	if (this.trigger.x - R.player.x > 32) {
		R.player.velocity.x = 0;
		R.player.enter_main_state();
		this.s1 = this.s3;
	}
}

if (this.s1 == 100 && R.player.overlaps(this.trigger)) {
	this.s1 = 101;
} else if (this.s1 == 101 && this.player_freeze_help()) {
		R.player.energy_bar.dont_move_cutscene_bars = true;
	this.dialogue("g2_2", "checkin", 0);
	this.s1 = 102;
} else if (this.s1 == 102) {
	if (this.d_last_yn() == 1) {
		this.s1 = 52;
		this.s3 = 100;
	} else if (this.d_last_yn() == 0) {
		this.set_event(35, true, this.context_values[0]);
		this.set_ss("g2_2", "checkin", 1, 1);
		this.s1 = 6;
		R.player.enter_cutscene();
	}
} else if (this.s1 == 103 && R.easycutscene.is_off()) {
	this.dialogue("g2_2", "checkin", 1,false);
	this.s1 = 4;
}

if (this.s1 == 200 && R.player.overlaps(this.trigger)) {
	this.s1 = 201;
} else if (this.s1 == 201 && this.player_freeze_help()) {
	this.dialogue("g2_3", "checkin", 0);
		R.player.energy_bar.dont_move_cutscene_bars = true;
	this.s1 = 202;
} else if (this.s1 == 202) {
	if (this.d_last_yn() == 1) {
		this.s1 = 52;
		this.s3 = 200;
	} else if (this.d_last_yn() == 0) {
		this.set_event(36, true, this.context_values[0]);
		this.set_ss("g2_3", "checkin", 1, 1);
		this.s1 = 6;
		R.player.enter_cutscene();
	}
} else if (this.s1 == 203 && R.easycutscene.is_off()) {
	this.dialogue("g2_3", "checkin", 1,false);
	this.s1 = 4;
}