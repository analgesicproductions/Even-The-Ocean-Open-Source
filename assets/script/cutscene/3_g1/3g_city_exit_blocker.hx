// blocks leaving the city
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	
	// DEBUG: blocker for yara in intermission 1
	//this._trace("DEBUG 3g_city_exit_blocker: yara intermission 1");
	
	
	// Test going to library before yara after g1_1
	//this.set_scene_state("city_i1", "yara", 1, 0);
	//this.set_scene_state("city", "lib_talk_g1_1_first", 1, 1);
	//this.set_event(29, true);
	
	// Test leaving after yara but before library
	//this.set_scene_state("city_i1", "yara", 1, 1);
	//this.set_scene_state("city", "lib_talk_g1_1_first", 1, 0);
	//this.set_event(29, true);
	
	// AFter g1_1 done but before seeing bye bye yara scene
	
	//this._trace("DEBUG 3g_city_exit_blocker: INTRO");
	//this.set_scene_state("city", "city_aliph_after_mayor_intro", 1, 1);

	
	//this.set_ss("s3", "last_debrief", 1, 1);
	//this.play_music("rain");

	//this.set_ss("ending", "radio_end", 1, 1);
	//this.play_music("wf_after_tower");
	
	
	// You can leave whenever
	if (R.inventory.is_item_found(30)) {
	// Ending??	
		this._trace("City blocker off: Communicator item 30 found.");
		this.SCRIPT_OFF = true;
		this.only_visible_in_editor = true;
		return;
	} else if (this.get_ss("ending","radio_end",1) == 1) {
		this.s1 = 0;
		this.s2 = 53;
	} else if (this.get_ss("s3","last_debrief",1) == 1 && this.get_ss("ending", "radio_end", 1) == 0) {
		this.s1 = 0;
		this.s2 = 52;
	// Post g2_3 (Int 2?)
	} else if (this.get_event_state(39) && this.get_ss("i2","yara",1) == 0) {
		this.s1 = 0;
		this.s2 = 520;
		//this._trace(3);
	// Post G2_2  - end somehow?	
	} else if (this.get_event_state(38) && this.get_ss("g2_2","bed",1) == 0) {
		this.s1 = 0;
		//this._trace(2);
	// Post g2_1 (Paxtons DEATH)	
	} else if (this.get_event_state(37) && this.get_ss("g2_1", "aliph_apt", 1) < 1) {
		this.s1 = 0;
		//this._trace(4);
	// During Intermission 1, but havent atlked to yara to end the day
	} else if (this.get_event(31)  && this.get_scene_state("i_1", "yara", 1) == 0) {
		this.s1 = 0;
		this.s2 = 59;
		
	// g1_2 finished and havent talked 2 yhara yet
	} else if (this.get_event(30) && this.get_scene_state("city_g1_2", "yara", 1) == 0) {
		this.s1 = 0;
		
	// G1_1 finished and havent gone to library, but talked to yara/slept
	} else if (this.get_scene_state("city", "lib_talk_g1_1_first", 1) == 0 && this.get_scene_state("city_i1", "yara", 1) == 1 && this.get_event(29)) {
		this.s1 = 0;
		this.s2 = 1238;
		
	// G1_1 finished and haven't slept/talked to yara
	} else if (this.get_scene_state("city_i1", "yara", 1) == 0 && this.get_event(29)) {
		this.s1 = 0;
		
	// [INTRO] From after the mayor intro (when you get control to explore the city) till you see the final yara scene, 
	} else if (	this.get_ss("city", "city_aliph_after_mayor_intro", 1) == 1 && this.get_scene_state("city", "intro_yara", 1) == 0) {
		this.s1 = 0;
		this.s2 = 1;
	} else {
		this.SCRIPT_OFF = true;
		this.only_visible_in_editor = true;
		return;
	}
	this.has_trigger = true;
	this.make_trigger(this.x , this.y, 16, 64);
}


// run back to the right
if (this.s1 == 0) {
	if (this.trigger.overlaps(R.player)) {
		this.s1 = 1;
	}
} else if (this.s1 == 1) {
	if (this.player_freeze_help()) {
		R.player.pause_toggle(false);
		R.player.enter_cutscene();
		R.player.velocity.x = -80;
		R.player.animation.play("wll");
	this.s1 = 11;
	}
} else if (this.s1 == 11) {
	
	if (R.player.x < this.trigger.x- 20) {
		R.player.velocity.x = 0;
		R.player.animation.play("iln");
		R.player.facing = 0x001;
		if (this.s2 == 0) {
			this.dialogue("city_i1", "leave", 0);
		} else if (this.s2 == 1) {
			this.dialogue("city", "map_tut", 1);
		} else if (this.s2 == 59) {
			// After g1_3. say hi 2 yara
			this.dialogue("city_i1", "leave", 1);
		} else if (this.s2 == 52) {
			this.dialogue("i2", "city_blocker", 0);
		} else if (this.s2 == 520) {
			this.dialogue("i2", "city_blocker", 1);
		} else if (this.s2 == 53) {
			this.dialogue("ending", "blocker", 0);
		} else if (this.s2 == 1238) {
			this.dialogue("city", "map_tut", 2);
		}
		this.s1 = 12;
	}
} else if (this.s1 == 12) {
	if (this.doff()) {
		this.s1 = 0;
		R.player.enter_main_state();
	}
}
