if (!this.child_init) {
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	this.s2 = 0;
	
	// Auto-warps you.
	// Note: debug stuff still in here!
	
	//this._trace("DEBUG 8g_final");
	//this.set_ss("ending", "flood", 1, 1);
	
	this.make_child("yara",false,"idle");
	this.make_child("humus",false,"idle");
	if (this.get_ss("ending", "flood", 1) == 1) {
		this.set_event(50);
		R.gs1 = 0;
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	
	if (this.get_ss("cutTEST","a",1) == 1) {
		this.s1 = 5;
		this.t_1 = 26 * 60 + 60*6;
		R.TEST_STATE.cutscene_handle_signal(0, [1.0 / (60 * 1.0)]);
	} else {
		R.TEST_STATE.cutscene_handle_signal(2, [1.0 / (6)]);
	}
}
var yara = this.sprites.members[0];
var humus = this.sprites.members[1];
if (this.s1 == 0) {
	this.t_1 ++;
	if (this.t_1 > 2) {
		
		// Debug
		if (false) {
			this._trace("8g final skip ialogue");
			//this.s1 = 10; // straight to final warp  
			this.s1 = 4; // show humus reveal, credits
			this.t_1 = 1213214;
			R.player.x = this.x+10;
			R.player.y = this.y + this.height - R.player.height;
		} else {
			this.energy_bar_move_set(false); 
			R.player.enter_cutscene();
			R.player.pause_toggle(false); // Stop player from moving or whatever but allow it to automove
			// play soft rain
			//this.play_music("rain");
			this.cam_to_id(1); // Instantly snap camera to this ID and unfollow player
			this.set_vars(yara, this.x + 32, this.y, 1);
			this.set_vars(humus, this.x - 64, this.y, 1);
			humus.scale.x = -1;
			R.player.facing = 0x1;
			R.player.animation.play("iln");
			R.player.x = this.x+10;
			R.player.y = this.y + this.height - R.player.height;
			
			// tests from the final dialogue
			//this.s1 = 2;
			
			// tests from song
			//this.s1 = 3;
			//return;
			
			// Tests the yara quote.
			//this.s1 = 4;
			//this.t_1 = 87 * 60;
			//return;
			
			this.s1 = 100;
			
			//this.s1 = 1000;
			//this.s1 = 5;
			//this.t_1 = 14 * 60 + 12 + 60 * 6;
			//this.t_1 = 0;
			
			R.TEST_STATE.cutscene_handle_signal(2, [0.005]);
			
			
			R.song_helper.stop_song_changes = false;
			this.play_music("wf_after_tower", false);
			
			//this.s1 = 8; // test from humus last
		}
	}
} else if (this.s1 == 100) {
	//this.t_1 ++;
	//if (this.t_1 > 40) {
	if (R.TEST_STATE.cutscene_just_finished(2)) {
		R.TEST_STATE.cutscene_handle_signal(4, [0xff000000]); // make it black
		this.dialogue("ending", "final", 0, false);
		this.s1 = 1;
	}
	//}
	
} else if (this.s1 == 1) {
	//SILENCE
	//talk 2
	if (this.doff()) {
		//this.play_music("rain");
		this.dialogue("ending", "final_2", 0,false);
		this.s1 = 2;
	}
	
} else if (this.s1 == 2) {
	
	if (this.doff()) {
		this.t_1 ++;
		if (this.t_1 > 120) {
			this.dialogue("ending", "final_2", 11, false);
			R.player.animation.play("irn");
			this.s1 = 3;
			this.t_1 = 0;
			this.play_music("null",false);
		}
	}
} else if (this.s1 == 3) {
	// ending thing
	if (this.doff()) {
		//R.song_helper.fade_to_this_song("wf_eto_song",false,"null");
		this.t_1 ++;
		if (this.t_1 == 1) {
			this.set_ss("ending", "final", 1, 1);
		} else if (this.t_1 == 60) {
			this.s1 = 1000;
			R.easycutscene.activate("4d_lullaby");
			R.player.energy_bar.OFF = true;
			this.t_1 = 0;
		}
	}
} else if (this.s1 == 1000) {
	// Playflood music. wait a while to start fading to white
	if (R.easycutscene.is_off()) {
		if (this.t_1 == 0) {
			this.play_music("flood", false);
		}
		this.t_1++;
		if (this.t_1 == 240) {
			R.TEST_STATE.cutscene_handle_signal(0, [1 / (60.0 * 9), 0xffffffff], true);
			this.t_1 = 0;
			this.s1 = 1001;
		}
	}
} else if (this.s1 == 1001) {
	// when faded to white, go on
	if (R.TEST_STATE.cutscene_just_finished(0)) {
		this.s1 = 4;
		this.t_1 = 0;
	}
} else if (this.s1 == 4) {
	// hang on white for a few seconds.
	this.t_1++;
	if (this.t_1 >= 120) {
		// Start fading the quote and easycut layer underneath the white
		R.easycutscene.activate("4e_yaraquote");
		this.s1 = 5;
		this.t_1 = 0;
	}
} else if (this.s1 == 5) {
	this.t_1++;
	// stop the flood music after quote has faded in
	// make sure the song gfades out slow
	if (this.t_1 == 100) {
		this.play_music("null", false);
		R.song_helper.FADE_OUT_SLOW = true;
		R.song_helper.FADE_OUT_FAST = false;
		R.TEST_STATE.cutscene_handle_signal(2, [1 / (180.0)], true);
	}
	// helps the song fade out slower
	if (this.t_1 >= 100 && this.t_1 <= 100+180) {
		R.song_helper.base_song_volume += 1.0 / 180.0;
	}
	
	// change the now-invisible fg_fade to balck agian and begin to fade it in
	if (this.t_1 == 14*60 + 12 + 60*1) {
		R.TEST_STATE.cutscene_handle_signal(4, [0xff000000]); // make it black
		R.TEST_STATE.cutscene_handle_signal(0, [1.0 / (60 * 2.0)]);
	}
	// show last humus
	if (this.t_1 > 14*60 + 12 + 60*2) {
		if (false) {
			this._trace("DEBUG 8g_final skip sng and humus");
			this.s1 = 7;
			this.credits_on();
		} else {
			//this.play_music("null");
			if (R.easycutscene.is_off()) {
				R.easycutscene.activate("4f_humus");
				//this.dialogue("ending", "final_humus", 0);
				this.t_1 = 0;
				this.s1 = 6;
			}
		}
	}
	
} else if (this.s1 == 6 ) {
	if (this.t_1 >= 0 && this.t_1 <= 3) {
		this.t_1++;
		if (this.t_1 == 3) {
			// fade out the fg fade again
			R.TEST_STATE.cutscene_handle_signal(2, [1.0 / (60 * 1.0)]);
		}
	}
	
	if (R.easycutscene.ping_last) {
		R.easycutscene.ping_last = false;
		R.TEST_STATE.cutscene_handle_signal(0, [1.0]);
	}
	
	if (R.easycutscene.is_off()) {
		this.t_1 ++;
		if (this.t_1 > 30) {
			this.t_1 = 0;
			this.s1 = 7;
			this.credits_on();
		}
		//activates credits
	}
} else if (this.s1 == 7) {
	if (R.credits_module.is_done()) {
		this.s1 = 8;
		this.credits_off();
	}
} else if (this.s1 == 8) {
	this.dialogue("ending", "post_credits", 0);
	this.s1 = 9;
	this.t_1 = 0;
} else if (this.s1 == 9) {
	if (this.doff()) {
		this.t_1 ++;
		if (this.t_1 > 30) {
			//this.dialogue("ending", "post_credits", 9);
			this.s1 = 10;
		}
	}
} else if (this.s1 == 10) {
	if (this.doff()) {
		//this.parent_state.add(R.save_module);
		
		// ask to save
		//R.TEST_STATE.MAP_NAME = "RADIO_LOBBY";
		//R.player.x = 5 * 16;
		//R.player.y = 9 * 16 - R.player.height;
		//R.save_module.can_cancel = false;
		
		// undo smoe dialogue flags
		//this._trace("undo radio tower done");
		//R.event_state[47] = 0;
		//this.set_ss("ending", "radio_end", 1, 0);// (set at top of radio tower?)
		//this.set_ss("ending", "init_yara", 1, 0); 
		//this.set_ss("ending", "flood", 1, 0);
		
		
		// save
		//public static inline var MODE_SAVE:Int = 1;
		//R.save_module.activate(1, R.player.x, R.player.y);
		this.s1 = 11;
	}
} else if (this.s1 == 11) {
	//if (R.save_module.is_idle()) {
		//this.parent_state.remove(R.save_module, true);
		this.s1 = 12;
		this.t_1 = 0;
	//}
} else if (this.s1 == 12) {
	//this.t_1 ++;
	//if (this.t_1 > 40) {
		//R.TEST_STATE.do_title_from_credits  = true;
		this.change_map("WF_LO_0", 11, 22, true);
		R.player.energy_bar.OFF = false;
		this.s1 = 13;
	//}
}

//start fading out during it . triggers HUMUS script that fades out