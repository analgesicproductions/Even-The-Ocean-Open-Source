if (!this.child_init) {
	this.only_visible_in_editor = true;
	this.child_init = true;
	
	//this._trace("debug 2b_aliph_fades");
	//this.set_ss("city", "aliph_fades", 1, 0);
	//this.set_ss("intro", "map", 1, 1);
	
	
	this.s1 = 0;
	
	// If this sequence seen, just exit.
	if (this.get_scene_state("city", "aliph_fades", 1) == 1) {
		this.SCRIPT_OFF = true;
		return;
	} else if (this.get_ss("intro","map",1) == 1) {
		R.gs1 = 1;
	} else {
		this._trace("2b_Aliph_fades is OFF");
		this.SCRIPT_OFF = true;
		return;
	}
	
	if (R.gs1 == 1) {
		R.player.energy_bar.OFF = true;
		R.player.enter_cutscene();
	}
}


R.player.x = 5;
R.player.y = 500;
R.player.velocity.y = 0;

if (this.s1 == 0) {
	R.easycutscene.start("0b_aliph");
	this.s1 = 1;
} else if (this.s1 == 1) {
	if (R.easycutscene.ping_last) {
		this.set_scene_state("city","aliph_fades", 1, 1);
		this.change_map("WF_GRAVEYARD", 12, 12, true);
		R.gs1 = 0;
		this.s1 = 2;
	}
}
