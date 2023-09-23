/* Deprecated (As of 2015-11-20) - uses person/city/yara_in_garden + EasyCutscene */


if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	
	
	// WHERE DOES THIS TRIGGEr
	
	// PPlays after I1 debriefing, in front of aliph house
	//this._trace("DEBUG 4c i1 yara after g1_3");
	//this.set_event(31, true); 
	// cv.0 = 0 = outside, cv.0 = 1 = yaras cv.0 = 2 = aliph's room
	//
	if (this.get_event(31) && this.get_scene_state("i_1", "yara", 1) == 1 && R.gs1 == 43521) {
		//if (this.context_values[0] == 0) {
			//this.s1 = -2;
		//} else 
		if (this.context_values[0] == 2) {
			this.s1 = 20;
			R.gs1 = 0;
		} else {
			this.s1 = 10;
		}
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	
	this.has_trigger = true;
	this.make_trigger(this.x, this.y, 20, 32);
	this.make_child("yara",false,"idle");
}

var yara = this.sprites.members[0];


if (this.s1 >= 20) {
	yara.exists = false;
}

//if (this.s1 == -2) {
	//this.set_vars(yara, this.camera_edge() + 8, this.y, 1);
	//this.s1 = -1;
	//// anim
//} else if (this.s1 == -1) {
	//this.s1 = 0;
//}
//

// outside yara's house
//if (this.s1 == 0) {
	//if (R.player.overlaps(this.trigger)) {
		//this.s1 = 1;
		//yara.velocity.x = -80;
	//}
//} else if (this.s1 == 1) {
	//if (this.player_freeze_help()) {
		//if (yara.x < R.player.x + R.player.width + 8) {
			//this.dialogue("i_1", "yara", 0,false);
			//this.s1 = 2;
			//yara.velocity.x = 0;
		//}
	//}
//} else if (this.s1 == 2 && this.doff()) {
	//this.change_map("WF_YARA", 1, 1, true);
	//this.s1 = 3;
//}
//

// from yara's house
if (this.s1 == 10) {
	this.t_1 ++;
	if (this.t_1 > 3) {
		this.t_1 = 0;
		R.player.animation.play("irn");
		R.player.facing = 0x10;
		//yara.x = this.x;
		//yara.y = this.y;
		this.set_vars(yara, this.x, this.y, 1);
		R.player.x = yara.x - 32;
		R.player.y = yara.y;
		this.dialogue("i_1", "yara", 2,false);
		this.s1 = 11;
		
	}
} else if (this.s1 == 11 && this.doff()) {
	R.TEST_STATE.cutscene_handle_signal(0, [0.01]);
	this.s1 = 22;
} else if (this.s1 == 22 ) { // aliph journal
	if (R.TEST_STATE.cutscene_just_finished(0) ) {
		this.dialogue("i_1", "yara", 6, false);
		this.s1 = 23;
		R.player.energy_bar.set_energy(128);
	}
} else if (this.s1 == 23 && this.doff())  {
	this.change_map("WF_ALIPH", 1, 1, true);
	this.s1 = 24;
}


if (this.s1 == 20) {
	this.t_1 ++;
	if (this.t_1 > 15) {
		this.s1 = 21;
		this.dialogue("i_1", "yara", 7);
	}
}



