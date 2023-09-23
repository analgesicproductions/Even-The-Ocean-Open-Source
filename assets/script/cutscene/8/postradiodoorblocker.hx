//this._trace(R.ignore_door);
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	
	// TODO..
	//this.set_ss("ending", "radio_end", 1, 1);
	
	if (this.event(50) || this.get_ss("ending","radio_end",1) == 0) {
		this._trace("post-radio blocker OFF because ending seen, or before finishing radio.");
		this.SCRIPT_OFF = true;
		return;
	}
	
	R.ignore_door = true;
	
}


if (this.s1 == 0) {
	
	if (this.dialogue_is_on()) {
		R.attempted_door = "";
		return;
	}
	
	if (R.attempted_door != null && R.attempted_door.length > 1) {
		
		if (R.TEST_STATE.MAP_NAME == "WF_HI_1") {
			if (R.attempted_door != "WF_TRAIN_HI") {
				this.dialogue("ending","blocker",1);		
			} else {
				this.dialogue("ending","blocker",2);		
				this.s1 = 2;
				return;
			}
		} else if (R.TEST_STATE.MAP_NAME == "WF_LO_0") {
			if (R.attempted_door != "WF_TRAIN_LO") {
				this.dialogue("ending","blocker",1);		
			} else {
				this.change_map("WF_TRAIN_LO", 0, 0);
			}
		} else {
			// n/a
		}
		
		R.attempted_door = "";
		this.s1 = 1;
	}
} else if (this.s1 == 2) {
	if (this.doff()) {
		this.change_map("WF_LO_1", 42,13,true);
		this.s1 = 3;
	}
} else if (this.s1 == 1 && this.doff() && !R.input.a2) {
		R.attempted_door = "";
	this.s1 = 0;
}