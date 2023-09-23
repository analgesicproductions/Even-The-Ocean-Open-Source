// Alipg enters home, eats noodles then eventually sleeps and writes injournals
if (!this.child_init) {
	this.child_init = true;
	this.s1 = -1;
	this.only_visible_in_editor = true;
	
	 //DEBUG!!!
	//this.set_scene_state("city", "intro_aliph_home", 1, 1);
	
	if (this.get_ss("city", "intro_aliph_home", 1) == 1) {
		var ss2 = this.get_ss("city", "intro_aliph_home", 2);
		if (ss2 == 0) {
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
	R.easycutscene.start("0f_aliph");
	this.s1 = 1;
} else if (this.s1 == 1) {
	if (R.easycutscene.ping_last) { 
		R.actscreen.activate(2, this.parent_state);
		R.player.energy_bar.set_energy(128);	
		this.s1 = 2;
	} 
} else if (this.s1 == 2) {
	if (R.actscreen.is_off()) {
		this.s1 = 3;
		this.change_map("WF_LO_1", 26, 13, true);
		this.set_ss("city", "intro_aliph_home", 2, 2);
	}
}









