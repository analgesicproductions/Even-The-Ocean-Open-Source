if (!this.child_init) {
	this.child_init = true;
	this.has_trigger = true;
	this.make_trigger(this.x-32, this.y-200, 20, 232);
	if (this.get_ss("shore", "fisher_1", 1) == 0) {
		this.s1 = 0;
	} else {
		this.s1 = 2;
	}
}


if (this.s1 == 0) {
	if (R.player.overlaps(this.trigger)) {
		this.s1 = 1;	
		this.set_ss("shore", "fisher_1", 1, 1);
	}
} else if (this.s1 == 1 && this.player_freeze_help()) {
	this.s1 = 2;
	this.dialogue("shore", "fisher_1", 8);
} else if (this.s1 == 2 && this.doff()) {
	if (this.try_to_talk()) {
		this.dialogue("shore", "fisher_1", 0);
	}	
}

