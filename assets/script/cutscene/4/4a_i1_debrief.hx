if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	
	//this._trace("DEBUG: 4a_i1_debreif");
	//this.set_event(31);
	
	if (this.get_event(31) && this.get_scene_state("i_1", "debrief", 1) == 0) {
		this.set_scene_state("i_1", "debrief", 1, 1);
		this.s1 = -1;
		R.player.energy_bar.bar_sprite.visible = false;
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	
	if (this.get_event(32, true) == this.get_event(28, true)) { // lopez was in g1_3
		this.s3 = 0;
	} else {
		this.s3 = 1;
	}
	// s3 = lopez or paxton (0  or 1)
	
	R.player.enter_cutscene();
	
	R.player.energy_bar.OFF = true;
	R.TEST_STATE.dialogue_box.speaker_always_none = true;
	R.TEST_STATE.dialogue_box.IS_SCREEN_AREA = true;
}


R.player.x = 5;
R.player.y = 400;
R.player.velocity.y = 0;

if (this.s1 == -1) {
	this.s1 = 0;
	R.easycutscene.activate("1e_g3_debrief");
}

if (this.s1 == 0) {
	if (R.easycutscene.ping_1) {
		R.easycutscene.ping_1 = false;
		this.s1 = 1;
		if (this.s3 == 0) { 
			this.dialogue("i_1", "debrief", 0);
		} else {
			this.dialogue("i_1", "debrief", 2);
		}
	}
} else if (this.s1 == 1) {
	if (R.easycutscene.ping_1) {
		// pick
		this.dialogue("i_1", "debrief", 39);
		this.s1 = 9;
	}
}  else if (this.s1 == 9) {
	if (this.d_last_yn() != -1) {
		var yn = this.d_last_yn();
		this.s1 = 10;
		R.easycutscene.ping_1 = false;
		if (yn == 0) {
			// set g2_1  to river
			this.set_event(34, true, 4);
			this._trace("river chosen");
			this.dialogue("i_1", "debrief", 40);
		} else if (yn == 1) {
			this.set_event(34, true, 6); // basin
			this._trace("basin chosen");
			this.dialogue("i_1", "debrief", 41);
		} else if (yn == 2) {
			this.set_event(34, true, 5); // woods
			this._trace("woods chosen");
			this.dialogue("i_1", "debrief", 42);
		}
	}
} else if (this.s1 == 10) {
	if (R.easycutscene.ping_last) {
		R.player.energy_bar.bar_sprite.visible = true;
		this.change_map(this.get_map("lighthouse_lobby"), 1, 1, true);
		this.s1 = 11;
	}
}
	



