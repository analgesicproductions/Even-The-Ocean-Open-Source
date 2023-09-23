//{ g2_1_apt
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	// always runs the first time u enter
	//this._trace("DEBUG 4i_apt");
	//this.set_ss("g2_1", "debrief", 1, 1);
	
	
	R.player.energy_bar.OFF = true;
		R.TEST_STATE.dialogue_box.speaker_always_none = true;
		
	if (this.get_ss("g2_1","hi_res", 1) == 0 && this.get_ss("g2_1","debrief",1) == 1) {
		this.set_ss("g2_1", "hi_res", 1, 1);
		this.play_music("mayor_apt",false);
		return;
	} else if (0 == this.get_ss("g2_1", "yara", 1) && this.get_ss("g2_1","hi_res", 1) == 1 && this.get_ss("g2_1","debrief",1) == 1) {
		this.play_music("mayor_apt",false);
	} else if (this.get_ss("g2_1", "yara", 1) == 1) { // set from yara in garden
		this.play_music("aliph_new_apt", false);
		this.set_ss("g2_1", "aliph_apt", 1, 2); // to exit the city
		this.set_ss("g2_1", "yara", 1, 2); // to turn off yara in garden
	} else {
		this.play_music("wf_hi_res", false);
	}
	
	R.TEST_STATE.dialogue_box.IS_SCREEN_AREA = true;
	this.s2 = 1;
	
}

R.player.x = 5;
R.player.y = 400;
R.player.velocity.y = 0;


if (this.s2 == 1) {
	if (this.s1 == 0) {
		this.camera_off();
		this.cam_to_id(0);	
		R.player.enter_cutscene();
		
		
		// after g2_2 debrief
		if (this.get_ss("i2", "humus_jail", 1) == 1) {
			this.s1 = 1;
			this.dialogue("g2_1", "aliph_apt_normal", 4);
		} else if (this.get_ss("g2_2", "bed", 1) == 0 && this.get_ss("g2_2", "debrief", 1) == 1) {
			this.s1 = 3;
			// "time to sleep?"
			this.dialogue("g2_1", "aliph_apt_normal", 1);
		} else if (this.get_ss("g2_2", "bed", 1) == 1) {
			this.dialogue("g2_1", "aliph_apt_normal", 3);
			this.s1 = 1;
		} else {
			this.dialogue("g2_1", "aliph_apt_normal", 0);
			this.s1 = 1;
		}
	} else if (this.s1 == 1 && this.doff()) {
		if (this.d_last_yn() == 0) {
			this.s1 = 2;
			this.change_map("WF_TRAIN_HI", 20,3,true);
				R.TEST_STATE.dialogue_box.speaker_always_none = false;
		}
		
	} else if (this.s1 == 2) {
		
	} else if (this.s1 == 3) {
		if (this.doff()) {
			if (this.d_last_yn() == 0) {
				R.player.energy_bar.set_energy(128);
				// EZ cutscene
				R.easycutscene.activate("2e_g5_sleep");
				this.set_ss("g2_2", "bed", 1, 1);
				this.s1 = 4;
			} else {
				this.change_map("WF_TRAIN_HI", 20, 3, true);
				R.TEST_STATE.dialogue_box.speaker_always_none = false;
				this.s1 = 2;
			}
		}
	} else if (this.s1 == 4) {
		if (R.easycutscene.is_off()) {
			this.s1 = 0;
		}
	}
	return;
}

// s2 = 0
if (this.s1 == 0) {
	R.player.enter_cutscene();
	this.s1 = 1;
} else if (this.s1 == 1) {
	R.easycutscene.activate("2b_windsweep");
	this.s1 = 2;
} else if (this.s1 == 2) {
	if (R.easycutscene.ping_last) {
		this.change_map("WF_TRAIN_HI", 20, 3, true);
		
		R.TEST_STATE.dialogue_box.speaker_always_none = false;
		this.s1 = 3;
	}
}