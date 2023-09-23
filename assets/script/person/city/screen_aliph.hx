//{ screen_aliph
//script s "person/city/screen_aliph.hx"
//}
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	this.s2 = 0;
	this.s3 = 0;
	//this._trace("DEBUG screen_aliph");
	//this.set_event(29);
	//this.set_ss("city_i1", "yara", 1, 1);
	//this.set_ss("city_i1", "after_yara_1", 1, 0);
	
	
	/* Don't play when doing the intro fades */
	if (this.get_ss("intro", "map", 1) == 1 && this.get_ss("city", "aliph_fades", 1) == 0) {
		this._trace("Off during introfades");
		this.SCRIPT_OFF = true;
		return;
	}
	
	
	R.TEST_STATE.dialogue_box.IS_SCREEN_AREA = true;
	return;
}

if (this.s1 == 0) {
	this.camera_off();
	this.cam_to_id(0);
	this.s1 = 1;
	// turned off in TestState.update_mode_change part 1 so the energy bar doesnt appear till youre gone
	R.player.energy_bar.OFF = true;
}

R.player.x = 500;
R.player.y = 300;
R.player.velocity.y = 0;

if (this.s1 == 1) {
	if (this.s2 == 0) {
		if (this.get_ss("city", "intro_aliph_home", 1) == 1 && 2 != this.get_ss("city", "intro_aliph_home", 2) ) {
			this.SCRIPT_OFF = true;
			return;
		}
		
		// Determine if there's a 'wakeup' dialogue
		if (this.get_ss("i_1", "yara", 1) == 1 && this.get_ss("i_1", "aliph_home_i1", 1) == 0) {
			this.s2 = 10;
			this.dialogue("i_1", "aliph_home_i1", 0);
			this.set_ss("i_1", "aliph_home_i1", 1, 1);
			R.player.energy_bar.set_energy(128);
			this.play_music("aliphssong", false);
		} else if (this.get_ss("city_i1", "yara", 1) == 1 && this.get_ss("city_i1", "after_yara_1", 1) == 0) {
			this.s2 = 10;
			R.player.energy_bar.set_energy(128);
			this.set_ss("city_i1", "after_yara_1", 1, 1);
			this.dialogue("city_i1", "after_yara_1", 0);
			this.play_music("aliphssong", false);
		} else {			
			this.dialogue("city_i1", "aliph_screen", 0);
			this.s2 = 1;
			this.play_music("aliphssong", false);
		}
	} else if (this.s2 == 10 && this.doff()) {
		this.s2 = 1;
		this.dialogue("city_i1", "aliph_screen", 0);
	} else if (this.s2 == 1) {
		if (this.doff()) {
			this.s1 = 3;
			if (this.d_last_yn() == 0) {
				this.change_map("WF_LO_1", 26, 13, true);
				// if choice stays in screen
				//R.player.energy_bar.force_hide = true;
			}
		}
	}
}