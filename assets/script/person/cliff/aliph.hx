// cliff
if (!this.child_init) {
	this.has_trigger = true;
	this.child_init = true;
	this.s1 = 0;
	this.only_visible_in_editor = true;
	if (this.context_values[0] == 1) { // entrance
			this.make_trigger(this.x, this.y-100, 32, 180);
		if (this.get_ss("cliff", "aliph_alone", 1) == 1) {
			if (this.event(18)) { // cliff done
				this.SCRIPT_OFF = true;
				return;
			}
			this.s2 = 1;
			return;
		} else {
		}
	} else if (this.context_values[0] == 2) { // cactus base
			this.make_trigger(this.x, this.y-100, 32, 180);
		if (this.get_ss("cliff", "aliph_alone", 2) == 1) {
			
			if (this.event(18)) { // cliff done
				this.SCRIPT_OFF = true;
				return;
			}
			this.s2 = 1;
			return;
		} else {
		}
	} else if (this.context_values[0] == 3) {
			this.make_trigger(this.x, this.y, 80, 80);
		if (this.get_ss("cliff","incense",1) == 0 || this.get_ss("cliff", "aliph_surface", 1) == 1) {
			this.SCRIPT_OFF = true;
			return;
		} else {
		}
	} 
}

if (this.s2 == 1) {
	if (this.try_to_talk(0, this.trigger, true)) {
		
			if (this.context_values[0] == 1) {
				this.dialogue("cliff", "aliph_alone", 0);
			} else {
				this.dialogue("cliff", "aliph_alone", 1);
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
			this.set_ss("cliff", "aliph_alone", 1, 1);	
			this.dialogue("cliff", "aliph_alone", 0);
		} else if (this.context_values[0] == 2) {
			this.set_ss("cliff", "aliph_alone", 2, 1);
			this.dialogue("cliff", "aliph_alone", 1);
		} else if (this.context_values[0] == 3) {
			this.set_ss("cliff", "aliph_surface", 1, 1);
			this.dialogue("cliff", "aliph_surface", 0);
			this.SCRIPT_OFF = true;
		}
	}
} else if (this.s1 == 1) {
	if (this.doff()) {
		this.s1 = 0;
		this.s2 = 1;
	}
}