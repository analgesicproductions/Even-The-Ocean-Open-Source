//{ i2_crowd_angry
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	this.s2 = 0;
	//this._trace("DEBUG 5h_crowd_angry");
	//this.set_ss("i2", "aliph_out", 1, 1);
	//this.set_ss("i2", "crowd", 1, 0);
	//this.s1 = 6;
	
	
	if (this.get_ss("i2", "crowd", 1) == 0 && this.get_ss("i2", "aliph_out", 1) == 1) {
		this.make_child("yara",false,"idle");
		this.make_child("humus",false,"idle");
		this.make_child("dave",false,"idle");
		this.make_child("ronaldSprite",false,"idle");
		this.make_child("maude",false,"idle");
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
}
var yara = this.sprites.members[0];
var humus = this.sprites.members[1];
var dave = this.sprites.members[2];
var ronald= this.sprites.members[3];
var maude = this.sprites.members[4];
if (this.s1 == 0) {
	this.t_1++;
	if (this.t_1 > 4) {
		R.player.energy_bar.OFF = true;
		this.camera_off();
		this.cam_to_id(0);
		this.play_music("wf_argue_talk");
		this.set_vars(yara, this.x - 16, this.y , 1);
		this.set_vars(humus, this.x - 48, this.y, 1);
		this.set_vars(dave, this.x + 36, this.y, 1);
		this.set_vars(ronald, this.x + 58, this.y, 1);
		this.set_vars(maude, this.x + 100, this.y, 1);
		yara.scale.x = humus.scale.x = -1;
		R.player.x =  R.player.last.x = this.camera_edge(true, false, true, false) - 16; 
		R.player.y = R.player.last.y =  13 * 16  - R.player.height + 1;
		R.player.offset.y = R.player.frameHeight - R.player.height;
		this.s1 = 1;
		this.t_1 = 0;
	}
} else if (this.s1 == 1) {
	this.t_1++;
	if (this.t_1 > 10) {
		this.t_1 = 0;
		this.dialogue("i2", "crowd", 0,false);
		this.s1 = 2;
	}
} else if (this.s1 == 2) {
	if (this.doff()) {
		// yara slumps
		yara.animation.play("idle");
		// aliph runs up
		R.player.enter_cutscene();
		R.player.pause_toggle(false);
		R.player.animation.play("wrr");
		R.player.velocity.x = 80;
		this.s1 = 3;
	}
} else if (this.s1 == 3) {
	if (R.player.x + R.player.width + 2 > humus.x) {
		R.player.velocity.x = 0;
		R.player.animation.play("irn");
		this.dialogue("i2", "crowd", 10);
		this.s1 = 4;
	}
} else if (this.s1 == 4) {
	if (this.doff()) {
		R.player.animation.play("wrr");
		R.player.velocity.x = 80;
		this.s1 = 5;
	}
} else if (this.s1 == 5) {
	if (R.player.x > yara.x + yara.width) {
		R.player.velocity.x = 0;
		R.player.animation.play("iln");
		this.dialogue("i2", "crowd", 16);
		this.s1 = 6;
		R.player.energy_bar.visible = false;
	}
} else if (this.s1 == 6 && this.doff()) {
	
	//this._trace(R.player.energy_bar.cutscene_mode);
	//if (R.player.energy_bar.cutscene_mode == 0) {
		this.set_ss("i2", "crowd", 1, 1);
		R.player.energy_bar.OFF = true;
		R.player.enter_cutscene();
		R.TEST_STATE.dialogue_box.speaker_always_none = true;
		// Jail, then yara's house, then implied sleep
		R.easycutscene.activate("3c_humusyara");
		this.s1 = 7;
	//}
} else if (this.s1 == 7 && R.easycutscene.ping_last) {
	this.s1 = 8;
	this.set_ss("i2", "humus_jail", 1, 1);
	this.set_ss("i2", "yara", 1, 1);
	this.set_ss("g2_2", "bed", 1, 1); // For correct dialogue in aliph new apt
	R.player.energy_bar.set_energy(128);
		R.player.energy_bar.visible = true;
	R.actscreen.activate(4, this.parent_state);
} else if (this.s1 == 8) {
	if (R.actscreen.is_off()) {
		this.s1 = 9;	
		this.change_map("WF_ALIPH2", 15, 11, true);
	}
}



