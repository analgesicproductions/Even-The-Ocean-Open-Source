
if (!this.child_init) {
	this.has_trigger = true;
	this.child_init = true;
	this.s1 = 0;
	this.only_visible_in_editor = true;
	this.make_trigger(this.x, this.y-150, 32, 200);	
	if (0 == this.context_values[0] && this.get_ss("hill", "aliph_alone", 1) == 1) {
		this.s2 = 1;
		return;
	} else if (1 == this.context_values[0]  && 1 == this.get_ss("hill", "aliph_alone", 2)) {
		this.s2 = 1;
		return;
	}
}

if (this.s2 == 1) {
	if (this.doff()) {
	if (this.try_to_talk(0, this.trigger, true)) {
		if (0 == this.context_values[0]) {
			this.dialogue("hill", "aliph_alone", 0);
			this.s2 = 0;
			this.s1 = 1;	
		} else {
			this.dialogue("hill", "aliph_alone", 1);
		}
	}
	}
	return;
}

if (this.s1 == 0) {
	if (R.player.overlaps(this.trigger)) {
		this.s1 = -1;
	}
} else if (this.s1 == -1) {
	if (this.player_freeze_help()) {
		this.s1 = 1;
		if (0 == this.context_values[0]) {
			this.set_ss("hill", "aliph_alone", 1, 1);	
			this.dialogue("hill", "aliph_alone", 0);
		} else  {
			this.dialogue("hill", "aliph_alone", 1);
			this.set_ss("hill", "aliph_alone", 2, 1);	
			this.s2 = 1;
			return;
		}
	}
} else if (this.s1 == 1) {
	if (this.doff()) {
		this.s1 = 3;
		R.player.enter_cutscene();
		this.pan_camera(0, 0, 180, 0, true, false);
	}
} else if (this.s1 == 3 && this.pan_done()) {
	this.t_1 ++;
	if (this.t_1 > 60) {
		this.t_1 = 0;
		this.s1 = 4;
		this.pan_camera(1, 0, 180, 0, true, false);
	}
	
} else if (this.s1 == 4 && this.pan_done()) {
	
	this.camera_to_player(true);
	R.player.enter_main_state();
	this.s1 = 0;
	this.s2 = 1;
}