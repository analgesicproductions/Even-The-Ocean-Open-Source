//{ paxlopez_g1
// stuff with wheover
// Lopez will ALWAYS try to go to Shore and paxton to Canyon.
// If you choose one of those first, the other shows up at HIll
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	
	
	if (R.TEST_STATE.MAP_NAME.indexOf("SHORE") != -1) {
		this.s3 = 1;
	} else if (R.TEST_STATE.MAP_NAME.indexOf("CANYON") != -1) {
		this.s3 = 2;
	} else if (R.TEST_STATE.MAP_NAME.indexOf("HILL") != 1) {
		this.s3 = 3;
	}

	
	this.ignore_parent_dialogue = true;
	
	// 26 27 28 - g1_1... ID	
	//29 30 31 - g1_1 ... done
	// 32 33 - lopez / pax ID
	
	
	//this._trace("DEBUG Lopez at Hill, G1_2");
	//this.set_event(29);
	//this.set_event(30, false);
	//this.set_event(32, true, 3);
	//this.set_event(27, true, 3);
	//this.set_event(26, true, 1);
	
	//this._trace("DEBUG Lopez at Shore, G1_2");
	//this.set_event(29);
	//this.set_event(30, false);
	//this.set_event(32, true, 1);
	//this.set_event(27, true, 1);
	//
	//this._trace("DEBUG Paxton at canyon, shore first, G1_2");
	//this.set_event(29); 
	//this.set_event(32, true, 1);
	//this.set_event(33, true, 2);
	//this.set_event(26, true, 1);
	//this.set_event(27, true, 2);
	//
	//this._trace("DEBUG paxlop OFF (g1_1)");
	//this.set_event(29, false);
	//this.set_event(30, false);
	
	//this._trace("DEBUG paxlop OFF (g1_2 revisited ,shore, lopez)");
	//this.set_event(29);
	//this.set_event(30);
	//this.set_event(33, true, 2);
	//this.set_event(32, true, 1);
	//this.set_event(27, true, 1);
	//this.set_event(28, true, 2);
	//
	// state_1 : 0 = do lopez, 1 = do paxton
	
	// s1 start: 0 = lopez, 100 = paxton/lopez looping dialoue, 200 = paxton
	
	
	// g1_2 done
	if (this.get_event(30)) {
		if (this.get_event(31)) { // dont play if g1_3 done already
			this.SCRIPT_OFF = true;
			return;
		}
		//lopez = g1_3 id
		if (this.get_event(32, true) == this.get_event(28, true) && this.s3 == this.get_event(28, true)) {
			this.state_1 = 0;
		} else if (this.get_event(33, true) == this.get_event(28, true) && this.s3 == this.get_event(28, true)) {
			this.state_1 = 1;
		} else  {
			this.SCRIPT_OFF = true;
			return;
		}
	} else if (this.get_event(29)) {
		if (this.get_event(30)) { // dont play if g1_2 done already
			this.SCRIPT_OFF = true;
			return;
		}
		//if lopez ID (32) = g1_2 id (27)
		if (this.get_event(32, true) == this.get_event(27, true) && this.s3 == this.get_event(27, true)) {
			this.state_1 = 0;
		} else if (this.get_event(33, true) == this.get_event(27, true) && this.s3 == this.get_event(27, true)) {
			this.state_1 = 1;
		} else {
			this.SCRIPT_OFF = true;
			return;
		}
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	
	if (this.state_1 == 0) {
		this.make_child("lopez_armor", false, "idle_l");
		// If did first part, go to repeating section after deactivating the barbed wire
		if (this.get_ss("nature_g1_2", "lopez", 1) == 2) {
			this.s1 = 100;
		} else if (this.get_ss("nature_g1_2", "lopez", 1) == 1) {
			this.s1 = 2;
		} else {
			this.s1 = 0;
		}
	} else {
		this.make_child("paxton_armor", false, "idle_l");
		// same, but for paxton
		if (this.get_ss("nature_g1_2", "paxton_1", 1) == 2) {
			this.s1 = 210;
			
		} else if (this.get_ss("nature_g1_2", "paxton_1", 1) == 1) {
			this.s1 = 202;
		} else {
			this.s1 = 200;
		}
	}
	
	
	this.set_vars(this.sprites.members[0], this.x, this.y);
	if (this.s1 == 210) {
		this.sprites.members[0].y = -200;
	}
	
	this.has_trigger = true;
	if (R.TEST_STATE.MAP_NAME == "CANYON_B") {
		this.make_trigger(this.x -120, this.y - 100, 32, 132);
	} else {
		this.make_trigger(this.x -200, this.y - 100, 32, 132);
	}
}

