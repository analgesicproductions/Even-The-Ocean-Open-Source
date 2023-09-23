//{ s2_nature_blocker
// blocks leaving the 2nd 3 areas
// blocks ENTERING the set 3 areas if you dont have bombs
// blocks entering set 2 areas if you didnt pass intermison 1
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.has_trigger = true;
	this.make_trigger(this.x , this.y, 32, 128);
	this.s1 = -1;
	this.s2 = 0;
	//this._trace("DEBUG 4_nature_blocker");
	//this.set_ss("i_1", "gate_exit", 1, 1);
	//R.inventory.set_item_found(0, 25, true);	
	return;
}

// run back to the right
if (this.s1 == -1) {
	
	// 23/24/25 earth air sea bombs
	if (R.TEST_STATE.MAP_NAME == "PASS_1" && !R.inventory.is_item_found(23)) {
		this.s1 = 0;
		this.s2 = 2;
	} else if (R.TEST_STATE.MAP_NAME == "FALLS_1") {
		if (!R.inventory.is_item_found(25)) {
			this.s1 = 0;
			this.s2 = 2;
		} else {
			this.SCRIPT_OFF = true;
		}
	} else if (R.TEST_STATE.MAP_NAME == "CLIFF_1" && !R.inventory.is_item_found(24)) {
		this.s1 = 0;
		this.s2 = 2;
	} else if (this.get_ss("g2_3", "checkin", 1) == 1 && !this.get_event(39)) {
		this.s1 = 0;	
	} else if (this.get_ss("g2_2", "checkin", 1) == 1 && !this.get_event(38)) {
		this.s1 = 0;
	} else if (this.get_ss("g2_1", "checkin", 1) == 1 && !this.get_event(37)) {
		this.s1 = 0;
	} else if (this.get_ss("i_1", "gate_exit", 1) == 0) { //  enter too early
		this.s1 = 0;
		this.s2 = 1;
	} else {
		this.trigger.alpha = 0;
		//this.s1 = -100;
		//this.SCRIPT_OFF = true;
	}
}  else if (this.s1 == 0) {
	this.trigger.alpha = 0.7;
	if (this.trigger.overlaps(R.player)) {
		this.s1 = 1;
		
	}
} else if (this.s1 == 1) {
	if (this.player_freeze_help()) {
		if (this.s2 == 1) {
			this.dialogue("g2_2", "checkin", 4);
		} else if (this.s2 == 2) {
			this.dialogue("s3", "no_bomb_area_enter", 0);
			this.s2 = 1;
			if (R.TEST_STATE.MAP_NAME == "CLIFF_1") {
				this.s2 = 0;
			}
		} else {
			this.dialogue("g2_2", "checkin", 3);
		}
		this.s1 = 11;
	} 
} else if (this.s1 == 11 && this.doff()) {
	R.player.pause_toggle(false);
	R.player.enter_cutscene();
	R.player.velocity.x = 80;
	if (this.s2 == 1) R.player.velocity.x *= -1;
	R.player.animation.play("wrr");
	if (this.s2 == 1) R.player.animation.play("wll");
	this.s1 = 12;
} else if (this.s1 == 12) {
	if (this.s2 == 0 && R.player.x > this.trigger.x + this.trigger.width + 24) {
		R.player.velocity.x = 0;
		R.player.animation.play("irn");
		R.player.facing = 0x0010;
		this.s1 = 13;
	}
	if (this.s2 == 1 && R.player.x < this.trigger.x - 32) {
		R.player.velocity.x = 0;
		R.player.animation.play("iln");
		R.player.facing = 0x0001;
		this.s1 = 13;
	}
} else if (this.s1 == 13) {
	if (this.doff()) {
		this.s1 = -1;
		R.player.enter_main_state();
	}
}
