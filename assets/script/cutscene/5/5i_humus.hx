/* DEPRECATED */
//{ i2_humus in the jail, plus yara scene
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	this.s2 = 0;
	
	//this._trace("DEBUG 5i_humus");
	//this.set_ss("i2", "crowd", 1, 1);
	//this.set_ss("i2", "humus_jail", 1, 0);
	
	if (this.get_ss("i2","crowd",1) == 1 && this.get_ss("i2","humus_jail",1) == 0) {
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	
	R.player.energy_bar.OFF = true;
	R.TEST_STATE.dialogue_box.speaker_always_none = true;
}

R.player.x = 5;
R.player.y = 400;
R.player.velocity.y = 0;

if (this.s1 == 0) {
	this.play_music("humus_theme");
	R.player.enter_cutscene();
	this.s1 = 1;
} else if (this.s1 == 1) {
	this.dialogue("i2", "humus_jail", 0,false);
	this.s1 = 2;
} else if (this.s1 == 2) {
	if (this.doff()) {
		this.s1 = 3;
	}
}