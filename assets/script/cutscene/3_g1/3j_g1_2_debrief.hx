if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	
	
	//this._trace("DEBUG g1_2_debrief: Canyon first, then hill. pax shld appears");
	//// beat g1 and g2
	//this.set_event(29);	
	//this.set_event(30);
	//
	//// beat canyo and hill
	//this.set_event(11);
	//this.set_event(12);
	//
	//// g1 and g2 IDs
	//this.set_event(26, true, 2);
	//this.set_event(27, true, 3);
	//this.set_event(28, true, 1); // should be set in checkin at g1_2
	//
	//// lop pax
	//this.set_event(32, true, 1);
	//this.set_event(33, true, 3);
	
	
	//this._trace("DEBUG g1_2_debrief: paxton - canyon 2nd, hill 1st");
	//this.set_event(30);
	//this.set_event(33, true, 2);
	//this.set_event(27, true, 2);
	//this.set_event(28, true, 1);
	
	if (this.get_event(30) && this.get_scene_state("city_g1_2", "debrief", 1) == 0) {
		this.set_scene_state("city_g1_2", "debrief", 1, 1);
		R.song_helper.permanent_song_name = "";
		
		R.player.energy_bar.bar_sprite.visible = false;
		this.s1 = -1;
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	
	// s3 = lopez or paxton (0  or 1)
	if (this.get_event(32, true) == this.get_event(27, true)) { // lopez
		this.s3 = 0;
	} else {
		this.s3 = 1;
	}
	
	R.player.enter_cutscene();
	R.TEST_STATE.dialogue_box.speaker_always_none = true;
	R.player.energy_bar.OFF = true;
	R.TEST_STATE.dialogue_box.IS_SCREEN_AREA = true; // Must be called bc dialogue fires from this script
}

R.player.x = 5;
R.player.y = 400;
R.player.velocity.y = 0;

if (this.s1 == -1) {
	this.s1 = 0;
	R.easycutscene.activate("1c_g2_debrief");
}

if (this.s1 == 0) {
	if (R.easycutscene.ping_1) {
		R.easycutscene.ping_1 = false;
		this.s1 = 1;
		if (this.s3 == 0) { 
			this.dialogue("city_g1_2", "debrief", 0);
		} else {
			this.dialogue("city_g1_2", "debrief", 3);
		}
	}
} else if (this.s1 == 1) {
	
	if (R.easycutscene.ping_1) {
		R.easycutscene.ping_1 = false;
		this.s1 = 2;
		this.dialogue("city_g1_2", "debrief", 7, false);
	}
} else if (this.s1 == 2 ) {
	if (R.easycutscene.ping_1) {
		R.easycutscene.ping_1 = false;
		if (this.s3 == 0) { 
			this.dialogue("city_g1_2", "debrief", 18);
		} else {
			this.dialogue("city_g1_2", "debrief", 20);
		}
		this.s1 = 3;
	}
} else if (this.s1 == 3) {
	if (R.easycutscene.ping_last) {
		
		R.player.energy_bar.bar_sprite.visible = true;
		this.change_map("WF_HI_1", 53, 21, true);
		R.player.facing = 0x1;
		this.s1 = 4;
		R.TEST_STATE.insta_d = "city_g1_2,debrief,26";
	}
}
	



