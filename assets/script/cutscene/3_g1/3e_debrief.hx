if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	
	// Plays after overworld -> train after G1_1
	 //DEBUG - Finish G1_1, visited shore first, lopez at hill, paxton at canyon
	 //this._trace("Debug 3e_debrief");
	//this.set_event(29, true);
	//this.set_scene_state("city_i1", "debrief", 1, 0);
	//this.set_event(26, true, 1);
	//// Lopez -> Hill Pax -> Canyon
	//this.set_event(32, true, 3);
	//this.set_event(33, true, 2);
	
	
	if (this.get_event(29) && 1 != this.get_scene_state("city_i1", "debrief", 1)) {
		R.song_helper.permanent_song_name = "";
		this.set_scene_state("city_i1", "debrief", 1, 1);
		this.s1 = -2;
		R.player.energy_bar.bar_sprite.visible = false;
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	R.player.enter_cutscene();
	R.TEST_STATE.dialogue_box.speaker_always_none = true;
}

R.player.x = 5;
R.player.y = 400;
R.player.velocity.y = 0;

if (this.s1 == -2) {
	this.s1 = 0;
}

if (this.s1 == 0) {
	R.easycutscene.activate("1a_g1_debrief");
	this.s1 = 1;
} else if (this.s1 == 1) {
	if (R.easycutscene.ping_last) {
		R.player.energy_bar.bar_sprite.visible = true;
		this.change_map("WF_GOV_LOBBY", 1, 2, true);
		this.s1 = 2;
	}
}