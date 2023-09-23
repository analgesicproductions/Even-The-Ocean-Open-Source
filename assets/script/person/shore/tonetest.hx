//if (this.try_to_talk()) {
	//if (R.inventory.is_item_found(11) == false) {
		//this.dialogue("shore", "angry_lounger", 0);
	//} else {
		//this.dialogue("shore", "angry_lounger", 1);
	//}
//}

if (!this.child_init) {
	this.SCRIPT_OFF = true;
	return;
	this.child_init = true;
	this.s1 = 0;
	this.play_music("null");
	this.energy_bar_move_set(false, true);
	this.only_visible_in_editor = true;
	R.player.energy_bar.dont_move_cutscene_bars = true;	
}

if (this.s1 == 0) {
	if (R.input.jpSit) {
		this.s1 = 1;
	}
} else if (this.s1 == 1) {
	if (R.input.jpA1) {
		this.s1 = 2;
		this.dialogue("test", "shore_clip", 0);
	this.energy_bar_move_set(false, true);
	}
} else if (this.s1 == 2 && this.doff()) {
	if (R.input.jpSit) {
		this.s1 = 3;
	}
} else if (this.s1 == 3) {
	if (R.input.jpSit) {
		
		R.TEST_STATE.cutscene_handle_signal(0, [0.01]);
		this.s1 = 4;
	}
} else if (this.s1 == 4 && R.TEST_STATE.cutscene_just_finished(0)) {
	this.dialogue("test", "shore_clip", 1);
	this.s1 = 5;
}




