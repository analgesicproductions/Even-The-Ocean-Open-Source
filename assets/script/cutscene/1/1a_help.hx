if (!this.child_init) {
	this.child_init = true;
	this.has_trigger = true;
	this.make_trigger(this.x, this.y, 50, 32);
	this.only_visible_in_editor = true;
	
	if (this.get_scene_state("intro", "intro_tutorial_popup", 1) == 1) {
		this.s1 = -1;
		return;
	}
}

if (this.s1 == 0) {
	if (R.player.overlaps(this.trigger)) {
		this.s1 = 1;
		//R.player.energy_bar.dont_move_cutscene_bars = true;
		R.player.energy_bar.force_set_cutscene_bar();
		this.set_scene_state("intro", "intro_tutorial_popup", 1, 1);	
	}
} else if (this.s1 == 1) {
	if (this.player_freeze_help()) {
		this.dialogue("intro", "intro_tutorial_popup", 0,false,false);
		this.s1 = 2;
	}
} else if (this.s1 == 2) {
	if (!this.dialogue_is_on()) { // Yes or No to seeing first tutorial
		//if (this.d_last_yn() == 0) {
			this.s1 = 3;
			this.run_tutorial(1);
		//} else {
			//this.s1 = 4;
		//}
	}
} else if (this.s1 == 3) {
	if (this.tutorial_done()) {
		this.s1 = 4;
	}
} else if (this.s1 == 4) {
	R.player.enter_main_state();
	R.there_is_a_cutscene_running = false;
	this.energy_bar_move_set(true, false);
	//this.dialogue("intro", "intro_tutorial_popup", 1);
	this.s1 = 5;
}else if (this.s1 == 5) {
	//if (!this.dialogue_is_on()) {
		this.s1 = 6;
	//}
}






