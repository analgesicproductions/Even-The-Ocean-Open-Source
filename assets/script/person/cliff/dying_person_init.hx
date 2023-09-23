//{ dying_person_init
//script s "person/cliff/dying_person_init.hx"
//}

if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	this.s2 = 0;
	this.has_trigger = true;
	this.make_trigger(this.x-88, this.y-48, 32, 80);
	//R.player.overlaps(this.trigger)
	
	/* Check for event */
	if (this.get_ss("cliff","dying_person_init",1) == 0) {
		
	} else {
		this.SCRIPT_OFF = true;
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
				this.dialogue("cliff", "dying_person_init", 0);
			}
		}
	} else if (this.s1 == 10 && this.doff()) {
		this.s1 = 1;
	} else if (this.s1 == 1 && this.doff()) {
		R.player.pause_toggle(false); 
		R.player.animation.play("wrr");
		R.player.velocity.x = 75;
		this.s1 = 2;
	} else if (this.s1 == 2) {
		//this.t_1++;
		if (R.player.x > this.trigger.x + 4*16) {
			//this.t_1 = 0;
			R.player.animation.play("irn");
			R.player.facing = 0x0010;
			this.s1 = 3;
			this.dialogue("cliff", "dying_person_init", 1);
		}
	} else if (this.s1 == 3 && this.doff()) {
		this.s2 = 1;
		this.set_ss("cliff", "dying_person_init", 1, 1);
		R.player.enter_main_state();
	}
} else if (this.s2 == 1 && this.doff()) {
}