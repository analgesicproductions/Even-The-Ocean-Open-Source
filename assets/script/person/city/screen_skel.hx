//{ screen_skel
//script s "person/city/screen_skel.hx"
//}

if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	this.s2 = 0;
	
	R.TEST_STATE.dialogue_box.IS_SCREEN_AREA = true;
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
if (this.s1 == 2) {
	R.player.energy_bar.force_hide = false;
	this.change_map("WF_LIBRARY", 30, 30, true);
	this.s1 = 3;
}
if (this.s1 == 3) {
	
}

if (this.s1 == 1) {
	if (this.s2 == 0) {
		this.dialogue("city", "screen_test", 0);
		this.s2 = 1;
	} else if (this.s2 == 1) {
		if (this.doff()) {
			if (this.d_last_yn() == 0) {
				this.s1 = 2;
			} else if (this.d_last_yn() == 1) {
				this.s2 = 2;
				this.dialogue("city", "screen_test", 1);
			} else if (this.d_last_yn() == 2) {
				R.player.energy_bar.force_hide = false;
				this.change_map("CAMTEST", 10, 30, true);
				this.s1 = 3;
			}
		}
	} else if (this.s2 == 2) {
		if (this.doff()) {
			this.s2 = 0;
		}
	}
}

R.player.x = 500;
R.player.y = 300;
R.player.velocity.y = 0;