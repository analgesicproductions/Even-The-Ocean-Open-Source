
if (!this.child_init) {
	this.child_init = true;
	this.s1 = 0;
	return;
}

if (this.s1 == 0) {
	if (this.try_to_talk()) {
		this.s1 = 2;
		this.dialogue("ui", "acttest", 0);
	}
}
if (this.s1 == 2) {
	if (this.d_last_yn() != -1) {
		
		if (this.t_1 == 0) {
			R.TEST_STATE.cutscene_handle_signal(0, [0.1]);
			this.s2 = this.d_last_yn();
			R.player.enter_cutscene();
		}
		this.t_1++;
	}
	//if (this.t_1 > 60) {
	if (R.TEST_STATE.cutscene_just_finished(0)) {
		R.actscreen.activate(this.s2, this.parent_state);
		this.s1 = 3;
	}
} else if (this.s1 == 3) {
	if (R.actscreen.is_off()) {
		R.TEST_STATE.cutscene_handle_signal(2, [0.11]);
		this.s1 = 4;
	}
} else if (this.s1 == 4) {
	if (R.TEST_STATE.cutscene_just_finished(2)) { 
		this.s1 = 0;
		this.t_1 = 0;
		R.player.enter_main_state();
	}
}