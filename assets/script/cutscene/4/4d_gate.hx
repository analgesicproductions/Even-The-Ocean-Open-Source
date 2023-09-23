//  Gate person in town leaving after I1
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;

	
	//this._trace("debug 4d_gate");
	//this.set_ss("i_1", "yara", 1, 1);
	
	if (1 <= this.get_ss("i_1","yara",1) && this.get_ss("i_1", "gate_exit", 1) == 0) {
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	// map i_1 gate_exit
	this.has_trigger = true;
	this.make_trigger(this.x-80 , this.y-130, 16, 200);
}


if (this.s1 == 0 && R.player.overlaps(this.trigger)) {
	this.s1 = 1;
		this.set_ss("i_1", "gate_exit", 1, 1);
} else if (this.s1 == 1 && this.player_freeze_help()) {
	this.dialogue("i_1", "gate_exit", 0);
	this.s1 = 2;
} else if (this.s1 == 2 && this.doff()) {
	
}
