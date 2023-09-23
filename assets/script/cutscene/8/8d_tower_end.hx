if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.width = 32;
	this.s1 = 0;
	this.s2 = 0;
	// Top of the Radio Tower at ending. idk if this needs anything. boss stuff?
	//if (this.context_values[0] == 1) {
		//
	//}
	//this._trace("DEBUG 8d_tower_end");
	//this.context_values[0] = 2;
	//this.set_ss("ending", "radio_end", 1, 0);
	
	//this.SCRIPT_OFF = true;
	if (this.get_ss("ending", "radio_end", 1) == 0) {
		
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
}

if (this.s1 == 0) {
	if (this.try_to_talk(0, this)) {
		this.s1 = 1;
		this.checkpoint_off();
		R.player.energy_bar.dont_move_cutscene_bars = true;
		this.dialogue("ending", "enter_tower", 2, false);
	}
} else if (this.s1 == 1) {
	if (this.doff()) {
		
		R.player.energy_bar.exit_extremes();
	this.do_laser_game(0);
	this.s1 = 2;
	}
} else if (this.s1 == 2) {
	if (this.do_laser_game(1)) {
		this.do_laser_game(2);
		this.dialogue("ending", "enter_tower", 1, false);
		this.s1 = 3;
	}
} else if (this.s1 == 3) {
	if (this.doff()) {
		this.energy_bar_move_set(true);
		this.s1 = 100;
		R.player.enter_cutscene();
		//R.player.pause_toggle(true);
		R.easycutscene.activate("4c_fall");
		// cutscene needs to end on a fade..
	}
} else if (this.s1 == 100 && R.easycutscene.ping_last) {
	if (this.context_values[0] == 2) {
		//R.easycutscene.ping_last = false;
		this.s1 = 4;
	//R.player.pause_toggle(false);
		R.player.enter_main_state();
		//this.dialogue("ending", "radio_end", 0);
		this.set_ss("ending", "radio_end", 1, 1);
		this.set_event(47, true); // Set to 'true'
		//R.song_helper.permanent_song_name = "wf_after_tower";
		//this.play_music("wf_after_tower",false);
	}
} else if (this.s1 == 4 && this.doff()) {
	this.change_map("WF_HI_1", 35, 22, true);
	if (R.gauntlet_mode) {
		R.song_helper.permanent_song_name = "";
		this.change_map("GM_1", 132, 13, true);
	}
	this.s1 = 5;
} else if (this.s1 == 5 && this.doff()) {
}
