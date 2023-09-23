
//{ ending_flood
//script s "cutscene/8/8f_flood.hx"
//}

if (!this.child_init) {
	this.child_init = true;
	
	this.only_visible_in_editor = true;
	
	this.s1 = 0;
	this.s2 = 0;
	
	/* [Debug function description] */
	//this._trace("DEBUG IN 8f_flood");
	//this.set_ss("ending", "init_yara", 1, 1);
	//R.event_state[19] = true;
	//R.event_state[18] = true;
	//R.event_state[47] = true;
	//this.play_music("flood");
	
	
	// map3 northern cont
	if (this.context_values[0] == 2) {
		this.s2 = 2; // map...
	}  else if (this.context_values[0] == 3) {
		this.s2 = 3; // ETC
	}
	
	/* Check for dialogue flag */
	if (this.get_ss("ending", "flood", 1) == 0 && this.get_ss("ending", "init_yara", 1) == 1) {
		R.gs1 = 245; // To turn off 1h_world_map
		
		this.play_music("flood", false);
		R.song_helper.stop_song_changes = true;	
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
	
	
	this.sf1 = 0.0;
}


if (this.s1 == 0) {
	this.t_1 ++;
	if (this.t_1 < 3) return;
	
	this.camera_off();
	
	for (i in [0,1,2,3]) {
		this.children[i].alpha = 0;
		if (this.s2 == 3) this.children[i].alpha = 1;
		this.children[i].scrollFactor.set(0, 0);
	}
	this.children[0].move(0, 80);
	this.children[1].move(0, 80);
	this.children[2].move(0, 16);
	this.children[3].move(0, 16);
	if (this.s2 == 2) {
		this.move_cam(708, 77);
		this.s1 = 1;
	} else {
		this.move_cam(1723, 126);
		this.sf1 = 77;
		this.s1 = 3;
	}
	
} else if (this.s1 == 1) {
	// Wait 3  + 7  sec 
	this.t_1 ++;
	//this.t_1 = 600;
	
	if (this.t_1 == 60 * 3) {
		R.sound_manager.accessibility_str = R.dialogue_manager.lookup_sentence("ui", "sound_labels", 2);
	}
	if (this.t_1 >= 60*10) {
		this.s1 = 2;
		this.t_1 = 0;
		this.shake(0.005, 2);
	}
} else if (this.s1 == 2) {
	// 2 s: fade in setpieces
	
	for (i in [0, 1, 2, 3]) {
		this.fade_in(this.children[i],1/120.0,1,0.99,1);
	}
	this.t_1 ++;
	if (this.t_1 >= 60*2) {
		this.s1 = 3;
		this.t_1 = 0;
	}
} else if (this.s1 == 3) {
	// Accel to max of 77. 
	if (this.sf1 < 77) {
		this.sf1 += 12.8 * (1 / 60.0); // increase current velocity based on an accel
	}
	
	var _x = this.camera_edge(true,false,true);
	var _y = this.camera_edge(false, true, true);
	_y += this.sf1 * (1 / 60.0); // increase position
	this.move_cam(_x, _y);
	
	if (_y >= 979 && this.s2 == 2) {
		this.s1 = 4;
		R.TEST_STATE.cutscene_handle_signal(0, [0.008, 0xffffffff], true);
	} else if (_y >= 900 && this.s2 == 3) {
		this.s1 = 4;
		R.TEST_STATE.cutscene_handle_signal(0, [0.012, 0xffffffff], true);
	}
	
	// 6 s: accel down
} else if (this.s1 == 4) {
	var _x = this.camera_edge(true,false,true);
	var _y = this.camera_edge(false, true, true);
	_y += this.sf1 * (1 / 60.0); // increase position
	if (this.s2 == 3) {
		//this.sf1 -= 77.0 / 120.0;
	}
	this.move_cam(_x, _y);
	if (R.TEST_STATE.cutscene_just_finished(0)) {
		this.s1 = 5;
		this.t_1 = 0;
	}
} else if (this.s1 == 5) {
	if (this.s2 == 3) {
		R.song_helper.cur_song.volume -= 1.0 / 180.0;
		R.song_helper.base_song_volume -= 1.0 / 180.0;
	}
	this.t_1 ++;
	if ((this.s2 == 2 && this.t_1 == 80) || (this.s2 == 3 && this.t_1 > 280)) {
		this.t_1 = 0;
		this.s1 = 10;
	}
} else if (this.s1 == 6) {
} else if (this.s1 == 7) {
} else if (this.s1 == 8) {
} else if (this.s1 == 9) {
} else if (this.s1 == 10) {
	if (this.s2 == 2) {
		this.change_map("MAP1", 1, 1, true); // 
	} else if (this.s2 == 3) {
		this.stop_invisible_player_cutscene("WF_LO_1", 1, 1);
		R.player.enter_main_state();
		this.set_ss("ending", "flood", 1,1);
		R.TEST_STATE.skip_fade_lighten = true;
	} 
	this.s1 = 11;
} 