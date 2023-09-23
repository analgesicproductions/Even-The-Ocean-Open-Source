// blocks leaving the first 3 areas
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.has_trigger = true;
	this.make_trigger(this.x , this.y, 16, 200);
	//this._trace("debug 3h_nature_blocker");
	//this.set_ss("city", "intro_yara", 1, 1);
}


// run back to the right
if (this.s1 == 0) {
	if (this.trigger.overlaps(R.player)) {
		if (this.get_ss("city", "intro_yara", 1) == 0) {
			this.s2 = 1;
			this.s1 = 1;
		} else {
			this.s2 = 0;
			
			if (this.get_event(26, true) > 0 && this.get_ss("nature", "g1_1_call_mayor",1) == 1 && !this.get_event(29)) {
				this.s1 = 1;
			} else if (this.get_event(27, true) > 0 && this.get_ss("nature_g1_2","checkin",1) == 1 && !this.get_event(30)) {
				this.s1 = 1;
			} else if (this.get_event(28, true) > 0 && this.get_ss("nature_g1_3","checkin",1) == 1 && !this.get_event(31)) {
				this.s1 = 1;
			}
		}
	}
} else if (this.s1 == 1) {
	if (this.player_freeze_help()) {
		R.player.pause_toggle(false);
		R.player.enter_cutscene();
		if (this.s2 == 1) {
			R.player.velocity.x = -80;
			R.player.animation.play("wll");
		} else {
			R.player.velocity.x = 80;
			R.player.animation.play("wrr");
		}
	this.s1 = 11;
	}
} else if (this.s1 == 11) {
	
	//R.player.velocity.x = 80;
	var b = false;
	
	if (this.s2 == 0 && R.player.x > this.trigger.x + this.trigger.width + 16) {
		R.player.velocity.x = 0;
		R.player.animation.play("irn");
		R.player.facing = 0x0010;
		this.dialogue("nature", "g1_1_call_mayor", 12);
		this.s1 = 12;
	} else if (this.s2 == 1 && R.player.x < this.trigger.x - 16) {
		R.player.velocity.x = 0;
		R.player.animation.play("iln");
		R.player.facing = 0x0001;
		this.s1 = 12;
		this.dialogue("nature", "g1_1_call_mayor", 13);
	}
} else if (this.s1 == 12) {
	if (this.doff()) {
		this.s1 = 0;
		R.player.enter_main_state();
	}
}
