if (!this.child_init) {
	this.child_init = true;
	this.s1 = 0;
	
	
	if (this.get_ss("overworld", "lopez", 1) == 1) {
		this.s1 = 6;
	}
}

// doesnt do complicated stuff atm, maybe ever
if (this.s1 == 0) {
	if (this.try_to_talk()) {
		if (this.s2 == 0) {
			this.dialogue("overworld", "lopez", 2);
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
		}
} else if (this.s1 == 4) {
	if (R.TEST_STATE.cutscene_just_finished(2)) {
		this.s1 = 5;
			R.player.enter_main_state();
			this.dialogue("overworld", "lopez", 4);
			this.set_ss("overworld", "lopez", 1, 1);
	}
} else if (this.s1 == 5) {
	if (this.doff()) {
		this.s1 = 6;
		R.achv.unlock(R.achv.findLopez);
	}
} else if (this.s1 == 6) {
	if (this.try_to_talk()) {
		this.dialogue("overworld", "lopez", 8);
	}
}
