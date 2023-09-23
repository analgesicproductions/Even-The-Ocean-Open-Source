
if (!this.child_init) {
	this.child_init = true;
	this.s1 = 0;
	//R.set_flag_bitwise(46, 0x001);
	//R.set_flag_bitwise(46, 0x010);
	//R.set_flag_bitwise(46, 0x100);
	
	//this._trace("debug jane");
	//this.set_ss("pass", "jane_init", 1, 0);
	
	
	//this.set_event(17);
	// earth done
	
	// Events: After geyser stuff, talking takes you to picnic where you're forced to go and finish golem
	// States: 0 - normal talking in beginning, 1 - after geyser stuff, 2 = after golem
	
	this.s2 = 0;
	
	if (this.event(17)) {
		this.s1 = 2;
	} else if (0x111 == this.get_event_state(46, true)) {
		this.s1 = 1;
	} else {
		// Saw first mandatory scene, go to idle chat
		if (this.get_ss("pass", "jane_init", 1) == 1) {
			this.s2 = 8;
		} else {
			
		}
	}
}

if (this.s1 == 0) {
	if (this.s2 == 0) { 
		if (R.player.x > this.x - 100 && R.player.x < this.x) {
			this.s2 = 1;
			this.set_ss("pass", "jane_init", 1, 1);
		}
	} else if (this.s2 == 1) { 
		if (this.player_freeze_help()) {
			this.s2 = 2;
			this.dialogue("pass", "jane_init", 0);
		}
	} else if (this.s2 == 2 && this.doff()) { 
		R.player.enter_cutscene();
		R.player.velocity.x = 80;
		this.s2 = 3;
		R.player.animation.play("wrr");
	} else if (this.s2 == 3) { 
		if (R.player.x > this.x - 40) {
			R.player.animation.play("irn");
			R.player.velocity.x = 0;
			this.dialogue("pass", "jane_init", 1);
			this.s2 = 7; 
		}
	} else if (this.s2 == 7 && this.doff()) {
		
		R.player.enter_main_state();	
		//this.camera_to_player(true);	
		//R.player.facing = 0x0010;
		this.s2 = 8;
	} else {
		if (this.doff() && this.try_to_talk()) {
			this.dialogue("pass", "jane_1", 0);
		}
	}
} else if (this.s1 == 1) {
	if (this.s2 == 2) {
		if (this.doff()) {
			// Change to the picnic scene
			R.player.enter_cutscene();
			this.change_map("PASS_2", 462, 272);
			this.s1 = 3;
			R.gs1 = 1; // set for use in picnic.hx
		}
	} else if (this.s2 == 1) {
		this.s2 = 2;
	} else {
		if (this.doff() && this.try_to_talk()) {
			this.s2 = 1;	
			this.dialogue("pass", "jane_2", 0);
		}
	}
} else if (this.s1 == 2) {
	if (this.try_to_talk()) {
		this.dialogue("pass", "jane_post_golem");
	}
}