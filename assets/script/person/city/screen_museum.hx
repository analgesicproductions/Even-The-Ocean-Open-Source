//{ screen_museum
//script s "person/city/screen_museum.hx"
//}
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	this.s2 = 0;
	this.s3 = 0;
	//this.set_event(37);
	//this.set_event(37, false);
	//this.set_ss("city", "museum_violet_2", 1, 0);
	
	R.TEST_STATE.dialogue_box.IS_SCREEN_AREA = true;
	if (this.event(37)) {
		this.s3 = 1;
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
if (this.s1 == 2) {
	R.player.energy_bar.force_hide = false;
	this.change_map("WF_TRAIN_HI", 0, 0, true);
	this.s1 = 3;
}
R.player.x = 500;
R.player.y = 300;
R.player.velocity.y = 0;
if (this.s1 == 1) {
	if (this.s2 == 0) {
		if (this.s3 == 0) {
			this.dialogue("city", "museum_intro", 0);
		} else if (this.s3 == 1) {
			this.dialogue("city", "museum_intro", 0);
		}
		this.s2 = 1;
	} else if (this.s2 == 1) { // Act on the first choice
		if (this.doff()) {
			if (this.d_last_yn() == 0) { // leave
				this.s1 = 2;
			} else if (this.d_last_yn() == 2) { // Go on a tour
				this.s2 = 2;
				if (this.s3 == 1) {
					this.dialogue("city", "museum_violet_2", 0);
				} else {
					this.dialogue("city", "museum_violet_1", 0);
				}
			} else if (this.d_last_yn() == 1) { // Look around
				this.s2 = 2;
				if (this.s3 == 0) {
					this.dialogue("city", "museum_intro", 1);
				} else if (this.s3 == 1) {
					this.dialogue("city", "museum_intro", 2);
				} 
			} else if (this.d_last_yn() == 3) { // people watch
				this.s2 = 2;
				if (this.s3 == 0) {
					this.dialogue("city", "museum_gossip", 0);
				} else if (this.s3 == 1) {
					this.dialogue("city", "museum_gossip", 0);
				} 
			}
		}
	} else if (this.s2 == 2) {
		if (this.doff()) {
			
			R.achv.unlock(R.achv.museum);
			this.s2 = 0;
		}
	}
}
