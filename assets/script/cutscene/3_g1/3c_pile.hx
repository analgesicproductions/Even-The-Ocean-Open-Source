// Golem spore pilesin g1_1
if (!this.child_init) {
	this.child_init = true;
	this.s1 = -1;
	
	if (R.TEST_STATE.MAP_NAME.indexOf("SHORE") != -1) {
		this.s3 = 1;
		this.animation.play("shore");
	} else if (R.TEST_STATE.MAP_NAME.indexOf("CANYON") != -1) {
		this.s3 = 2;
		this.animation.play("canyon");
	} else {
		this.s3 = 3;
		this.animation.play("hill");
	}
	
	// DEBUG: turns this event on
	
	// for reference
	//public static inline var g1_1_DONE:Int = 29;
	
	//// DEBUG
	//this._trace("g");
	//R.inventory.set_item_found(0, 16);
	//this.set_event(29, true);
	
	var g1_1_done = this.get_event_state(29);
	var g1_2_done = this.get_event_state(30);
	
	
	this.has_trigger = true;
	this.make_trigger(this.x, this.y-this.height, 20, 64);
	
	if (g1_2_done) {
		this.s1 = 200;
	} else if (g1_1_done) {
		// Either play a "I've seen this before"( if this is where g1_1 was), or do the 2nd message thingy
		this.s1 = 100;
	} else {
		this.s1 = -2;
		return;
	}
	
}

if (this.s1 == -2) {
	// if unseen, auto-play first thing
	if (this.get_scene_state("nature", "g1_1_pile", 1) == 0) {
		if (this.context_values[0] == 1) {
			this.s1 = 0;
		} else {
			this.s1 = -1;
		}
	} else {
		this.s1 = 0;
	}
} else if (this.s1 == -1) {
	
	if (this.s2 == 1) {
		if (this.player_freeze_help()) {
			this.set_scene_state("nature", "g1_1_pile", 1, 1); // blah blah blah
			this.dialogue("nature", "g1_1_pile", 0,false);
			this.s1 = 1;
		}
		return;
	}
	if (this.trigger.overlaps(R.player)) {
		this.s2 = 1;
	} 
}

if (this.s1 == 0) {
	if (this.doff()) {
		if (this.try_to_talk(0, this)) {
			if (this.context_values[0] == 1) { // Secondary pile, say fixed message
				this.dialogue("nature", "g1_1_pile", 6);
			} else {
				if (this.get_scene_state("nature", "g1_1_pile", 1) == 1) { // Say end message if mmain pile
					this.dialogue("nature", "g1_1_pile", 5);
				} 
			}
		}
	}
	// play the "this is mad eof.."
} else if (this.s1 == 1) {
	if (this.doff()) {
		if (this.s3 == 1) {
			this.dialogue("nature", "g1_1_pile", 1,false);
		} else if (this.s3 == 2) {
			this.dialogue("nature", "g1_1_pile",2,false);
		} else if (this.s3 == 3) {
			this.dialogue("nature", "g1_1_pile", 3,false);
		}
		this.s1 = 2;
	}
} else if (this.s1 == 2 && this.doff()) {
	this.dialogue("nature", "g1_1_pile", 4);
	this.s1 = 0;
}



// decide if need to autoplay for first time or not
if (this.s1 == 100) {
	var g1_1_id = this.get_event(26, true);
	var ok = false;
	if (R.TEST_STATE.MAP_NAME.indexOf("SHORE") != -1 && g1_1_id == 1) {
		ok = true;
	} else if (R.TEST_STATE.MAP_NAME.indexOf("CANYON") != -1 && g1_1_id == 2) {
		ok = true;
	} else if (R.TEST_STATE.MAP_NAME.indexOf("HILL") != -1 && g1_1_id == 3) {
		ok = true;
	}
	if (ok) {
		this.state_1 = 1;
		this.s1 = 102;
		return;
	}
	
	if (this.context_values[0] != 1 && this.get_scene_state("nature_g1_2", "g1_2_pile", 1) == 0) {
		this.s1 = 101;
	} else {
		this.s1 = 102;
	}
} else if (this.s1 == 101) {
	if (this.s2 == 1) {
		if (this.player_freeze_help()) {
			this.set_scene_state("nature_g1_2", "g1_2_pile", 1, 1); // blah blah blah
			this.dialogue("nature_g1_2", "g1_2_pile", 1);
			this.s1 = 102;
		}
		return;
	} 
	if (this.trigger.overlaps(R.player)) {
		this.s2 = 1;
	}
} else if (this.s1 == 102) {
	if (this.doff() && this.try_to_talk(0, this)) {
		
		// In g1_1, play this message instead
		if (this.state_1 == 1) {
			this.dialogue("nature_g1_2", "g1_2_pile", 0);
			return;
		}
		
		if (this.context_values[0] == 1) { // Secondary pile, say fixed message
			this.dialogue("nature_g1_2", "g1_2_pile", 4);
		} else {
			if (this.get_scene_state("nature_g1_2", "g1_2_pile", 1) == 1) { // Say end message if mmain pile
				this.dialogue("nature_g1_2", "g1_2_pile", 4);
			} 
		}
	}
}

if (this.s1 == 200) {
	if (this.try_to_talk(0, this)) {
		this.dialogue("nature_g1_3", "pile", 0);
		this.s1 = 201;
	}
} else if (this.s1 == 201 && this.doff()) {
	this.s1 = 200;
}