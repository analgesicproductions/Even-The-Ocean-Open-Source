if (!this.child_init) { 
	//R.inventory.set_item_found(0, 47);
	//this._trace("DEBUG DOLLY LIFT");
		//this.set_ss("forest", "dolly_gate", 1, 0);
	this.child_init = true;
	this.has_trigger = true;
	this.play_anim("idle_l");
	this.height = 24;
	this.offset.y = 24;
	if (this.context_values[0] == 2) { // dolly at bridge gate??
		this.make_trigger(this.x - 200, this.y - 100, 20, 132);
		this.s3 = 1;
	} else {
		if (1 == this.get_ss("forest", "dolly_gate", 2)) {
			this.children[0].animation.play("broken");
			this.visible = false;
			this.SCRIPT_OFF = true;
			return;
		}
		this.s2 = 60;
		this.make_trigger(this.x - 80, this.y - 100, 20, 132);
		this.move(56 * 16, 57 * 16 - this.height);
	}
}

if (this.s3 == 1) {
	if (this.s1 == -1) {
		this.broadcast_tick(false);
		this.s1 = -2;
	} 
	if (this.s1 == 0) {
		if (1 == this.get_ss("forest", "dolly_gate", 1)) {
			this.s1 = -1;
			this.visible = false;
		} else {
			this.s1 = 1;
			this.visible = true;
		}
	} else if (this.s1 == 1) {
		if (R.player.overlaps(this.trigger)) {
			this.set_ss("forest", "dolly_gate", 1, 1);
			this.s1 = 2;
		}
	} else if (this.s1 == 2) {
		if (this.player_freeze_help()) {
			this.dialogue("forest", "dolly_gate", 0, false);
			this.s1 = 3;
		}
	} else if (this.s1 == 3) {
		if (this.doff()) {
			R.player.pause_toggle(false);
			R.player.enter_cutscene();
			R.player.animation.play("wrr");
			R.player.velocity.x = 80;
			this.s1 = 14;
		}
	} else if (this.s1 == 14) {
		this.t_1 ++;
		if (this.t_1 > 60) {
			this.t_1 = 0;
			R.player.animation.play("irn");
			R.player.velocity.x = 0;
			this.broadcast_tick(false);
			this.s1 = 4;
		}
	} else if (this.s1 == 4) {
			R.player.enter_cutscene();
			//this.velocity.x = 80;
			this.alpha -= 0.03;
			if (this.alpha <= 0) {
				this.velocity.x = 0;
				this.s1 = 5;
				R.player.enter_main_state();
			this.dialogue("forest", "dolly_gate", 1);
			}
	} else if (this.s1 == 5) {
		if (this.doff()) {
			this.s1 = 6;
		}
	} else if (this.s1 == 6) {
		
	}
	
	return;
}


// idle, r, l
// Wait for trigger?
if (this.s1 == 0) {
	this.s2 ++;
	if (this.s2 >= 60 && R.inventory.is_item_found(47)) {
		this.visible = true;
		this.s1 = 1;
	} else {	
		this.visible = false;
		if (this.s2 == 60) {
			this.s2 = 0;
		}
		return;
	}	
} else if (this.s1 == 1) {
	// dollyu consoel and stuffif (this.s1 == 1) {
	if (R.player.overlaps(this.trigger)) {
		this.s1 = 2;
	}
} else if (this.s1 == 2) {
	if (this.player_freeze_help()) {
		this.dialogue("forest", "dolly_talk", 0);
		this.s1 = 10;
	}
} else if (this.s1 == 10 && this.doff()) {
	this.animation.play("windup");
	this.play_sound("lock_shield.wav");
	this.s1 = 11;
	this.t_1 = 0;
} else if (this.s1 == 11) {
	this.t_1 ++;
	if (this.t_1 > 80) {
		this.animation.play("hit");
		this.play_sound("step_tile.wav");
		this.play_sound("pew_hit_shield.wav");
		this.shake(0.02, 0.3);
		this.s1 = 12;
		this.t_1 = 0;
		this.children[0].animation.play("broken");
	}
} else if (this.s1 == 12) {
	this.t_1 ++;
	if (this.t_1 > 80) {
		this.animation.play("idle_l");
		this.t_1 = 0;
		this.s1 = 3;
	}
} else if (this.s1 == 3) {
	this.set_ss("forest", "dolly_gate", 2, 1);
	this.alpha -= 0.020;
	this.s1 = 4;
} else if (this.s1 == 4) {
		this.alpha -= 0.020;
	if (this.alpha <= 0 ) {
		this.velocity.x = 0;
		this.s1 = 5;
	}
}
	
