//{ cliff_last_sign
//script s "person/cliff/last_sign.hx"
//}

if (!this.child_init) {
	this.child_init = true;
	//this.only_visible_in_editor = true;
	this.s1 = 0;
	this.s2 = 0;
	this.has_trigger = true;
	this.make_trigger(this.x-8, this.y-48, 32, 80);
	//R.player.overlaps(this.trigger)
	
	/* Check for event */
	if (this.get_ss("cliff","last_sign",1) == 0) {
	} else {
		this.s2 = 1;
	}

	// Don't play default (cliffambient) till you finish all the scenes/
	if (this.get_ss("cliff", "incense", 1) == 0) {
		this.play_music("earth_boss");
	}
}

// Do stuff

if (this.s2 == 0) {
	if (this.s1 == 0) {
		if (R.player.overlaps(this.trigger) || this.s3 == 1) {
			this.s3 = 1;
			if (this.player_freeze_help()) {
				R.player.enter_cutscene();
				R.player.animation.play("irn");
				this.s1 = 10;
				this.dialogue("cliff", "last_sign", 0);
			}
		}
	} else if (this.s1 == 10 && this.doff()) {
		this.dialogue("cliff", "last_sign", 1);
		this.s1 = 1;
	} else if (this.s1 == 1 && this.doff()) {
		R.player.pause_toggle(false); 
		R.player.animation.play("wll");
		R.player.velocity.x = -75;
		this.s1 = 2;
	} else if (this.s1 == 2) {
		this.t_1++;
		if (this.t_1 > 30) {
			this.t_1 = 0;
			R.player.animation.play("iln");
			R.player.facing = 0x0001;
			this.s1 = 3;
			this.dialogue("cliff", "last_sign", 2);
		}
	} else if (this.s1 == 3 && this.doff()) {
		this.s2 = 1;
		this.set_ss("cliff", "last_sign", 1, 1);
		R.player.enter_main_state();
	}
} else if (this.s2 == 1 && this.doff()) {
	if (this.try_to_talk(0, this, true)) {
		this.dialogue("cliff", "last_sign", 0);
	}
}