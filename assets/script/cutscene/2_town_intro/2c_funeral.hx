if (!this.child_init) {
	// Bar still not visible
	this.only_visible_in_editor = true;
	this.child_init = true;
	this.s1 = -1;
	
	// DEBUG
	//this._trace("debug 2c_funeral");	
	//this.set_scene_state("city", "aliph_fades", 1, 1);
	//this.set_scene_state("city", "funeral_speech", 1, 0);
	//
	 //If this sequence seen, just exit.	
	if (this.get_scene_state("city", "funeral_speech", 1) == 1) {
		this.SCRIPT_OFF  = true;
		return;
	}
	// Prev event
	if (this.get_scene_state("city", "aliph_fades", 1) == 1) {
		this.set_scene_state("city", "funeral_speech", 1, 1);
		this.s1 = 0;
		
		this.play_music("wf_yara", false);
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	
	//this.s1 = 21;
	
	this.make_child("yara",false,"idle_l");
	this.make_child("paxton",false,"idle_r");
	this.make_child("lopez",false,"idle_r");
	this.make_child("hastings",false,"idle_r");
	this.make_child("funeral_casket", false, "idle");
	
	this.has_trigger = true;
	this.make_trigger(190, this.y - 132, 24, 178);
	// MAKE NPCS
	R.player.enter_cutscene();
	R.player.x = R.player.last.x =  25 * 16 - 19;
	R.player.y = R.player.last.y = 11* 16-R.player.height;
	R.player.animation.play("irx");
	R.player.shieldless_sprite = true;
 	
	
}

var yara = this.sprites.members[0];
var paxton = this.sprites.members[1];
var lopez = this.sprites.members[2];
var official = this.sprites.members[3];
var casket = this.sprites.members[4];


if (this.state_1 == 0) {
	if (this.trigger.overlaps(R.player)) {
		this.state_1 = 1;
	}
}
if (this.state_1 == 1) {
	if (this.player_freeze_help()) {
		R.player.pause_toggle(false);
		R.player.enter_cutscene();
		R.player.velocity.x = 80;
		R.player.animation.play("wrr");
		this.state_1 = 2;
	}
} else if (this.state_1 == 2) {
	if (R.player.x > this.trigger.x + this.trigger.width + 10) {
		R.player.velocity.x = 0;
		this.state_1 = 3;
		this.dialogue("city", "funeral_yara", 1);
		R.player.animation.play("irn");
		R.player.facing = 0x10;
	}
} else if (this.state_1 == 3) {
	if (this.doff()) {
		R.player.enter_main_state();
		this.state_1 = 0;
	}
}
//return;

if (this.s1 == 0) {
	this.cam_to_id(0);
	
lopez.scale.x = paxton.scale.x = official.scale.x = -1;
	this.set_vars(yara, this.x + 122, this.y, 1);
	this.set_vars(paxton, this.x+16, this.y, 1);
	this.set_vars(lopez, this.x-16, this.y, 1);
	this.set_vars(official, this.x-64, this.y, 1);
	this.set_vars(casket, this.x + 180, this.y-16, 1);
	this.s1 = 1; 
	return;
}


if (this.s1 == 1) {
	this.t_2 ++;
	if (this.t_2 > 15) {
		this.dialogue("city", "funeral_speech", 0,false);
		this.s1 = 2;
	}
} else if (this.s1 == 2) {
	if (!this.dialogue_is_on()) {
		this.s1 = 3;
		R.TEST_STATE.cutscene_handle_signal(0, [0.01]);
	}
} else if (this.s1 == 3) {
	if (R.TEST_STATE.cutscene_just_finished(0)) {
		this.s1 = 4;
		
		this.play_music("wf_cass", false);
		this.dialogue("city", "funeral_speech", 3);
	}
} else if (this.s1 == 4 && !this.dialogue_is_on()) {
	this.s1 = 5;
	R.TEST_STATE.cutscene_handle_signal(2, [0.01]);
} else if (this.s1 == 5) {
	if (R.TEST_STATE.cutscene_just_finished(2)) {
		this.s1 = 6;
		R.player.enter_main_state();
		this.camera_to_player(true);
		this.energy_bar_move_set(true);
	}
} else if (this.s1 == 6) {
	if (this.dialogue_is_on()) {
		return;
	}
	
	if (this.try_to_talk(0, official)) {
		official.scale.x = 1;
		this.dialogue("city", "funeral_official");
		this.s1 = 7;
		return;
	}
	
	
	if (this.try_to_talk(0, paxton)) {
		paxton.scale.x = 1;
		this.dialogue("city", "funeral_paxton");
		return;
	}
	
	if (this.try_to_talk(0, lopez)) {
		lopez.scale.x = 1;
		this.dialogue("city", "funeral_lopez");
		return;
	}
	if (this.try_to_talk(0, yara)) {
		yara.scale.x = 1;
		this.dialogue("city", "funeral_yara",0);
		return;
	}
	
	if (this.s2 == 1) {
		return;
	}
	
	
	if (this.try_to_talk(0, casket)) {
		this.dialogue("city", "funeral_casket",0,false);
		this.s1 = 9;
	}
	
	
} else if (this.s1 == 7) {
	if (this.d_last_yn() != -1) {
		this.s3 = this.d_last_yn();
	}
	if (!this.dialogue_is_on()) {
		if (this.s3 == 0) { // Stay
			this.s1 = 6;
		} else {
			this.s1 = 8; // leave
			// walk_l
			R.player.enter_cutscene();
			//R.player.animation.play("wln");
			//official.velocity.x = -80;
			//R.player.velocity.x = -80;
		}
	}
} else if (this.s1 == 8) {
	//this.t_1 ++;
	//if (this.t_1 > 30) {
		//R.player.velocity.x = 0;
		//R.player.animation.play("iln");
		//this.dialogue("city", "funeral_casket", 11);
		this.s1 = 21;
		//this.t_1 =  0;
		//R.player.velocity.x = 0;
		R.player.enter_cutscene();
	//}
} else if (this.s1 == 20) {
	//if (!this.dialogue_is_on()) {
		//R.player.pause_toggle(false);
		//R.player.animation.play("wln");
		//R.player.velocity.x = -80;
		//this.camera_off();
		//this.s1 = 21;
	//}
	
} else if (this.s1 == 21) {
	this.t_1 ++;
	if (this.t_1 == 30) {
		R.player.energy_bar.OFF = true;
		R.easycutscene.activate("0c_leavefuneral", this.parent_state);	
	}
		
	if (R.easycutscene.ping_last) {
		this.s1 = 22;
		R.player.shieldless_sprite = false;
		this.change_map("WF_GOV_MAYOR", 0, 0, true);
	}
} else if (this.s1 == 22) {
	
}

if (this.s1 == 9) {
	if (!this.dialogue_is_on()) {
		//yara.acceleration.x = 150;
		//yara.maxVelocity.x = 50;
		yara.scale.x = -1;
		// walk r
		this.s1 = 10;
	}
} else if (this.s1 == 10) {
	//if (yara.x + yara.width > R.player.x - 4) {
		// idle
		R.player.enter_cutscene();
		R.player.animation.play("iln");
		yara.velocity.x = yara.acceleration.x = 0;
		this.dialogue("city", "funeral_casket", 4); // yara says hey
		this.energy_bar_move_set(false);
		this.s1 = 11;
	//}
} else if (this.s1 == 11 && !this.dialogue_is_on()) {
	this.s1 = 12;
	//R.player.velocity.x = -80;
	//R.player.animation.play("wln");
} else if (this.s1 == 12) { 
	//if (R.player.x + R.player.width < yara.x) {
		//R.player.velocity.x = 0;
		//R.player.animation.play("irn");
		this.dialogue("city", "funeral_casket", 9); // a: im sorry about your loss
		this.s1 = 13;
		this.s2 = 1;
	//}
}  else if (this.s1 == 13) {
	if (!this.dialogue_is_on()) {
		this.s1 = 6;
		R.player.enter_main_state();
	}
}







