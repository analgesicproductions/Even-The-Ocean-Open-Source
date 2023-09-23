if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	// DEBUG
	//this._trace("debug 2d mayor intro");
	//this.s1 = 0;
	//this.set_scene_state("city", "funeral_speech", 1, 1);
	//this.set_scene_state("city", "mayor_intro", 1, 0);

	// Plays after funeral
	//this._trace(this.get_ss("city", "funeral_speech", 1));
	//this._trace(this.get_ss("city", "mayor_intro", 1));
	if (this.get_ss("city", "funeral_speech", 1) == 1) {
		if (this.get_ss("city", "mayor_intro", 1) == 0) {
			this.set_ss("city", "mayor_intro", 1, 1);
			this.s1 = 0;
		} else {
			this.SCRIPT_OFF = true;
			return;
		}
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	R.player.enter_cutscene();
	
	R.player.energy_bar.OFF = true;
	return;
}

R.player.x = 5;
R.player.y = 400;
R.player.velocity.y = 0;

this.t_1++;
if (this.t_1 < 4) return;
//this._trace(R.easycutscene.ping_last);
if (this.s1 == 0) {
	R.easycutscene.activate("0d_mayor",this.parent_state);
	this.s1 = 1;
} else if (this.s1 == 1) {
	if (R.easycutscene.ping_last) {
		this.change_map("WF_HI_1", 53, 21, true);
		this.s1 = 2;
	}
}