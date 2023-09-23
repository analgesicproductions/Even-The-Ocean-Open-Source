//{ i2_aliph_out
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	//this._trace("DEBUG 5g_aliph_out");
	//this.set_ss("i2", "mayor_sad", 1, 1);
	//this.set_ss("i2", "aliph_out", 1, 0);
	
	
	
	if (this.get_ss("i2", "mayor_sad", 1) == 1 && this.get_ss("i2", "aliph_out", 1) == 0) {
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
}
if (this.s1 == 0) {
	this.t_1++;
	if (this.t_1 == 3) {
		this.cam_to_id(0);
	}
	if (this.t_1 > 8) {
		this.t_1 = 0;
		this.play_music("wf_city_attack");
		this.dialogue("i2", "aliph_out", 0);
		this.s1 = 1;
		this.set_ss("i2", "aliph_out", 1, 1);
	}
} else if (this.s1 == 1) {
	if (this.doff()) {
		R.player.energy_bar.OFF = false;
		this.camera_to_player(true);
		this.s1 = 2;
	}
}
