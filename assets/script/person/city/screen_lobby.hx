//{ screen_lobby
//script s "person/city/screen_lobby.hx"
//}
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	this.s2 = 0;
	this.s3 = 0;
	//this._trace("DEBUG screen_lobby");
	
	//this.set_ss("city", "intro_aliph_home", 2, 2);
	//this.set_ss("city", "intro_armor", 1, 0);
	
	
	//this.set_ss("g2_1", "debrief", 1, 1); // open history
	
	
	/* Don't play when doing the armor scene */
	if (this.get_ss("city", "intro_aliph_home", 2) == 2 && this.get_ss("city", "intro_armor", 1) == 0) {
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
		this.dialogue("city", "gov_lobby", 0);
		this.s2 = 1;
	} else if (this.s2 == 1) {
		if (this.doff()) {
			this.s1 = 3;
			if (this.d_last_yn() == 0) {
				this.change_map("WF_HI_1", 53, 21, true);
				R.player.facing = 0x1;
				this.s1 = 4;
			} else if (this.d_last_yn() == 1) {
				if (this.get_ss("g2_1", "debrief", 1) > 0) {
					this.change_map("WF_GOV_HIST", 0, 0, true);
					this.s1 = 4;
				} else {
					this.dialogue("city", "gov_lobby", 1);
				}
			} else if (this.d_last_yn() == 2) {
				this.dialogue("city", "gov_lobby_person", 0);
			}
		}
	}
} else if (this.s1 == 3) {
	if (this.doff()) {
		this.s1 = 1;
		this.s2 = 0;
	}
}