if (!this.child_init) {
	this.child_init = true;
	this.s1 = 0;
	this.s2 = 0;
	
	// 40 to 42 is the IDS (values: 7 8 9 pass cliff falls)
	//public static inline var g3_1_DONE:Int = 43;
	//public static inline var g3_2_DONE:Int = 44;
	//public static inline var g3_3_DONE:Int = 45;
	//
	//this._trace("DEBUG IN 7e_final_debrief: FIRST");
	//this.play_music("old_city_radio");
	//this.set_event(43, true);
	//
	//this._trace("DEBUG IN 7e_final_debrief: SECOND");
	//this.set_ss("s3", "debrief", 1, 1);
	//this.set_event(44, true);
	////
	//this._trace("DEBUG IN 7e_final_debrief: FINAL");
	//this.set_ss("s3", "debrief_2", 1, 1);
	//this.set_event(45, true);
	//
	//this._trace("DEBUG IN 7e_final_debrief: Golem order: PASS CLIFF FALLS");
	//this.set_event(40, true, 7);
	//this.set_event(41, true, 8);
	//this.set_event(42, true, 9);
//

	// First 3 conditionals are for the debrief scenes, otherwise there's more lgic to figure out where you are in the powereing-on-and-finding-maps scene when you first enter WF
	if (this.get_event(45, true) == 1 && this.get_ss("s3", "last_debrief", 1) == 0) {
		this.broadcast_to_children("energize");
	} else if (this.get_event(44, true) == 1 && this.get_ss("s3", "debrief_2", 1) == 0) {
		this.broadcast_to_children("energize");
	}else if (this.get_event(43, true) == 1 && this.get_ss("s3", "debrief", 1) == 0) {
		this.broadcast_to_children("energize");
	} else {
		this.s2 = 1;
	}
	this.animation.play("on", true);
}

if (this.s2 == 1) {
	
	if (this.s1 == 0) {
		
		if (this.get_ss("s3", "kv_gotmaps_wf", 1) == 1) {
			// Console (idle msg) (All non special states stay here)			
			this.s1 = 5;
			this.broadcast_to_children("energize");
		} else if (this.get_ss("s3", "kv_contact_wf", 1) == 1) {
			// Idle messageuntil you get items
			this.s1 = 4;
			this.broadcast_to_children("energize");
		} else if (this.get_ss("s3", "kv_console", 1) == 1) {
			// Console (contact WF) --> Opens raisewall to office	
			this.s1 = 2;
		} else {
			this.animation.play("off", true);
			this.s1 = 1;
		}
		
	} else if (this.s1 == 1) {
		
		if (!this.doff()) {
			return;
		}
		// Console
		if (this.try_to_talk(0, null, false	)) {
			this.dialogue("s3", "kv_console", 0);
			this.s1 = 100;
		}
	} else if (this.s1 == 100 && this.doff()) {
		this.set_ss("s3", "kv_console", 1, 1);
	// Raise the wall
		this.play_sound("raisewall.wav");
		this.animation.play("on", true);
		this.broadcast_to_children("energize");
		this.s1 = 3;
		this.dialogue("s3", "kv_contact_wf", 0);
	// Tell WF u got to KV
	} else if (this.s1 == 3) {
		if (this.doff()) {
			this.set_ss("s3", "kv_contact_wf", 1, 1);
			this.broadcast_to_children("energize");
			this.s1 = 4;
		}
	// If have maps, tell WF
	} else if (this.s1 == 4) {
		
		if (!this.doff()) {
			return;
		}
		if (this.try_to_talk(0, null, true)) {
			if (R.inventory.is_item_found(19)) {
				this.dialogue("s3", "kv_gotmaps_wf", 0);
				this.s1 = 5;
				this.set_ss("s3", "kv_gotmaps_wf", 1,1);
				this.set_ss("s3", "first_sleep", 1, 1); // idk if neededs
			} else {
				if (1 == this.get_ss("s3", "last_debrief", 1)) {
					this.dialogue("s3", "kv_console", 2);
				} else {
					this.dialogue("s3", "kv_console", 1);
				}
			}
		}
	// Idle console dialgue
	} else if (this.s1 == 5) {
		if (!this.doff()) {
			return;
		}
		if (this.try_to_talk(0, null, true)) {
			if (1 == this.get_ss("s3", "last_debrief", 1)) {
				this.dialogue("s3", "kv_console", 2);
			} else {
				this.dialogue("s3", "kv_console", 1);
			}
		}
	}
	 
	return;
}

// Do stuff
if (this.s1 == 0) {
	if (this.try_to_talk(0, null, true)) {
		if (this.get_event(45, true) == 1 && this.get_ss("s3","last_debrief",1) == 0) {
			this.play_music("null",false);
			this.set_ss("s3", "last_debrief", 1, 1);
			this.dialogue("s3", "last_debrief", 0);
			//R.song_helper.permanent_song_name = "rain";
			//this.play_music("rain",false);
			this.t_1 = 0;
			this.s1 = 2;
			return;
		} else if (this.get_event(44, true) == 1 && this.get_ss("s3", "debrief_2", 1) == 0) {
			this.set_ss("s3", "debrief_2", 1, 1);
			this.dialogue("s3", "debrief_2", 0);
		}else if (this.get_event(43, true) == 1 && this.get_ss("s3", "debrief", 1) == 0) {
			this.set_ss("s3", "debrief", 1, 1);
			this.dialogue("s3", "debrief", 0);
		} else {
			this.dialogue("s3", "no_debrief", 0);
		}
		this.s1 = 1;
	}
} else if (this.s1 == 1) {
	if (this.doff()) {
		this.s1 = 0;
	}
} else if (this.s1 == 2) {
	if (this.doff()) {
		if (this.t_1 == 0) {
			R.TEST_STATE.cutscene_handle_signal(0, [0.01]);
			R.player.enter_cutscene();
		}
		this.t_1++;
		//if (this.t_1 > 60) {
		if (R.TEST_STATE.cutscene_just_finished(0)) {
			R.actscreen.activate(5, this.parent_state);
			this.s1 = 3;
		}
	}
} else if (this.s1 == 3) {
	if (R.actscreen.is_off()) {
		R.TEST_STATE.cutscene_handle_signal(2, [0.01]);
		this.s1 = 4;
	}
} else if (this.s1 == 4) {
	if (R.TEST_STATE.cutscene_just_finished(2)) { 
		this.s1 = 0;
		R.player.enter_main_state();
	}
}
