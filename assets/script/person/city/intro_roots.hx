//leave city roots
//{ intro_roots
if (!this.child_init) {
	this.child_init = true;
	this.s1 = 0;
	
	// Shows up after waking up for armor then never again.
	//this._trace("debug intro roots");
	//this.set_ss("city", "intro_aliph_home", 2, 2);
	//this.set_ss("city", "wf_j_intro", 1, 0);
	
	if (this.get_ss("city", "wf_j_intro", 1) == 1 || this.get_ss("city", "intro_aliph_home", 2) < 2) {
		this.SCRIPT_OFF = true;
		this.visible = false;
		this.only_visible_in_editor = true;
		return;
	}
	
	this.has_trigger = true;
	this.make_trigger(this.x-32, this.y-100, 20, 160);
}

if (this.s1 == 0) {
	if (R.player.overlaps(this.trigger)) {
		this.s1 = 10;
	}
} else if (this.s1 == 10) {
	if (this.player_freeze_help()) {
		this.set_ss("city", "wf_j_intro", 1, 1);
		this.dialogue("city", "wf_j_intro", 0);
		this.s1 = 1;
	}
} else if (this.s1 == 1) {
	if (this.doff()) {
		this.s1 = 2;
	}
} else if (this.s1 == 2) {
	this.alpha -= 0.05;
	//if (this.try_to_talk()) {
		//this.dialogue("city", "wf_j_intro", 6);
		//this.s1 = 1;
	//}
}