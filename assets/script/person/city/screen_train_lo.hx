//{ screen_train_lo
//script s "person/city/screen_train_lo.hx"
//}
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	this.s2 = 0;
	this.s3 = 0;
	//this._trace("DEBUG screentrainlo");
	//this.set_event(29);
	//
	//this.set_ss("city", "wf_j_intro", 1, 1);
	
	
	R.TEST_STATE.dialogue_box.IS_SCREEN_AREA = true;
	// in train hi	
	if (this.context_values[0] == 1) {
		this.s3 = 1;
	}
	// in wf hi 2
	if (this.context_values[0] == 2) {
		this.s3 = 2;
	}
	return;
}

if (this.s1 == 0) {
	this.camera_off();
	this.cam_to_id(0);
	this.s1 = 1;
	R.player.energy_bar.toggle_bar(false, false);
	// turned off in TestState.update_mode_change part 1 so the energy bar doesnt appear till youre gone
	R.player.energy_bar.OFF = true;
}

R.player.x = 500;
R.player.y = 300;
R.player.velocity.y = 0;

if (this.s3 == 0) {
if (this.s1 == 1) {
	if (this.s2 == 0) {
		this.dialogue("city", "train_lo_choice", 0);
		this.s2 = 1;
	} else if (this.s2 == 1) {
		if (this.doff()) {
			R.player.energy_bar.force_hide = false;
			R.sound_manager.allow_fade_all = false;
			var vol = 0.75;
			if ("WF_LO_0" == R.TEST_STATE.prev_map_name) {
				vol = 1.0;
			}
			this.s1 = 3;
			if (this.d_last_yn() == 0) {
				this.change_map("WF_LO_0", 11, 22, true);
				this.play_sound("train_lo_short.wav",vol);
			} else if (this.d_last_yn() == 1) {
				this.change_map("WF_LO_1", 56, 13, true);
				this.play_sound("train_lo_short.wav",vol);
			} else if (this.d_last_yn() == 2) {
				if (this.event(48)) {
					this.s2 = 2;
					this.s1 = 1;
					this.dialogue("city", "train_hi_choice", 5);
					R.player.energy_bar.force_hide = true;
				} else {
					this.change_map("WF_GRAVEYARD", 10, 11, true);
					this.play_sound("train_lo_short.wav", vol);
				}
			} else if (this.d_last_yn() == 3) {
				if (this.get_ss("city", "wf_j_intro", 1) == 0) {
					this.s2 = 2;
					this.s1 = 1;
					this.dialogue("city", "train_lo_choice", 2);
				} else {
					if (this.event(48)) {
						this.s2 = 2;
						this.s1 = 1;
						this.dialogue("city", "train_hi_choice", 5);
						R.player.energy_bar.force_hide = true;
					} else {
						this.change_map("WF_J", 7, 11, true);
						this.play_sound("train_lo_short.wav", vol);
					}
				}
			} else if (this.d_last_yn() == 4) {
				if (!this.event(29)) {
					this.s2 = 2;
					this.s1 = 1;
					this.dialogue("city", "train_lo_choice", 1);
					R.player.energy_bar.force_hide = true;
				} else {
					this.change_map("WF_LIBRARY", 10, 3, true);
					
				this.play_sound("train_lo_short.wav",vol);
				}
			} else if (this.d_last_yn() == 5) {
				// never mind
				
				this.play_sound("enter_door.wav");
				//TODO
				this.s2 = 2;
				if ("WF_LO_0" == R.TEST_STATE.prev_map_name) {
					this.change_map(R.TEST_STATE.prev_map_name, 11,22, true);	
				} else if ("WF_GRAVEYARD" == R.TEST_STATE.prev_map_name) {
					this.change_map(R.TEST_STATE.prev_map_name, 10, 11, true);	
				} else if ("WF_LO_1" == R.TEST_STATE.prev_map_name) {
					this.change_map(R.TEST_STATE.prev_map_name, 56, 13, true);	
				} else if ("WF_J" == R.TEST_STATE.prev_map_name) {
					this.change_map(R.TEST_STATE.prev_map_name, 7, 11, true);	
				} else if ("WF_LIBRARY" == R.TEST_STATE.prev_map_name) {
					this.change_map(R.TEST_STATE.prev_map_name, 10, 13, true);	
				} 
			}
			
		}
	} else if (this.s2 == 2) {
		if (this.doff()) {
			this.s2 = 0;
		}
	}
}
} else if (this.s3 == 1) {
if (this.s1 == 1) {
	if (this.s2 == 0) {
		this.dialogue("city", "train_hi_choice", 0);
		this.s2 = 1;
	} else if (this.s2 == 1) {
		if (this.doff()) {
			R.player.energy_bar.force_hide = false;
			R.sound_manager.allow_fade_all = false;
			this.s1 = 3;
			if (this.d_last_yn() == 0) {
				this.change_map("WF_LO_0", 33, 14, true);
				this.play_sound("trainhishort.wav");
			} else if (this.d_last_yn() == 1) {
				this.change_map("WF_HI_1", 46, 22, true);
				this.play_sound("trainhishort.wav");
			} else if (this.d_last_yn() == 2) {
				if (!this.event(29)) {
					this.s2 = 2;
					this.s1 = 1;
					this.dialogue("city", "train_hi_choice", 1);
					R.player.energy_bar.force_hide = true;
				} else {
					this.change_map("WF_MUSEUM", 1, 3, true);
				this.play_sound("trainhishort.wav");
				}
			} else if (this.d_last_yn() == 3) { // patio
				if (!this.event(29)) {
					this.s2 = 2;
					this.s1 = 1;
					this.dialogue("city", "train_hi_choice", 1);
					R.player.energy_bar.force_hide = true;
				} else {
					
					if (this.event(48)) {
						this.s2 = 2;
						this.s1 = 1;
						this.dialogue("city", "train_hi_choice", 5);
						R.player.energy_bar.force_hide = true;
					} else {
						this.change_map("WF_HI_3", 4,11, true);
						this.play_sound("trainhishort.wav");
					}
				} 
			} else if (this.d_last_yn() == 4) { // apt
				if (!this.event(37)) {
					// DONT HAVE HOUSE YET...
					this.s2 = 2;
					this.s1 = 1;
					this.dialogue("city", "train_hi_choice", 3);
					R.player.energy_bar.force_hide = true;
				} else {
					if (this.event(48)) {
						this.s2 = 2;
						this.s1 = 1;
						this.dialogue("city", "train_hi_choice", 4);
						R.player.energy_bar.force_hide = true;
					} else {
						this.change_map("WF_ALIPH2", 5,5, true);
						this.play_sound("enter_door.wav");
					}
				}
			} else if (this.d_last_yn() == 5) {
				// never mind
				
				this.play_sound("enter_door.wav");
				//TODO
				this.s2 = 2;
				if ("WF_LO_0" == R.TEST_STATE.prev_map_name) {
					this.change_map(R.TEST_STATE.prev_map_name, 33,14, true);	
				} else if ("WF_MUSEUM"  == R.TEST_STATE.prev_map_name) {
					this.change_map(R.TEST_STATE.prev_map_name, 1, 3, true);	
				} else if ("WF_HI_1" == R.TEST_STATE.prev_map_name) {
					this.change_map(R.TEST_STATE.prev_map_name, 46, 22, true);	
				} else if ("WF_HI_3" == R.TEST_STATE.prev_map_name) {
					this.change_map(R.TEST_STATE.prev_map_name, 4,11, true);	
				} else if ("WF_ALIPH2"  == R.TEST_STATE.prev_map_name) {
					this.change_map(R.TEST_STATE.prev_map_name, 5, 5, true);	
				}
			}
		}
	} else if (this.s2 == 2) {
		if (this.doff()) {
			this.s2 = 0;
		}
	}
}
}