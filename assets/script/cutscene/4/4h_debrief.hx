//{ g2_1_debrief (x2)
if (!this.child_init) {
	this.child_init = true;
	this.s1 = 0;
	this.only_visible_in_editor = true;
	//this._trace("DEBUG 4h_debrief (post g2_1)");
	// 37 to 39 g2_1 to g2_3
	//this.set_event(37, true);
	//this.set_ss("g2_1", "debrief", 1, 0);
	
	if (this.s1 == 0) {
		if (R.gs1 != 1 && this.get_ss("g2_1", "debrief", 1) == 0 && this.get_event_state(37)) {
			this.set_ss("g2_1", "debrief", 1, 1);
			R.player.energy_bar.bar_sprite.visible = false;
			R.player.enter_cutscene();
			this.s1 = -1;
		} else {
			this.SCRIPT_OFF = true;
			return;
		}
	}
	R.player.energy_bar.OFF = true;
	R.TEST_STATE.dialogue_box.speaker_always_none = true;
}


R.player.x = 5;
R.player.y = 400;
R.player.velocity.y = 0;

/* Mayor office PT 1 */
if (this.s1 == -1) {
	this.s1 = 0;
	R.easycutscene.activate("2a_history");
} else if (this.s1 == 0) {
	if (R.easycutscene.ping_last) {
		this.s1 = 1;	
		R.player.energy_bar.bar_sprite.visible = true;
	}
} else if (this.s1 == 1) {
	this.change_map(this.get_map("lighthouse_lobby"), 3, 3, true);
	this.s1 = 4;
}