//{ i2_enter_city
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	
	//this._trace("DEBUG 5a_enter_city");
	//this.set_event(39, true); // g2_3 done
	//this.set_ss("i2", "cart_init", 1, 0);
	//this.set_ss("i2", "mayor_init", 1, 0);
	
	if (this.get_event(39) && this.get_ss("i2", "cart_init", 1) == 0) {
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	
	R.player.enter_cutscene();
	R.player.energy_bar.OFF = true;
		// TODO
	R.player.last.x = R.player.x = this.x;
	R.player.last.y = R.player.y = this.y + 16;
	R.player.facing = 0x0010;
	R.player.animation.play("irn");
	
}

if (this.s1 == 0) {
	this.cam_to_id(2);
	R.song_helper.permanent_song_name = "wf_city_attack";
	this.play_music("wf_city_attack");
	this.set_ss("i2", "cart_init", 1, 1);
	R.easycutscene.activate("3a_gate");
	this.s1 = 1;
} else if (this.s1 == 1 && R.easycutscene.ping_1) {
	this.dialogue("i2", "cart_init", 0);
	this.s1 = 2;
} else if (this.s1 == 2 && this.doff()) {
	R.TEST_STATE.dialogue_box.speaker_always_none = true;
	R.player.enter_cutscene();
	R.easycutscene.ping_1 = false;
	this.s1 = 3;
} else if (this.s1 == 3 && R.easycutscene.ping_last) {
	this.change_map("WF_HI_1", 53, 21, true);
	this.s1 = 4;
}
