// Aliph gets armors
if (!this.child_init) {
	this.child_init = true;
	this.s1 = -1;
	
	// DEBUG!!!
	 //this._trace("DEBUG 2h_yara_exit");
	//this.set_scene_state("city", "intro_armor", 1, 1);
	//this.set_scene_state("city", "intro_yara", 1, 0);
	
	// Plays after aliph gets armor
	if (this.get_scene_state("city", "intro_armor", 1) == 1 && this.get_scene_state("city", "intro_yara", 1) == 0) {
		//this.play_music("null",false);
		this.s1 = 0;
	} else {
		this.SCRIPT_OFF = true;
		this.only_visible_in_editor = true;
		return;
	}
	
	this.make_child("yara",false);
	
	this.animation.play("idle");
	this.has_trigger = true;
	this.make_trigger(this.x, this.y-100, 16, 200);
	this.only_visible_in_editor = true;
	this.sprites.members[0].visible = false;
	this.set_vars(this.sprites.members[0], this.x, this.y, 1);
}

var yara = this.sprites.members[0];

if (this.s1 == 0) {
	if (R.player.overlaps(this.trigger)) {
		this.set_scene_state("city", "intro_yara", 1, 1);
		this.s1 = 1;
	}
} else if (this.s1 == 1) {
	if (this.player_freeze_help()) {
		this.dialogue("city", "intro_yara", 0);
		this.s1 = 2;
	}
} else if (this.s1 == 2 && this.doff()) {
	R.player.animation.play("iln");
	R.player.facing = 0x001;
	R.player.pause_toggle(false);
	R.player.enter_cutscene();
	yara.x  = this.camera_edge(true,false,true) +95;
	yara.y = R.player.y - (yara.height - R.player.height);
	yara.velocity.x = 75;
	yara.visible = true;
	yara.scale.x = -1;
	yara.alpha = 0;
	yara.animation.play("walk_r");
	//this.animation.play("idle");
	this.s1 = 3;
} else if (this.s1 == 3) {
	yara.alpha += 0.05;
	if (yara.x > R.player.x - R.player.width -24) {
		yara.velocity.x = 0;
		yara.animation.play("idle");
		this.dialogue("city", "intro_yara", 2);
		this.s1 = 4;
	}
} else if (this.s1 == 4) {
	if (this.doff()) {
		//play yara anim
		this.s1 = 5;
	}
} else if (this.s1 == 5) {
	this.t_1 ++;
	if (this.t_1 > 60) {
		this.t_1 = 0;
		this.change_map("MAP1", 124, 75, true);
		this.s1 = 6;
	}
}


