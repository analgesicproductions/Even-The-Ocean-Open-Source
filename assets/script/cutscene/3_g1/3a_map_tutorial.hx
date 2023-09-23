if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	
	// DEBUG: turns this event on
	
	//this._trace("debug 3a map tut");
	//this.set_ss("city_i1", "debrief", 1, 1);
	//this.set_scene_state("city", "intro_yara", 1, 1);
	//this.set_scene_state("city", "aliph_map", 1, 1);
	//this.set_scene_state("city", "map_tut", 1, 1);
	
	this.s1 = -1;
	
	// beginning of game trigger's at fay rouge to tel you how to get back
	if (this.get_ss("city", "intro_yara", 1) == 0 && this.get_ss("city","aliph_map",1) == 0) {
		this.s1 = 10;
	} else if (this.get_scene_state("city", "intro_yara", 1) == 1 && this.get_scene_state("city", "map_tut", 1) == 0) {
		this.s1 = 0;
		// Bc we left the yara cutscene preivously which left us in cutscene state, and we aren't enteirng a platforming area which would reset us to main state. we need to do this so we can still pause
		R.player.enter_main_state();
		this.set_scene_state("city", "map_tut", 1, 1);
	// after g1_1, "Where pax and lop??"
	} else if (0 != this.get_ss("city_i1","debrief",1,1) && 0 == this.get_ss("city", "map_paxlop", 1)) {
		this.s1 = 20;
	} else {
		this.SCRIPT_OFF = true;
		this.only_visible_in_editor = true;
		return;
	}
	
	
	this.has_trigger = true;
	this.make_trigger(this.x-80, this.y, 160, 90);
}


if (this.s1 == 0) {
	if (this.trigger.overlaps(R.activePlayer)) {
		this.s1 = 1;
		this.dialogue("city", "map_tut", 0);
	}
} else if (this.s1 == 1 && this.doff()) {
	this.run_tutorial(7); // 3,4,5 = en, wall climb, wall jump
	this.s1 = 2;
} else if (this.s1 == 2) {
	if (this.tutorial_done()) {
		this.s1 = 3;
	}
} else if (this.s1 == 3) {
	
}
if (this.s1 == 20) {
	if (this.trigger.overlaps(R.activePlayer)) {
		this.s1 = 21;
		this.dialogue("city", "map_paxlop", 0);
		this.set_ss("city", "map_paxlop", 1, 1);
	}
} else if (this.s1 == 21 && this.doff()) {
	this.s1 = 22;
}

if (this.s1 == 10) {
	this.trigger.x = 94 * 16;
	this.trigger.y = 33 * 16;
	
	if (this.trigger.overlaps(R.activePlayer)) {
		this.s1 = 11;
		this.dialogue("city", "aliph_map", 0);
		this.set_ss("city", "aliph_map", 1, 1);
	}
} else if (this.s1 == 11 && this.doff()) {
		R.worldmapplayer.pause_toggle(true);
	this.run_tutorial(6);

	this.s1 = 12;
} else if (this.s1 == 12 && this.tutorial_done())
 {
 	this.dialogue("city","aliph_map",1);
 	this.s1 = 13;
 } else if (this.s1 == 13 && this.doff()) {
	 
		R.worldmapplayer.pause_toggle(false);
		this.s1 = 14;
 }