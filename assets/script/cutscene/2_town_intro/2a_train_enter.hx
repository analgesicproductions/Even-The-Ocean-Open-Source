/* UNUSED AS OF 2015-11-13 */

//this._trace([this.s1, this.s2, this.s3]);
if (!this.child_init) {
	this.only_visible_in_editor = true;
	this.make_child("city_train", false, "move");
	this.make_child("city_pic", false); 
	this.make_child("tiny_train", false); 
	this.s1 = -1;
	this.s2 = 0;
	this.s3 = -1;
	
	
	// this.s1 = 1 -> Go straight to moving train
	// DEBUG
	//this.set_scene_state("city", "funeral_speech", 1, 1);
	
	if (R.TEST_STATE.MAP_NAME != "WF_LO_0") {
			this.s1 = 1;
			this.s2 = 100;
	} else {
	
		//this._trace("debug 2a_train_enter");
		//this.set_ss("intro","map",1,1);
		
		// After G1_1 is done
		//if (this.get_event(29) && 1 != this.get_scene_state("city_i1", "debrief", 1)) {
			//this.s1 = 1;
			//this.s3 = 1;
		//} else if (this.get_scene_state("city", "funeral_speech", 1) == 1) {
		if (this.get_scene_state("city", "funeral_speech", 1) == 1) {
			this.SCRIPT_OFF = true;
			return;
			//if (this.get_scene_state("city", "mayor_intro", 1) == 0) {
				//this.s1 = 1;
				//this.s3 = 1; // Go to mayor
			//}
		// First time visiting city.
		} else if (this.get_scene_state("city", "train_enter", 1) == 0 && this.get_scene_state("intro", "map", 1) == 1) {
			
			this.cam_to_id(1);
			this.s1 = 0;  // play intro dialogue
			this.s3 = 0; // play the effect
			this.set_scene_state("city", "train_enter", 1, 1);
			R.TEST_STATE.cutscene_handle_signal(5); // Put dialogue box on top
			R.TEST_STATE.skip_fade_lighten = true;
			
			R.player.enter_cutscene();
			this.energy_bar_move_set(false,true);
		// Otherwise, just go to the movement thing
		} else {
			this.s1 = 89274;
			this._trace("normal train");
		}
		if (this.s1 == 89274) {
			R.player.enter_main_state();
			this.energy_bar_move_set(true);
		} else {
		}
	}
}

if (this.s1 != 89274) {
	R.player.y = -200;
	R.player.velocity.x = 0;
}

var train = this.sprites.members[0];
var city_pic = this.sprites.members[1];
var tiny_train = this.sprites.members[2];

if (!this.child_init) {
	if (this.s2 != 100) {
		this.set_vars(train, 416, 100, 1, true);
		this.set_vars(city_pic, (432 - city_pic.width) / 2, (256 - city_pic.height) / 2, 0, true);
		this.set_vars(tiny_train, (432 - tiny_train.width) / 2, (256 - tiny_train.height) / 2, 0, true);
		city_pic.scrollFactor.set(0, 0);
		tiny_train.scrollFactor.set(0, 0);
	} else {
		this.set_vars(train, -train.width, 100, 1, true);
	}
	this.child_init = true;
}

// Initial whiteFORGE
if (this.s1 == 0) {
	if (this.s2 == 0) {
		this.camera_off();
		this.dialogue("city", "train_enter", 0,false); // The rest of the day wa sa blur.
		this.s2 = 1;
	} else if (this.s2 == 1) {
		if (!this.dialogue_is_on()) {
			R.TEST_STATE.cutscene_handle_signal(2, [0.01]); // Fade away the fg_fade
			this.s2 = 2;
		}
	} else if (this.s2 == 2) {
		if (R.TEST_STATE.cutscene_just_finished(2) == true) {
			this.s2 = 3;
		}
	} else if (this.s2 == 3) {
		this.s1 = 1;
		this.s2 = 0;
	}
}

// Moving through...
if (this.s1 == 1) {
	
	// Going from plaza to upwards
	if (this.s2 == 0) {
		this.s2 = 1;
		train.velocity.x = 0;
		
		//train.velocity.x = -250;
		train.maxVelocity.x = 150;
		train.acceleration.x = -50;
	} else if (this.s2 == 1) {
		if (this.is_offscreen(train)) {
			if (this.s3 == 0) {
				this.s2 = 10;
				this.s2 = -69;
				tiny_train.x = city_pic.x + city_pic.width - tiny_train.width - 4;
				tiny_train.y = city_pic.y + city_pic.height - tiny_train.height - 4;
				tiny_train.velocity.set( -10, -2);
			
			} else {
				this.s2 = 2;
			}
		}
	} 
	
	//private function fade_in(o:Dynamic, constant:Float = 0.01, mult:Float = 1.05, target:Float =0.95,final:Float=1):Bool {
	if (this.s2 == -69) {
		this.fade_in(tiny_train);
		if (this.fade_in(city_pic)) {
			this.s2 = -70;
		}
	} else if (this.s2 == -70) {
		this.t_1++; 
		if (this.t_1 > 100) {
			
			R.TEST_STATE.eae.turn_on("CITY");
			this.s2 = 10;
		}
	} else if (this.s2 == -71) {
		
	}
	
	// Going left
	// relevant here
	//if (this.s2 == 100) {
		//this.s2 = 101;
		//train.maxVelocity.x = 150;
		//train.acceleration.x = -50;
	//} else if (this.s2 == 101) {
		//if (this.is_offscreen(train)) {
			//this.s2 = 102;
		//}
	//}
	
	// Enter area Effect - go here if this is the first time in
	if (this.s2 == 10) {
		if (tiny_train.x < city_pic.x + 8) {
			tiny_train.velocity.set(0, 0);
		}
		if (R.TEST_STATE.eae.is_off()) {
			this.t_1++;
			if (this.t_1 > 120) {
				this.s2 = 11;
				tiny_train.velocity.set(0, 0);
			}
		}
	} else if (this.s2 == 11) {
		R.TEST_STATE.cutscene_handle_signal(0, [0.01]);
		this.s2 = 12;
	} else if (this.s2 == 12) {
		if (R.TEST_STATE.cutscene_just_finished(0) == true) {
			this.dialogue("city", "train_enter", 1,false); // I was debriefed...
			this.s2 = 13;
		}
	} else if (this.s2 == 13) {
		if (!this.dialogue_is_on()) {
			this.s2 = 2;
		}
	} 
	
	// Leave (going to square)
	if (this.s2 == 2) {
		
		this.energy_bar_move_set(true);
		if (this.s3 == 1) {
			this.change_map("WF_GOV_MAYOR", 6, 11, true);
		} else {
			this.change_map("WF_HI_1", 17, 44, true);
			// If going to aliph etners town scene, set this var
			if (this.s3 == 0) {
				// removed 9/17/16 for safety
				//R.gsw1 = 1;
			}
		}
		this.s2 = 3;
	}
	// Leave (going to entry)
	if (this.s2 == 102) {
		this.energy_bar_move_set(true);
		this.change_map("WF_LO_0", 0, 0, true);
		this.s2 = 103;
	}
}