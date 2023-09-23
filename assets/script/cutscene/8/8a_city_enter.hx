if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	this.s2 = 0;
	this.has_trigger = true;
	this.make_trigger(this.x, this.y, 32, 32);
	
	//this._trace("DEBUG 8a_city_enter");
	//this.set_ss("s3", "last_debrief", 1, 1);
	//this.set_ss("ending", "city_enter", 1, 0);
	//this.play_music("rain");
	
	if (this.get_ss("s3", "last_debrief", 1) == 1 && this.get_ss("ending","city_enter", 1) == 0) {
		this.make_child("yara",false,"idle");
		this.make_child("humus", false, "idle");		
		return;
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	
}

// Assign sprites
var yara = this.sprites.members[0];
var humus = this.sprites.members[1];

if (this.s2 == 0) {
	this.set_vars(yara, this.x, this.y, 1);	
	this.set_vars(humus, this.x - 60, this.y, 1);	
	humus.scale.x = -1;
	R.player.facing = 0x1;
	R.player.x = R.player.last.x = this.x - 10;
	R.player.y = R.player.last.y = this.y + this.height - R.player.height;
	this.s2 = 1;
}

// Do stuff
if (this.s1 == 0) {
	R.player.energy_bar.OFF = true;
	this.camera_off();
	this.cam_to_id(0);
	this.set_ss("ending", "city_enter", 1, 1);
	this.s1 = 1;
} else if (this.s1 == 1) {
	if (this.player_freeze_help()) {
		this.s1 = 2;
		R.player.enter_cutscene();
		this.dialogue("ending", "city_enter", 0,false);
	}
} else if (this.s1 == 2 && this.doff()) {
	this.s1 = 200;
} else if (this.s1 == 200) {
	this.s1 = 3;
} else if (this.s1 == 3 && this.doff()) {
	R.player.pause_toggle(false);
	//R.player.animation.play("irn"); // should be cry
	this.s1 = 4;
} else if (this.s1 == 4) {
	this.t_1 ++;
	if (this.t_1 > 15) {
		yara.animation.play("idle"); // Should be kneel
		this.s1 = 5;
		this.t_1 = 0;
	}
} else if (this.s1 == 5) {
	this.t_1 ++;
	if (this.t_1 > 30) {
		this.t_1 = 0;
		this.dialogue("ending", "city_enter_2", 0,false);
		this.s1 = 6;
	}
} else if (this.s1 == 6 && this.doff()) {
	R.player.animation.play("irn"); // sb look up
	this.s1 = 7;
} else if (this.s1 == 7) {
	this.t_1 ++;
	if (this.t_1 > 30) {
		this.t_1 = 0;
		this.dialogue("ending", "city_enter_2", 1);
		this.s1 = 8;
	}
} else if (this.s1 == 8) {
	if (this.doff()) {
		//R.player.pause_toggle(false);
		//R.player.velocity.x = 80;
		//R.player.animation.play("wrr");
		this.s1 = 9;
	}
} else if (this.s1 == 9) {
	//R.player.x -= 8;
	//if (this.is_offscreen(R.player)) {
		R.player.enter_cutscene();
		R.easycutscene.activate("4a_cart");
		this.s1 = 10;
		this.t_1 = 0;
	//}
	//R.player.x += 8;
} else if (this.s1 == 10) {
	//this.t_1 ++;
	//if (this.t_1 > 60) {
		//R.player.velocity.x = 0;
	//}
	if (R.easycutscene.ping_last) {
		this.s1 = 11;
		this.change_map("WF_HI_1", 53, 21, true);
	}
}