if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	
	// PPlays after G1_1 debriefing, in front of aliph house
	//this._trace("DEBUG 3f_yara after g1_1");
	//this.set_event(29, true); //29 = g1_1 done
	//this.set_scene_state("city_i1", "yara", 1, 0);
	if (this.get_event(29) && this.get_ss("city_i1", "yara", 1) == 0) {
		this.s1 = -2;
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	
	this.has_trigger = true;
	this.make_trigger(this.x, this.y, 80, 64);
	this.make_child("yara", false, "idle_l");
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

if (this.s1 == 0) {
	if (R.player.overlaps(this.trigger)) {
		this.s1 = 10;
	R.player.energy_bar.OFF = true;
		this.set_scene_state("city_i1", "yara", 1, 1);
	}
} else if (this.s1 == 10) {
	if (this.player_freeze_help()) {
		yara.alpha = 0;
		this.set_ss("city_i1", "yara", 1, 1);
		this.s1 = 1;
		yara.velocity.x = -80;
		yara.animation.play("walk_l");
		yara.velocity.y = 50;
		yara.x = R.player.x + 100;
		yara.y = R.player.y - 16;
		//R.player.pause_toggle(true);
	}
} else if (this.s1 == 1) {
	yara.velocity.x = -80;
	yara.velocity.y = 50;
	yara._minslopebump = 0;
	yara.alpha += 0.05;
	this.separate(yara);
	if (yara.x < R.player.x + R.player.width + 8) {
		R.player.pause_toggle(false);
		yara.animation.play("idle");
		this.dialogue("city_i1", "yara", 0);
		this.s1 = 2;
		yara.velocity.x = 0;
		yara.velocity.y = 0;
		R.player.animation.play("irn");
	}
} else if (this.s1 == 2 && this.doff()) {
	R.player.enter_cutscene();
	R.easycutscene.activate("1b_yara_1");
	this.s1 = 3;
} else if (this.s1 == 3 ) {
	if (R.easycutscene.ping_last) {
		this.change_map("WF_ALIPH", 3, 1, true);
		this.s1 = 5;
	}
}