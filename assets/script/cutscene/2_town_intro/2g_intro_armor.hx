// Aliph gets armors
if (!this.child_init) {
	this.child_init = true;
	this.s1 = -1;
	this.only_visible_in_editor = true;
	
	//this._trace("DEBUG 2g_intro_armor");
	//this.set_scene_state("city", "intro_aliph_home", 2, 2);
	
	// Plays after aliph eats noodles 
	if (this.get_scene_state("city", "intro_aliph_home", 2) == 2) {
		if (this.get_scene_state("city", "intro_armor", 1) == 0) {
			this.play_music("mayor_intro",false);
			this.s1 = 0;
			R.player.enter_cutscene();
		} else {
			this.SCRIPT_OFF = true;
			return;
		}
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	R.player.energy_bar.OFF = true;
}

R.player.x = 5;
R.player.y = 400;
R.player.velocity.y = 0;

if (this.s1 == 0) {
	R.easycutscene.start("0g_armor");
	this.s1 = 1;
} else if (this.s1 == 1 && this.doff()) {
	if (R.easycutscene.ping_last) {
			this.set_scene_state("city", "intro_armor", 1, 1);
		this.s1 = 2;
		this.change_map("WF_HI_1", 53, 21, true);
		R.TEST_STATE.insta_d = "city,after_armor,0";
	}
}