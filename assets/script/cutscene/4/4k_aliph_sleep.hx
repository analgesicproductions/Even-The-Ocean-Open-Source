/* DEPRECATED 2015 11 23*/
//{ g2_1_aliph_sleep
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	this.s2 = 0;
	if (this.get_ss("g2_1", "aliph_apt", 1) == 1) {
		this.set_ss("g2_1", "aliph_apt", 1, 2);
		R.player.enter_cutscene();
		R.player.animation.play("irn");
		R.player.x = this.x; // TO DO initi posotion
		R.player.y = this.y;
		R.TEST_STATE.skip_fade_lighten = true;
		this.play_music("null");
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
}
if (this.s1 == 0) {
	R.TEST_STATE.cutscene_handle_signal(0, [0.01]);	
	this.s1 = 1;
} else if (this.s1 == 1) {
	if (R.TEST_STATE.cutscene_just_finished(0)) {
		this.s1 = 2;
	}
} else if (this.s1 == 2) {
	this.t_1 ++;
	if (this.t_1 > 120) {
		this.t_1 = 0;
		this.dialogue("g2_1", "aliph_apt", 0,false);
		this.s1 = 3;
	}
} else if (this.s1 == 3) {
	if (this.doff()) {
		R.TEST_STATE.cutscene_handle_signal(2, [0.02]);
		this.play_music("aliph_new_apt");
		this.dialogue("g2_1", "aliph_apt", 2);
		//R.player.pause_toggle(false);
		this.s1 = 4;
	}
} else if (this.s1 == 4) {
	if (R.TEST_STATE.cutscene_just_finished(2)) {
		//R.player.scale.x = 2;
		this.s2 = 1;
	} 
	if (this.s2 == 1 && this.doff()) {
		this.s2 = 0;
		R.player.velocity.x = 80;
		R.player.animation.play("wrr");
		this.s1 = 5;
	}
} else if (this.s1 == 5) {
	if (R.player.x - this.x > 64) { // TODO cofffe make position
		R.player.velocity.x =  0;
		R.player.animation.play("irn");
		this.dialogue("g2_1", "aliph_apt", 3,false);
		this.s1 = 6;
	}
} else if (this.s1 == 6) {
	if (this.doff()) {
		this.t_1 ++;
		if (this.t_1 == 30) {
			// snd
			this.play_sound("SapPad.wav");
		} else if (this.t_1 == 60) {
			this.s1 = 7;
			this.t_1 = 0;
			this.dialogue("g2_1", "aliph_apt", 4,false);
		}
	}
} else if (this.s1 == 7 && this.doff()) {
	R.player.alpha -= 0.02;
	if (R.player.alpha <= 0) {
		this.t_1 ++;
		if (this.t_1 == 60) {
			this.t_1 = 0;
			this.s1 = 8;
			R.player.x -= 32; // TODO coffee postion
		}
	}
} else if (this.s1 == 8) {
	R.player.alpha += 0.02;
	if (R.player.alpha >= 1) {
		this.dialogue("g2_1", "aliph_apt", 5);
		this.s1 = 9;
	}
} else if (this.s1 == 9) {
	if (this.doff()) {
		R.player.enter_main_state();
		this.s1 = 10;
	}
}
