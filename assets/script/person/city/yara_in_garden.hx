//{ yara_in_garden
if (!this.child_init) {
	this.child_init = true;
	this.s1 = 0;
	this.s2 = 0;
	this.only_visible_in_editor = true;
	/* [Debug function description] */
	//this._trace("DEBUG yara_in_garden before g2_1 fight");
	//this.set_ss("g2_1", "hi_res", 1, 1);
	//this.set_ss("g2_1", "yara", 1, 0);
	
	//this._trace("DEBUG yara_in_garden before end-of_I_1");
	//this.set_event(31, true); 
	
	
	//public static inline var g1_1_DONE:Int = 29;
	//public static inline var g1_2_DONE:Int = 30;
	//public static inline var g1_3_DONE:Int = 31;
	
	
	//public static inline var g2_1_DONE:Int = 37;
	//public static inline var g2_2_DONE:Int = 38;
	//public static inline var g2_3_DONE:Int = 39;
	
	//public static inline var g3_1_DONE:Int = 43;
	//public static inline var g3_2_DONE:Int = 44;
	//public static inline var g3_3_DONE:Int = 45;
	
		//this._trace("debug yaraingarden");
		//this.set_scene_state("city", "intro_yara", 1, 1);
		
		
		//this._trace("debug yaraingarden");
	//this.set_scene_state("city_g1_2", "yara", 1, 1);
		
	//this._trace("debug yaraingarden safter g1_1");
	//this.set_scene_state("city_i1", "yara", 1, 1);
	//this.set_event(31,false);
	
	// Before end-of-I_1 talk
	if (this.get_event(31) && this.get_scene_state("i_1", "yara", 1) == 0) {
		this.s3 = 3;
		
	// After end-of-I_1 talk, before G2_1 finished
	} else if (this.get_scene_state("i_1", "yara", 1) == 1 && !this.get_event(37)) {
		this.s3 = 10;
		this.s2 = 2;
		
	// after g2_1: activate fight scene.
	} else if (this.get_ss("g2_1", "hi_res", 1) == 1 && this.get_ss("g2_1", "yara", 1) == 0) {
		this.s3 = 5; // What event
		
	// After intro thing, before g1_1 done
	} else if (this.get_ss("city","intro_yara",1) > 0 && !this.get_event(29)) {
		this.s3 = 10;
		this.s2 = -1;
		
		
	// after g1_1 yara scene, before g1_2 done
	} else if (this.get_ss("city_i1", "yara", 1) > 0 && !this.get_event(30)){
		this.s3 = 10;
		this.s2 = 0;
	// after g1_2 yara scene, before g1_3 done
	} else if (this.get_ss("city_g1_2", "yara", 1) > 0 && !this.get_event(31)) {
		this.s3 = 10;
		this.s2 = 1;
	// After I2 fight, but before leaving?
	} else if (this.get_ss("i2", "yara", 1) > 0 && !this.get_event(43)) {
		this.s3 = 11;
	// for trigger flood?
	} else if (false) {
		
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	
	this.make_child("yara", false, "dig");
	
	
	if (this.s3 == 3) {
		this.set_vars(this.sprites.members[0], this.x, this.y, 1);
	}
	
	if (this.s3 == 5) {
		this.set_vars(this.sprites.members[0], this.x, this.y, 1);
	}

	// Disabled for now - yara's idling.
	if (this.s3 == 10 || this.s3 == 11) {
		this.set_vars(this.sprites.members[0], this.x, this.y, 0);
		this.SCRIPT_OFF = true;
		return;
	}
	this.sprites.members[0].y -= 24;
	this.sprites.members[0].x += 8;
	this.sprites.members[0].height += 24;
}
var yara = this.sprites.members[0];


// Yara I_1 (before G2_1) i1 
if (this.s3 == 3) {
	if (this.s1 == 0) {
		if (this.try_to_talk(0, yara)) {
			this.s1 = 1;
			R.player.energy_bar.OFF = true;
			yara.animation.play("dig_idle");
			this.dialogue("i_1", "yara", 0,false);
		}
	} else if (this.s1 == 1) {
		if (this.doff()) {
			R.easycutscene.activate("1f_yara_3");
			this.s1 = 2;
		}
	} else if (this.s1 == 2) {
		if (R.easycutscene.ping_last) {
			R.actscreen.activate(3, this.parent_state);
			this.s1 = 3;
		}
	} else if (this.s1 == 3) {
		if (R.actscreen.is_off()) {
			this.change_map("WF_ALIPH", 1, 1, true);
			this.set_scene_state("i_1", "yara", 1, 1);
			this.s1 = 4;
		}
	}
	return;
}
// end Yara I_1





// Yara G2_1 fight. After Mayor shows you the apartment.
if (this.s3 == 5) {

if (this.s1 == 0) {
	if (this.try_to_talk(0, yara)) {
		this.s1 = 1;
		R.player.energy_bar.OFF = true;
		this.dialogue("g2_1", "yara_defaults", 0);
		yara.animation.play("dig_idle");
	}
} else if (this.s1 == 1) {
	if (this.d_last_yn() == 1) {
		this.s1 = 2;
	} else if (this.doff()) {
		yara.animation.play("dig");
		R.player.energy_bar.OFF = false;
		this.s1 = 0;
	}
} else if (this.s1 == 2) {
	if (this.doff()) {
		this.dialogue("g2_1", "yara", 0);
		this.s1 = 3;
		this.set_ss("g2_1", "yara", 1, 1);
		
		//debug
		//this.set_ss("g2_1", "hi_res", 1, 1);
	}
} else if (this.s1 == 3) {
	if (this.doff()) {
		R.TEST_STATE.dialogue_box.speaker_always_none = true;
		R.player.enter_cutscene();
		R.easycutscene.activate("2c_yarafight");
		this.s1 = 4;
	}
} else if (this.s1 == 4) {
	if (R.easycutscene.ping_last) {
		this.s1 = 5;
		this.change_map("WF_ALIPH2", 10, 20, true);
	}
}
}

//set 1 idling
if (this.s3 == 10) {
	if (this.s1 == 0) {
		if (this.try_to_talk(0, yara)) {
			this.s1 = 1;		
			yara.animation.play("dig_idle");
			if (this.s2 == -1) {
				this.dialogue("g2_1", "yara_garden_intro", 0);
			} else if (this.s2 == 0) {
				this.dialogue("g2_1", "yara_garden_intro_g1_1", 0);
			} else if (this.s2 == 1) {
				this.dialogue("g2_1", "yara_garden_intro_g1_2", 0);
			} else if (this.s2 == 2) {
				this.dialogue("g2_1", "yara_garden_intro_i1", 0);
			}
		}
	} else if (this.s1 == 1) {
		if (this.doff()) {
			yara.animation.play("dig");
			this.s1 = 0;
		}
	}
}

//idling before leaving after I2
if (this.s3 == 11) {
	if (this.s1 == 0) {
		if (this.try_to_talk(0, yara)) {
			this.s1 = 1;
			this.dialogue("g2_1", "yara_garden_post_i2", 0);
		}
	} else if (this.s1 == 1) {
		if (this.doff()) {
			this.s1 = 0;
		}
	}
}