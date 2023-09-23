
if (R.editor.editor_active) {
	this.debug_name.visible = true;
} else {
	this.debug_name.visible = false;
}
// bay outside. show up only if you saw the other memory
if (!this.child_init) {
	this.child_init = true;
	this.visible = false;
}
if (this.s1 == 0) {
	if (this.context_values[0] ==0) { // Location B1
		if (this.get_scene_state("hill", "soup_memory", 1) == 2) {
			this.visible = true;
		}
	} else { // Location B2
		if (this.get_scene_state("hill", "soup_memory", 1) == 1) {
			this.visible = true;
		}
	}
	if (this.get_scene_state("hill", "bay_outside", 1) == 1) {
		this.visible = false;
		return;
	}
	if (this.visible) {
		this.s1 = 1;
	}
} else if (this.s1 == 1) {
	if (this.try_to_talk()) {
		this.dialogue("hill", "bay_outside", 0);
		this.s1 = 2;
	}
} else if (this.s1 == 2) {
	if (!this.dialogue_is_on()) {
		
		R.TEST_STATE.cutscene_handle_signal(0, [0.01]);
		R.player.enter_cutscene();
		this.s1 = 3;
	}
} else if (this.s1 == 3) {
	if (R.TEST_STATE.cutscene_just_finished(0)) {
		this.s1 = 4;
		this.visible = false;
		this.y = -500;
	}
} else if (this.s1 == 4) {
		this.t_1 ++;
	if (this.t_1 == 60) {
		this.s1 = 5;
		R.TEST_STATE.cutscene_handle_signal(2, [0.01]);
	}
} else if (this.s1 == 5) {
	if (R.TEST_STATE.cutscene_just_finished(2)) {
		this.s1 = 6;
		R.player.enter_main_state();
		this.set_scene_state("hill", "bay_outside", 1, 1);
		if (this.get_scene_state("hill", "trent_outside", 1) == 1) {
			this.dialogue("hill", "aliph_after_finding", 0);
		}
	}
}