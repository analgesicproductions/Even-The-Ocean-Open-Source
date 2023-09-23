//{ screen_kv
//script s "person/city/screen_kv.hx"
//}
if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	this.s2 = 0;
	this.s3 = 0;
	//this._trace("DEBUG screen_kv");
	
	//this.set_event(44);
	
	if (R.TEST_STATE.MAP_NAME == "KV_GOV") {
		this.s2 = 0;
		R.player.enter_cutscene();
		R.TEST_STATE.dialogue_box.speaker_always_none = true;
		R.TEST_STATE.dialogue_box.IS_SCREEN_AREA = true;
		return;
	} else {
		this.s2 = 1;
		this.s1 = -1;
	}
	
}


if (this.s1 == 0 && this.s2 == 0) {
	this.camera_off();
	this.cam_to_id(0);
	// turned off in TestState.update_mode_change part 1 so the energy bar doesnt appear till youre gone
	R.player.energy_bar.OFF = true;
}

if (this.s2 == 0) {
	R.player.x = 500;
	R.player.y = 300;
	R.player.velocity.y = 0;
}

// KV GOV OFFICE
if (this.s2 == 0) {
	if (this.s1 == 0) {
		if (this.get_ss("s3", "kv_maps", 1) == 0) {
			this.dialogue("s3", "kv_maps", 0);
			this.set_ss("s3", "kv_maps", 1, 1);
		} else {
			this.dialogue("s3", "kv_maps", 4);
		}
		this.s1 = 1;
	} else if (this.s1 == 1) {
		if (this.doff()) {
			this.change_map("KV_RADIO", 29, 30, true);
			R.player.facing = 0x10;
			
		R.TEST_STATE.dialogue_box.speaker_always_none = false;
			this.s1 = 2;
		}
	}
// KV BEDROOM
} else {
	if (this.s1 == -1) {
		if (this.try_to_talk()) {
			if (this.event(43) && this.get_ss("s3","debrief",1) == 1 && this.get_ss("s3", "yara", 1) == 0) {
				this.s1 = 0;
				this.dialogue("s3", "bed", 0);
			} else if (this.event(44) && this.get_ss("s3","debrief_2",1) == 1 && this.get_ss("s3", "yara_2", 1) == 0) {
				this.s1 = -2;
				this.dialogue("s3", "bed", 0);
			} else {
				this.s1 = 4;
				this.dialogue("s3", "bed", 2);
			}
		}
	} else if (this.s1 == 0) {
		if (this.doff()) {
			R.TEST_STATE.cutscene_handle_signal(0, [0.04]);
			R.input.lr_toggle(false);
			this.s1 = 1;
		}
	} else if (this.s1 == -2) {
		if (this.doff()) {
			R.TEST_STATE.cutscene_handle_signal(0, [0.04]);
			R.input.lr_toggle(false);
			this.s1 = 2;
		}
	} else if (this.s1 == 1) {
		if (R.TEST_STATE.cutscene_just_finished(0)) {
			R.TEST_STATE.dialogue_box.speaker_always_none = true;
			R.TEST_STATE.dialogue_box.IS_SCREEN_AREA = true;
			R.player.enter_cutscene();
			this.set_ss("s3", "yara", 1, 1);
			R.easycutscene.activate("3g_g7_yara");
			this.s1 = 10;
			this.t_1 = 0;
		}
	} else if (this.s1 == 2) {
		if (R.TEST_STATE.cutscene_just_finished(0)) {
			R.TEST_STATE.dialogue_box.speaker_always_none = true;
			R.TEST_STATE.dialogue_box.IS_SCREEN_AREA = true;
			R.player.enter_cutscene();
			this.set_ss("s3", "yara_2", 1, 1);
			R.easycutscene.activate("3h_g8_yara");
			this.s1 = 3;
			this.t_1 = 0;
		}
	} else if (this.s1 == 10) {
		this.t_1++;
		if (this.t_1 == 100) {
			R.TEST_STATE.cutscene_handle_signal(2, [0.1]);
		}
		
		if (R.TEST_STATE.cutscene_just_finished(2)) {
			
		}
		
		if (R.easycutscene.is_off()) {
			this.s1 = 4;
			R.player.animation.play("irn");
			R.input.lr_toggle(true);
			this.dialogue("s3", "wakeup_after_g7", 0);
		}
	} else if (this.s1 == 3) {
		
		
		this.t_1++;
		if (this.t_1 == 100) {
			R.TEST_STATE.cutscene_handle_signal(2, [0.1]);
		}
		
		if (R.TEST_STATE.cutscene_just_finished(2)) {
		}
		
		if (R.easycutscene.is_off()) {
			this.s1 = 4;
			R.player.animation.play("irn");
			R.input.lr_toggle(true);
			this.dialogue("s3", "bed", 1);
		}
	} else if (this.s1 == 4 && this.doff()) {
		
		R.TEST_STATE.dialogue_box.speaker_always_none = false;
		R.TEST_STATE.dialogue_box.IS_SCREEN_AREA = false;
		R.player.enter_main_state();
		this.s1 = 5;
	} else if (this.s1 == 5) {
		this.s1 = -1;
	}
}



