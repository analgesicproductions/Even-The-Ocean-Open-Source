//{ g2_2_debrief
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	// 38 - G2_2 done
	//this._trace("DEUBG 4l_debref (g2_2 debrief)");
	//this.set_event(38, true);
 	//
	if (this.get_event(38) && this.get_scene_state("g2_2", "debrief", 1) == 0) {
		this.set_scene_state("g2_2", "debrief", 1, 1);
		R.player.energy_bar.bar_sprite.visible = false;
		this.s1 = -1;
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	R.player.enter_cutscene();
	
	R.player.energy_bar.OFF = true;
		R.TEST_STATE.dialogue_box.speaker_always_none = true;
}


R.player.x = 5;
R.player.y = 400;
R.player.velocity.y = 0;


if (this.s1 == -1) {
	this.s1 = 0;
}

if (this.s1 == 0) {
	this.s1 = 1;
	R.easycutscene.activate("2d_debrief");
	
} else if (this.s1 == 1) {
	if (R.easycutscene.ping_last) {
		R.player.energy_bar.bar_sprite.visible = true;
		this.change_map(this.get_map("lighthouse_lobby"), 1, 1, true);
		this.s1 = 4;
	}
	//R.player.enter_main_state();
}
	



