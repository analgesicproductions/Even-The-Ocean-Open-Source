
if (!this.child_init) {
	this.child_init = true;
	
	this.s1 = 0;
	
	//R.set_flag_bitwise(46, 0x001);
	//R.set_flag_bitwise(46, 0x010);
	//R.set_flag_bitwise(46, 0x100);

	
	//this.set_event(17);
	// earth done
	
	//this.s1 = 1;
	//this._trace("test picnic");
		//R.gs1 = 1;
	if (R.gs1 == 1) {
		R.gs1 = 0;
		this.s1 = 1;

		// Picnic basket
		//this.make_child("vale",false,"idle"); // vale
		//this.set_vars(this.sprites.members[0], this.x -32, this.y, 1);

		
		this.animation.play("sit");
		R.player.enter_cutscene();
		R.player.animation.play("sit_down_r");
		R.player.x = R.player.last.x = this.x - 20;
		R.player.y = R.player.last.y = this.y + this.height - R.player.height;
		this.t_1 = -10;
	} else {
		this.only_visible_in_editor = true;
		
		if (R.TEST_STATE.bg_parallax_layers.members.length > 2) {
			R.TEST_STATE.bg_parallax_layers.members[2].alpha = 0;
		}
	}
}


if (this.s1 == 0) {
	return;
} 

if (this.s1 == 1) {
	this.t_1 ++;
	if (this.t_1 > 15) {
		this.s1 = 2;
		this.dialogue("pass", "picnic", 0);
		this.t_1 = 0;
	}	
} else if (this.s1 == 2 && this.doff()) {
	
	if (this.t_1 == 0) {
		R.player.animation.play("sit_up_r");
	}
	this.t_1++;
	if (this.t_1 == 20) {
		R.player.animation.play("irn");
		R.player.enter_main_state();
		this.s1 = 3;
		this.t_1 = 0;
	}
} else if (this.s1 == 3) {
	if (this.try_to_talk()) {
		this.dialogue("pass", "picnic", 20);
	}
	if (R.player.x > 125*16) {
		R.player.enter_cutscene();
		this.s1 = 4;
		R.player.velocity.x = -80;
		R.player.animation.play("wll");
	} else if (R.player.x < 86 * 16) {
		R.player.enter_cutscene();
		this.s1 = 4;
		R.player.velocity.x = 80;
		R.player.animation.play("wrr");
	}
	
	//45 32
	if (R.player.x > 108 * 16 && R.player.x < 114* 16 && R.player.y > 23 * 16 && R.player.y < 34 * 16) {
		this.s1 = 600;
		if (R.story_mode) {
			this.change_map("PASS_B", 4, 13, true);
		} else {
			this.change_map("PASS_G0", 16, 32, true);
		}
		R.player.enter_door();
	}
} else if (this.s1 == 4) {
	if (R.player.x < 122*16  && R.player.x > 88*16) {
		if (R.player.velocity.x > 0) {
			R.player.animation.play("irn");
			R.player.facing = 0x0010;
			R.player.enter_main_state();
		} else {
			R.player.animation.play("iln");
			R.player.facing = 0x001;
			R.player.enter_main_state();
		}
		R.player.velocity.x = 0;
		this.s1 = 3;
	}
} else if (this.s1 == 600) {
}

