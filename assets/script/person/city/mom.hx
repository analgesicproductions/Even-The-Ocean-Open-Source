//{ aloe
if (!this.child_init) {
	this.child_init = true;
	this.s1 = 0;
	
	//this._trace("mom debug");
	//this.set_ss("i2", "cart_init", 1, 1);
	//this.set_ss("i_1", "debrief", 1, 1);
	//this.set_event(37);
	
	if (this.get_ss("i2", "cart_init", 1) != 0) {
			this.s2 = 2;
	// in set 2
	} else if (this.get_scene_state("i_1", "debrief", 1) > 0) {
			this.s2 = 1;	
	// in set 1 or before
	} else {
		this.s2 = 0;
	}
}

// doesnt do complicated stuff atm, maybe ever
if (this.s1 == 0) {
	if (this.try_to_talk()) {
		if (this.s2 == 0) {
			this.dialogue("overworld", "mom", 0);
		} else if (this.s2 == 1) {
			this.dialogue("overworld", "mom", 7);
		} else {
			this.dialogue("overworld", "mom", 12);
		}
		this.s1 = 1;
	}
} else if (this.s1 == 1) {
	if (this.doff()) {
		if (this.s2 == 0) {
			this.s1 = 2;
			R.player.enter_cutscene();
		R.TEST_STATE.cutscene_handle_signal(0, [0.01]);
		} else {
			this.s1 = 0;
		}
	}
} else if (this.s1 == 2) {
	if (R.TEST_STATE.cutscene_just_finished(0)) {
		this.s1 = 3;
	}
} else if (this.s1 == 3) {
		this.t_1 ++;
		if (this.t_1 == 90) {
		R.TEST_STATE.cutscene_handle_signal(2, [0.01]);
		this.s1 = 4;
		this.t_1 = 0;
		}
} else if (this.s1 == 4) {
	if (R.TEST_STATE.cutscene_just_finished(2)) {
		this.s1 = 5;
			R.player.enter_main_state();
			this.dialogue("overworld", "mom", 3);
	}
} else if (this.s1 == 5) {
	if (this.doff()) {
		
		R.achv.unlock(R.achv.mom);
		this.s1 = 6;
	}
} else if (this.s1 == 6) {
	if (this.try_to_talk() && this.doff()) {
		this.dialogue("overworld", "mom2", 0);
	}
}
