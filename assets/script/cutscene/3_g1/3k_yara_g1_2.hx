if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	// PPlays after G1_2 debriefing, in front of aliph house
	//this._trace("DEBUG 3k_yara_g1_2 after g1_2");
	//this.set_event(30, true); 
	if (this.get_event(30) && this.get_scene_state("city_g1_2", "yara", 1) == 0) {
		if (this.context_values[0] == 0) {
			this.s1 = -2;
		} else {
			this.s1 = 10;
			this.SCRIPT_OFF = true;
			return;
		}
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	this.has_trigger = true;
	this.make_trigger(this.x-32, this.y, 80, 64);
	this.make_child("yara",false,"idle_l");
}

var yara = this.sprites.members[0];

if (this.s1 == -2) {
	this.set_vars(yara, this.camera_edge() + 8, this.y, 1);
	yara.alpha = 0;
	this.s1 = -1;
	// anim
} else if (this.s1 == -1) {
	this.s1 = 0;
}


// outside yara's house
if (this.s1 == 0) {
	if (R.player.overlaps(this.trigger)) {
		this.s1 = 1;
		
		R.player.energy_bar.OFF = true;
		yara.velocity.x = -80;
		yara.animation.play("walk_l");
		yara.velocity.y = 50;
		yara.x = R.player.x + 110;
		yara.y = R.player.y - 16;
		yara.alpha = 0;
	}
} else if (this.s1 == 1) {
	yara.velocity.x = -80;
	yara.velocity.y = 50;
	yara.alpha += 0.05;
	yara._minslopebump = 0;
	this.separate(yara);
	if (this.player_freeze_help()) {
		if (yara.x < R.player.x + R.player.width + 8) {
			this.dialogue("city_g1_2", "yara", 0);
			this.s1 = 2;
			yara.animation.play("idle");
			R.player.animation.play("irn");
			yara.velocity.x = 0;
			yara.velocity.y = 0;
		}
	}
} else if (this.s1 == 2 && this.doff()) {
	this.set_scene_state("city_g1_2", "yara", 1, 1);
	R.player.enter_cutscene();
		R.TEST_STATE.dialogue_box.speaker_always_none = true;
	R.easycutscene.activate("1d_yara_2");
	this.s1 = 3;
} else if (this.s1 == 3) {
	if (R.easycutscene.ping_last) {
		this.change_map("WF_ALIPH", 1, 1, true);		
		this.s1 = 4;
	}
}

