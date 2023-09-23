//{ i1_humus
//meet humus Outside the lighthouse
//<cut back to lobby. You can head out, there is a bit of commotion in the plaza. Humus is the center of attention here. Some people from the high district who I haven’t named yet. Let’s say… Maude, Dave, Ronald>
// Plays till you go 2 sleep
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	
	// Show if you beat g1_3 but didnt talk 2 yaraand do the sleep yet
	//this.set_event(31);
	//this.set_ss("i_1", "humus", 1, 0);
	//this.set_ss("i_1", "only_humus", 1, 0);
	//
	//this.set_ss("i_1", "humus", 2, 0);
	//this._trace("DEBUG 4b_humus");
	
	if (this.get_event(31) && this.get_scene_state("i_1", "yara", 1) == 0) {
		this.s1 = -1;
	} else {
		this._trace("off");
		this.SCRIPT_OFF = true;
		return;
	}
	
	this.make_child("humus",false,"idle");
	this.make_child("maude", false, "idle");
	this.make_child("dave", false, "idle");
	this.make_child("ronaldSprite", false, "idle");
	
}

var humus = this.sprites.members[0];
var maude = this.sprites.members[1];
var dave = this.sprites.members[2];
var ronald = this.sprites.members[3];

if (this.s1 == -1) {
	this.t_1 ++;
	maude.scale.x = -1;
	dave.scale.x = -1;
	ronald.scale.x = -1;
	
	if (this.t_1 > 2) {
	this.set_vars(humus, this.x -32, this.y, 1);
	this.set_vars(maude, this.x - 80, this.y, 1);
	this.set_vars(dave, this.x - 135, this.y, 1);
	this.set_vars(ronald, this.x - 112, this.y, 1);
	
	this.s1 = 0;
	if (this.get_ss("i_1", "humus", 1) == 1) {
		dave.exists = false;
		R.ignore_door = false;
		this.s1 = 2;
	} else {
		R.ignore_door = true;
		R.player.enter_cutscene();
		R.player.animation.play("iln");
		R.player.x = R.player.last.x = 874;
		R.player.y = R.player.last.y = 308;
		R.player.velocity.y = 0;
		R.player.facing = 0x001;
		this.cam_to_id(10);
		return;
	}
	this.t_1 = 0;
	}
}

if (this.s1 == 0) {
	this.s1 = 1;
	this.dialogue("i_1", "humus", 0);
} else if (this.s1 == 1) {
	if (this.doff()) {
		this.s1 = 2;
		R.player.enter_main_state();
		R.player.touching = 0x1000;
		R.player.velocity.y = 0;
		dave.scale.x = 1;
		this.set_ss("i_1", "humus", 1, 1);
	}
} else if (this.s1 == 2) {
	dave.alpha -= 0.0005;
	if (dave.alpha <= 0.970) {
		dave.alpha -= 0.04;
	}
	if (dave.alpha <= 0 && dave.exists) {
		dave.ID ++;
		if (dave.ID > 30) {
			dave.exists = false;
			this.camera_to_player(true);
		}
	}
	
	if (this.try_to_talk(0, maude)) {
		maude.scale.x = 1;
		if (this.get_ss("i_1", "humus", 2) == 0) {
			this.dialogue("i_1", "humus", 5);
			this.set_ss("i_1", "humus", 2, 1);
		} else {
			this.dialogue("i_1", "humus", 7);
		}
		this.s1 = 3;
	}
	if (this.try_to_talk(0, ronald)) {
		ronald.scale.x = 1;
		if (this.get_ss("i_1", "humus", 2) == 0) {
			this.dialogue("i_1", "humus", 5);
			this.set_ss("i_1", "humus", 2, 1);
		} else {
			this.dialogue("i_1", "humus", 8);
		}
		this.s1 = 3;
	}
	
	if (this.try_to_talk(0, humus)) {
		if (this.get_ss("i_1", "only_humus", 1) == 0) {
			this.dialogue("i_1", "only_humus", 0);
			this.set_ss("i_1", "only_humus", 1, 1);
			R.ignore_door = false;
		} else {
			this.dialogue("i_1", "only_humus", 10);
		}
	}
	
	if (R.ignore_door) {
	//this._trace(R.attempted_door);
	if (R.attempted_door != null && R.attempted_door.length > 1) {
		if (this.s2 != 1 && this.get_ss("i_1", "only_humus", 1) == 0) {
			// not done, run
			this.dialogue("i_1", "only_humus", 11);
			this.s1 = 4;
		} else {
			this.s2 = 1;
		}
	}
	}
	// Talk to Ronald/maude, must talk to humus
} else if (this.s1 == 3 && this.doff()) {
	this.s1 = 2;
} else if (this.s1 == 4 && this.doff()) {
		R.attempted_door = "";
	this.s1 = 2;
} else if (this.s1 == 5) {
	
}
	



