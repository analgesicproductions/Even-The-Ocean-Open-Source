// DEBUG!
if (!this.child_init) {
	this.child_init = true;
	//R.song_helper.fade_to_this_song("null");
	//this.play_sound("powerplant_frequency_roar.ogg");
	//this.state_1 = 1;
		//this.nr_LIGHT_received = 4;
		
	//this.set_scene_state("intro", "message", 1, 1);
		//this.set_event(23);
	if (this.get_event_state(23) == true) {
		this.broadcast_to_children("energize_l");
		this.play_anim("on");
		this.nr_LIGHT_received = 4;
		this.s2 = 2;
		
		this.set_ss("test", "gstate", 1,0);
	}
	this.s3 = 0;
	//this.state_1 = 1;
	//this.t_2 = 2000;
	
	return;
}

if (this.s3 < 2) {
	this.s3 ++ ;
	if (this.s3 == 2) {
	this.recv_message("RESTORE_PLANTBLOCK");
	}	
}

// console in generic_npc.son
if (this.s1 == 0) {
	
		
		if (this.s2 == 0 && this.nr_LIGHT_received == 1) {
			R.player.animation.play("irn");
			this.dialogue("intro", "plantblock", 12); // one down
			this.s2 = 1;
		}
		if (this.nr_LIGHT_received == 4 && this.s2 < 2) {
			this.s2 = 2;
			if (this.get_scene_state("intro", "plantblock", 1) != 1) {
				if (R.player.facing == 1) {
				R.player.animation.play("iln");
				} else {
				R.player.animation.play("irn");
				}
				if (R.story_mode) {
					this.set_scene_state("intro", "control_room_enter", 1, 1);	// set in 1f_control_room_enter, but not in story mode so set it here
					this.dialogue("intro", "control_room_enter", 5); // note on story mode for player
				} else {
					this.dialogue("intro", "plantblock", 6); // "theyre all done blah blah"
				}
				this.set_scene_state("intro", "plantblock", 1, 1);
			}
		}
	//this.nr_LIGHT_received = 3;
	if (this.nr_LIGHT_received >= 4) {
		this.play_anim("on");
		if (this.try_to_talk(0, null, true)) {
			//public static inline var INTRO_console_scene_done:Int = 23;
			if (this.get_event_state(23) == true) {
				this.dialogue("intro", "at_console_done", 0); // It's done, i should leave.
			} else {
				R.song_helper.fade_to_this_song("null",false);
				this.s1 = 1;
				this.dialogue("intro", "at_console", 0, false); // Let's see here..
			}
		}
	} else if (this.try_to_talk(0, null, true)) {
		this.dialogue("intro", "at_console_done", 1); // I need tofix this thing.
	}
} else if (this.s1 == 1) {
	if (!this.dialogue_is_on()) {
		this.s1 = 1000;
		this.do_laser_game(0);
		this.laser_game.no_laser = true;
		this.parent_state.remove(this.parent_state.dialogue_box, true);
		this.parent_state.add(this.parent_state.dialogue_box);
		this.t_1 = 0;
	}
} else if (this.s1 == 1000) {
	if (this.t_1 == 90 && this.doff()) {
		this.dialogue("intro", "at_console_done", 2, false); // I need tofix this thing.
		this.t_1 = 91;
		return;
	}  else if (this.t_1 == 91) {
		if (this.doff()) {
			this.laser_game.no_laser = false;
			this.t_1 = 92;
		}
		return;
	}
	this.t_1 ++;
	if (this.t_1 > 90 && this.do_laser_game(1)) {
		
		this.do_laser_game(2);
		this.t_1 = 0;
		this.play_sound("powerplant_multiple_click.ogg",0.7);
		this.s1 = 2;
	}
} else if (this.s1 == 2) {
	this.t_1 ++;
	if (this.t_1 > 120) {
		this.t_1 = 0;
		this.s1 = 3;
		this.dialogue("intro", "at_console", 1,false);  // set the freq, and...
	}
} else if (this.s1 == 3) {
	if (!this.dialogue_is_on()) {
		this.play_sound("powerplant_frequency_whir.ogg");
		this.s1 = 4;
	}
} else if (this.s1 == 4) {
	this.t_1 ++ ;
	if (this.t_1 > 330) {
		this.t_1 = 0;
		this.dialogue("intro", "at_console", 2,false); // Okay...that should do it,
		this.s1 = 5;
	}
} else if (this.s1 == 5) {
	if (!this.dialogue_is_on()) {
		
		this.broadcast_to_children("energize_l");
		this.play_sound("powerplant_frequency_roar.ogg",0.35);
		this.state_1 = 1;
		this.s1 = 6;
	}
} else if (this.s1 == 6) {
	this.t_1 ++;
	if (this.t_1 > 420) {
		this.t_1 = 0;
		this.dialogue("intro", "at_console", 3); // Hello? this is aliph.....Well, that's that.
		this.s1 = 7;
	}
} else if (this.s1 == 7) {//pan camera etc, elevator
	if (!this.dialogue_is_on()) {
		this.s1 = 0;
		// Reset state
		this.set_ss("test", "gstate", 1,0);
		this.set_event(23);
		if (R.gauntlet_mode) {
			this.change_map("GM_1", 4, 13, true);
			this.s1 = 8;
		} else {
			this.s1 = 8;
			this.change_map("MAP1", 98, 32, true);
		}
	}
}

// play loop
if (this.state_1 == 1) {
	this.t_2++;
	if (this.t_2 > 60 * 18 + 45) {
		this.t_2 = 0;
		this.state_1 = 2;
		this.play_sound("pp_freq_roar_loop.ogg",0.6);
	}
} else if (this.state_1 == 2) {
	this.t_2++;
	if (this.t_2 > 60 * 6 + 30) {
		this.t_2 = 0;
		this.play_sound("pp_freq_roar_loop.ogg",0.6);
	}
}

