//  Gate person in town leaving after I1
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	
	// spawn paxton
	//trigger
	// DEBUG
	// set g2_1  to river
	//this._trace("DEBUG IN 4f_paxton");
	//this.set_event(34, true, 6 );
	
	this.make_child("paxton_armor",false,"dead");
	
	if (this.get_ss("g2_1", "paxton", 1) == 1) {
		if (this.event(37)) {
			this.SCRIPT_OFF = true;
			return;
		}
		this.sprites.members[0].animation.play("dead");
		this.s1 = 8;
	}
	
	this.broadcast_to_children("dark_off");
	this.sprites.members[0].animation.play("dead");
	
	this.set_vars(this.sprites.members[0], this.x + 32, this.y-16, 1);
	
	this.has_trigger = true;
	this.make_trigger(this.x - 40 , this.y - 100, 16, 164);
	if (R.TEST_STATE.MAP_NAME == "WOODS_B") {
		this.trigger.x += 64 + 10*16;
	}
}

var paxton = this.sprites.members[0];

if (this.s1 == 0 && R.player.overlaps(this.trigger)) {
	this.s1 = 1;
	this.set_ss("g2_1", "paxton", 1, 1);
} else if (this.s1 == 1 && this.player_freeze_help()) {
	this.dialogue("g2_1", "paxton", 0);
	this.s1 = 2;
} else if (this.s1 == 2 && this.doff()) {
	// inch
	R.player.enter_cutscene();
	if (R.TEST_STATE.MAP_NAME == "WOODS_B") {
		R.player.animation.play("wll");
		R.player.velocity.x = -80;
	} else {
		R.player.velocity.x = 80;
		R.player.animation.play("wrr");
	}
	this.s1 = 3;
} else if (this.s1 == 3) {
	
	if (R.TEST_STATE.MAP_NAME == "WOODS_B") {
		R.player.velocity.x = -80;
		if (R.player.x < paxton.x + 50) {
			R.player.velocity.x = 0;
			R.player.animation.play("iln");
			R.player.facing = 0x1;
			this.s1 = 4;
		}
	} else {
		R.player.velocity.x = 80;
		if (R.player.x + R.player.width > paxton.x - 8) {
			R.player.velocity.x = 0;
			R.player.animation.play("irn");
			R.player.facing = 0x10;
			this.s1 = 4;
		}
	}
} else if (this.s1 == 4) {
	this.dialogue("g2_1", "paxton", 2);
	this.s1 = 5;
} else if (this.s1 == 5 && this.doff()) {
	// anim for paxton slumping
	this.dialogue("g2_1", "paxton", 4);
	this.s1 = 6;
} else if (this.s1 == 6 && this.doff()) {
	this.s1 = 7;
	//this.dialogue("overworld", "lopez", 0);
} else if (this.s1 == 7 && this.doff()) {
	R.player.enter_main_state();
	this.s1 = 8;
} else if (this.s1 == 8 && this.doff()) {
	if (this.try_to_talk(0,paxton,true)) {
		this.dialogue("g2_1", "paxton", 14);
	}
}
