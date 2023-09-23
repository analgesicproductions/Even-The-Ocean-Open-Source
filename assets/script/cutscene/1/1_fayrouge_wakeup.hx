if (!this.child_init) {
	this.child_init = true;
	this.has_trigger = true;
	this.make_trigger(this.x - 132, this.y-32, 120, 120);
	this.play_anim("idle_l");
	this.s1 = -1;
	
	//this._trace("debug 1_Fayrouge_wakeup");
	//this.s1 = 9;
	return;
}

if (this.s1 == -1) {
	if (R.player.overlaps(this.trigger)) {
		R.TEST_STATE.skip_fade_darken = true;
	}
	//this._trace("debug 1_fayrouge_wakeup");
	//this.set_scene_state("intro", "message", 1, 1);
	//R.set_flag(6, true);
	if (this.get_scene_state("intro", "message", 1) == 1) {
		this.s1 = -2;
		this.visible = false;
		R.TEST_STATE.skip_fade_darken = false;
		if (this.get_event_state(23) == true) {
			this.s1 = -3;
		}
		
		return;
	}
	this.s1 = 0;
}

if (this.s1 == 0) {
	this.t_1++;
	if (this.t_1 < 4) return;
	if (R.player.overlaps(this.trigger)) {
		this.s1 = 1;
		this.camera_to_player();
		this.set_scene_state("intro", "message", 1, 1);
		R.player.change_vistype(0, 0); // force armor aliph
		R.set_flag(6, false);
		R.TEST_STATE.cutscene_handle_signal(0, [0.01]);
		R.player.enter_cutscene();
		R.player.x = R.player.last.x = this.x - 32;
		R.player.y = R.player.last.y = this.y + (this.height - R.player.height);
				
		R.player.facing = 0x10;
		R.player.animation.play("irn");
	}
} else if (this.s1 == 1) {
	if (R.TEST_STATE.cutscene_just_finished(0)) {
		R.actscreen.activate(1, this.parent_state);
		this.s1 = 100;
	}
} else if (this.s1 == 100) {
	if (R.actscreen.is_off()) {
		this.s1 = 2;
		R.TEST_STATE.skip_fade_darken = false;
		R.TEST_STATE.cutscene_handle_signal(2, [0.005]);
		R.song_helper.fade_to_this_song("intro_scene_ambience");
	}
} else if (this.s1 == 2) {
	if (R.TEST_STATE.cutscene_just_finished(2)) {
		this.dialogue("intro", "message", 0,false);
		this.s1 = 3;
	}
} else if (this.s1 == 3 ) {// remove overlay
	if (!this.dialogue_is_on()) {
		this.s1 = 4;
		this.dialogue("intro", "message", 1, false);
	}
} else if (this.s1 == 4) {
	if (!this.dialogue_is_on()) {
		this.s1 = 5;
		this.play_anim("r");
		this.velocity.x = 85;
	}
} else if (this.s1 == 5) {
	if (this.is_offscreen(this)) {
		this.s1 = 6;
		this.dialogue("intro", "message", 8);
		this.energy_bar_move_set(false);
	}
} else if (this.s1 == 6) {
	if (!this.dialogue_is_on()) {
		this.s1 = 7;
		R.player.velocity.x = 100;
		R.player.animation.play("wrr");
		R.player.ignore_y_motion = true;
		//this.pan_camera(0, 0, 20, 0, true);
		this.camera_off();
	}
} else if (this.s1 == 7) {
	if (this.is_offscreen(R.player)) {
		this.s1 = 8;
		R.player.y += 1000;
		R.player.ignore_y_motion = false;
	}
} else if (this.s1 == 8) {
		//private function pan_camera(id:Int, t:Float, vi:Float, vo:Float, dontreturn:Bool = true):Void {
	this.t_1 ++;
	if (this.t_1 > 70) {
		this.s1 = 9;
		R.TEST_STATE.eae.turn_on("INTRO");
	}
} else if (this.s1 == 9) {
	if (R.TEST_STATE.eae.is_off()) {
		this.s1 = 10;
		R.player.facing = 0x0010;
		this.change_map("ROUGE_1", 6,101,true);
	}
}

if (this.s1 == -2 && this.doff()) {
	if (this.trigger.overlaps(R.player)) {
		this.s1 = -50;
	}
} else if (this.s1 == -50) {
	if (this.player_freeze_help()) {
		R.player.pause_toggle(false);
		R.player.enter_cutscene();
		R.player.velocity.x = 80;
		R.player.animation.play("wrr");
		this.s1 = -51;
	}
} else if (this.s1 == -51) {
	if (R.player.x > this.trigger.x + this.trigger.width + 16) {
		R.player.velocity.x = 0;
		R.player.animation.play("irn");
		R.player.facing = 0x0010;
		if (this.get_event_state(6) == true) {
			this.dialogue("intro", "intro_blocker", 1);
		} else {
			this.dialogue("intro", "intro_blocker", 0);
		}
		this.s1 = -52;
	}
} else if (this.s1 == -52 && this.doff()) {
	R.player.enter_main_state();
	this.s1 = -2;
}