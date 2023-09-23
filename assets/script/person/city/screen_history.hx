//{ screen_history
//script s "person/city/screen_history.hx"
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
	this.change_map("WF_GOV_LOBBY", 2, 2, true);
	this.s1 = 3;
}

if (this.s1 == 1) {
	if (this.s2 == 0) {
		this.dialogue("city", "history_intro", 0);
		this.parent_state.dialogue_box.yesno_no_leave = 0;
		this.s2 = 1;
	} else if (this.s2 == 1) {
		if (this.d_last_yn() != -1) {
			this.s2 = 2;
			if (this.d_last_yn() == 1) {
					R.infopage.activate("city", "history_exhibit", 1, this.parent_state);
					//R.infopage.add_sprite("assets/sprites/npc/city/library_info.png", 64, 32, 0, 1,0, 0);
					//R.infopage.add_sprite("assets/sprites/npc/city/library_info.png", 64, 32, 1, 2,0, 0);
			} else if (this.d_last_yn() == 2) {
					R.infopage.activate("city", "history_exhibit", 2, this.parent_state);
					//R.infopage.add_sprite("assets/sprites/npc/city/library_info.png", 64, 32, 0, 1,0, 0);
					//R.infopage.add_sprite("assets/sprites/npc/city/library_info.png", 64, 32, 1, 2,0, 0);
			} else if (this.d_last_yn() == 3) {
					R.infopage.activate("city", "history_exhibit", 3, this.parent_state);
					//R.infopage.add_sprite("assets/sprites/npc/city/library_info.png", 64, 32, 0, 1,0, 0);
					//R.infopage.add_sprite("assets/sprites/npc/city/library_info.png", 64, 32, 1, 2,0, 0);
			} else if (this.d_last_yn() == 4) {
					R.infopage.activate("city", "history_exhibit", 4, this.parent_state);
					//R.infopage.add_sprite("assets/sprites/npc/city/library_info.png", 64, 32, 0, 1,0, 0);
					//R.infopage.add_sprite("assets/sprites/npc/city/library_info.png", 64, 32, 1, 2,0, 0);
			} else if (this.d_last_yn() == 5) {
					R.infopage.activate("city", "history_exhibit", 5, this.parent_state);
					//R.infopage.add_sprite("assets/sprites/npc/city/library_info.png", 64, 32, 0, 1,0, 0);
					//R.infopage.add_sprite("assets/sprites/npc/city/library_info.png", 64, 32, 1, 2,0, 0);
			} else if (this.d_last_yn() == 0) {
				this.s1 = 2;
				this.s2 = 1;
				this.parent_state.dialogue_box.yesno_no_leave = -1; // So future YN chocies dont block
			}
		}
	} else if (this.s2 == 2) {
		if (R.infopage.is_off()) {
			//this.parent_state.dialogue_box.skip_to_yesno = true;
			this.s2 = 1;
			R.TEST_STATE.dialogue_box.last_yn = -1; // So the above state doesn't choose till you do
			R.TEST_STATE.dialogue_box.mode = 6; // Change mode out of info page
		}
	}
}

R.player.x = 500;
R.player.y = 300;
R.player.velocity.y = 0;