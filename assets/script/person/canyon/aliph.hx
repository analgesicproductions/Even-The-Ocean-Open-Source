
if (!this.child_init) {
	this.has_trigger = true;
	this.child_init = true;
	this.s1 = 0;
	this.only_visible_in_editor = true;
			this.make_trigger(this.x, this.y, 32, 32);
	if (this.context_values[0] == 1) {
		if (this.get_ss("canyon", "aliph_alone", 1) == 1) {
			this.s2 = 1;
			return;
		} else {
		}
	} else {
		if (this.get_ss("canyon", "aliph_alone", 2) == 1) {
			this.s2 = 1;
			return;
		} else {
		}
	}
}

if (this.s2 == 1) {
	if (this.try_to_talk(0, this.trigger, true)) {
		
			if (this.context_values[0] == 1) {
				this.dialogue("canyon", "aliph_alone", 0);
			} else {
				this.dialogue("canyon", "aliph_alone", 1);
			}
		this.s1 = 1;
		this.s2 = 0;
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
		if (this.context_values[0] == 1) {
			this.set_ss("canyon", "aliph_alone", 1, 1);	
			this.dialogue("canyon", "aliph_alone", 0);
		} else {
			this.set_ss("canyon", "aliph_alone", 2, 1);
			this.dialogue("canyon", "aliph_alone", 1);
		}
	}
} else if (this.s1 == 1) {
	if (this.doff()) {
		if (this.context_values[0] == 1) {
			this.s1 = 0;
			this.s2 = 1;
		} else {
			this.s1 = 3;
			R.player.enter_cutscene();
			this.pan_camera(0, 0, 180, 0, true, false);
		}
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