var person = this.sprites.members[0];
person.scale.x = -1;

// LOPEZ
if (this.s1 == 0) {
	if (this.trigger.overlaps(R.player)) {
		this.s1 = 1;
	}
} else if (this.s1 == 1) {
	if (this.player_freeze_help()) {
		this.s1 = 2;
		R.player.animation.play("irn");
		R.player.facing = 0x10;
		this.set_scene_state("nature_g1_2", "lopez", 1, 1);
		this.dialogue("nature_g1_2", "lopez", 9);
	}
} else if (this.s1 == 2 && this.doff() && this.nr_ENERGIZE_received > 0) {

	// need to turn off a dark barbed wire with light energy
	this.s1 = 101;
	this.set_scene_state("nature_g1_2", "lopez", 1, 2);
	this.dialogue("nature_g1_2", "lopez", 0);
}

// PAXTON
if (this.s1 == 200) {
	if (this.trigger.overlaps(R.player)) {
		this.s1 = 201;	
	}
} else if (this.s1 == 201) { // Say initial thing "oh no!"
	if (this.player_freeze_help()) {
		this.s1 = 202;
		this.set_scene_state("nature_g1_2", "paxton_1", 1, 1);
		this.dialogue("nature_g1_2", "paxton_1", 2); // oh no paxton!! 
	}
} else if (this.s1 == 202 && this.doff()) { // wait till dark barbed wire is off
	if (this.nr_ENERGIZE_received > 0) {
		if (this.s2 == 0) {
			R.player.enter_cutscene();
			//R.player.velocity.x = 80;
			//R.player.animation.play("wrr");
			this.s2 = 2;
			this.t_1 = 0;
		} else if (this.s2 == 2) {
			this.t_1 ++;
			if (this.t_1 > 45) {
				//R.player.velocity.x = 0;
				//R.player.facing = 0x0010;
				R.player.animation.play("irn");
				this.s2 = 1;
			}
		} else if (this.s2 == 1 && this.player_freeze_help()) {
			this.s1 = 203;
			this.set_scene_state("nature_g1_2", "paxton_1", 1, 2);
			this.dialogue("nature_g1_2", "paxton_1", 0, false); // ' you couldve helped L first...'
		}
	}
} else if (this.s1 == 203 && this.doff()) { 
	if (this.get_event(30)) { // If g1_2 is done, then L was saved first
		this.dialogue("nature_g1_2", "paxton_2_last", 0,false); 
	} else {
		this.dialogue("nature_g1_2", "paxton_2_first", 0,false); 
	}
	this.s1 = 204;
} else if (this.s1 == 204 && this.doff()) {
	this.dialogue("nature_g1_2", "paxton_3", 0);  // alih, aiph, aliph...*walks forward*
	this.s1 = 205;
} else if (this.s1 == 205 && this.doff()) {
	R.player.enter_cutscene();
	//R.player.velocity.x = 80;
	//R.player.animation.play("wrn");
	//person.velocity.x = 80;
	//person.animation.play("idle");
	this.s1 = 206;
} else if (this.s1 == 206) {
	// if past some point
	this.t_1++;
	if (this.t_1 > 45) {
		this.s1 = 207;
		this.t_1 = 0;
		//R.player.velocity.x = 0;
		//person.velocity.x = 0;
		//person.animation.play("idle_l");
		//R.player.animation.play("irn");
		//R.player.enter_main_state();
		//R.player.facing = 0x0010;
		// paly hurt anim
		R.TEST_STATE.cutscene_handle_signal(0, [0.01]);
	}
} else if (this.s1 == 207 && this.doff() && R.TEST_STATE.cutscene_just_finished(0)) {
	this.s1 = 208;
} else if (this.s1 == 208) {
	person.y = -500;
	this.t_1 ++;
	if (this.t_1 >= 90) {
		R.TEST_STATE.cutscene_handle_signal(2, [0.01]);
		this.s1 = 209;
	}
} else if (this.s1 == 209 && R.TEST_STATE.cutscene_just_finished(2)) {
	this.s1 = 210;
	R.player.enter_main_state();
	this.broadcast_to_children("dark_off");
}


// ONLY LOPEZ, LOOP

if (this.s1 == 100) {
	//broadcast so,eting to children
	this.broadcast_to_children("dark_off");
	this.s1 = 101;
} else if (this.s1 == 101) {
	if (this.doff()) {
	if (this.try_to_talk(0, person)) {
		if (this.state_1 == 0) {
			this.dialogue("nature_g1_2", "lopez", 8);
		} else {
			this.dialogue("nature_g1_2", "paxton_3", 9);
		}
	}
	}
}






