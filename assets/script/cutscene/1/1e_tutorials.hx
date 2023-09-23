// after cave


var cv= this.context_values[0];

if (!this.child_init) {
	this.child_init = true;
	this.prevent_shield_lock = false;
	this.has_trigger = true;
	this.make_trigger(this.x, this.y-58, 32, 90);
	//this.only_visible_in_editor = true;
	//this._trace(R.PLAYER_NAME);
	//var skip = false;
	//if (cv == 2 && this.get_scene_state("intro", "cave_tut", 1) == 1) {
		//skip = true;
	//} else if (cv == 3 &&  this.get_scene_state("intro", "cave_tut", 2) == 1) {
		//skip = true;
	//} else if (cv == 4 &&  this.get_scene_state("intro", "cave_tut_2", 1) == 1) {
		//skip = true;
	//}
	//if (skip) {
		//this.s1 = -1;
		//return;
	//}
	this.alpha = 0.25;
	if (cv == 0) {
		this.only_visible_in_editor = true;
		if (this.get_ss("intro", "exit_cave", 1) == 1) {
			this.SCRIPT_OFF = true;
			return;
		} else {
			this.s1 =  255;
		}
	}
	if (cv == 10) {
		
	}
	
	// Thunder snd
	if (cv == 20) {
		this.only_visible_in_editor = true;
		if (this.get_ss("intro", "thunder", 1) >= 1) {
			this.SCRIPT_OFF = true;
			return;
		}
	} 
	// Louder thunder snd
	if (cv == 30) {
		this.s1 = 0;
		this.only_visible_in_editor = true;
		if (this.get_ss("intro", "thunder", 1) >= 2) {
			this.SCRIPT_OFF = true;
			return;
		}
	}
}

if (R.player.overlaps(this)) {
	this.alpha += 0.04;
	if (this.alpha >= 1) this.alpha = 1;
} else {
	this.alpha -= 0.04;
	if (this.alpha < 0.25) this.alpha = 0.25;
}

if (cv == 20) {
	
	if (this.s1 == 0) {
		
		if (R.player.overlaps(this.trigger)) {
			this.s1 = 1;
			
		}
	} else if (this.s1 == 1) {
		R.song_helper.base_song_volume -= 0.03;
		R.song_helper.set_volume_modifier(R.song_helper.get_volume_modifier());
		if (R.song_helper.base_song_volume <= 0.3) {
			R.song_helper.base_song_volume = 0.3;
			this.t_1 ++;
			if (this.t_1 > 30) {
				this.play_sound("lightning_low.wav");
				this.set_ss("intro", "thunder", 1, 1);
				this.shake(0.004, 0.88);
				R.sound_manager.accessibility_str = R.dialogue_manager.lookup_sentence("ui", "sound_labels", 1);
				this.s1 = 2;
				this.t_1 = 0;
			}
			
		}
		
	} else if (this.s1 == 2) {
		this.t_1 ++;
		if (this.t_1 > 30) {
		R.song_helper.base_song_volume += 0.01;
		
		if (R.song_helper.base_song_volume  >= 1) {
			R.song_helper.base_song_volume  = 1;
		}
		R.song_helper.set_volume_modifier(R.song_helper.get_volume_modifier());
		if (R.song_helper.base_song_volume  >= 1) {
			this.s1 = 3;
			this.SCRIPT_OFF = true;
		}
		}
	}
	
	return;
}

if (cv == 30) {
	
	if (this.s1 == 0) {
		if (R.player.overlaps(this.trigger)) {
			
			
			this.s1 = 1;
			this.energy_bar_move_set(false, true);
		}
	} else if (this.s1 == 1) {
		if (this.player_freeze_help()) {
			
			R.song_helper.base_song_volume -= 0.03;
			R.song_helper.set_volume_modifier(R.song_helper.get_volume_modifier());
			if (R.song_helper.base_song_volume <= 0.3) {
				R.song_helper.base_song_volume = 0.3;
			this.s1 = 2;
			this.t_1 = 0;
			}
			
		}
	} else if (this.s1 == 2) {
		this.t_1 ++;
		if (this.t_1 == 30) {
			this.play_sound("lightning_mid.wav");
			
			this.shake(0.013, 0.65);
			R.sound_manager.accessibility_str = R.dialogue_manager.lookup_sentence("ui", "sound_labels", 1);
		}
		if (this.t_1 == 90) {
			this.dialogue("intro", "thunder", 0);
			this.set_ss("intro", "thunder", 1, 2);
			this.s1 = 3;
		}
	} else if (this.s1 == 3 && this.doff()) {
		R.song_helper.base_song_volume += 0.01;
		if (R.song_helper.base_song_volume  >= 1) {
			R.song_helper.base_song_volume  = 1;
		}
		R.song_helper.set_volume_modifier(R.song_helper.get_volume_modifier());
		if (R.song_helper.base_song_volume  >= 1) {
			this.s1 = 4;
			this.SCRIPT_OFF = true;
		}
	}
	return;
	
}


if (this.s1 == 255) {
	if (R.player.overlaps(this)) {
		this.s1 = 256;
	}
	return; 
} else if (this.s1 == 256) {
	if (this.player_freeze_help()) {
		this.dialogue("intro", "exit_cave", 0);
		this.set_ss("intro", "exit_cave", 1, 1);
		this.s1 = 257;
	}
}

if (this.s1 == 0 && this.doff()) {
	//if (R.player.overlaps(this.trigger)) {
	if (this.try_to_talk(this, 0, true)) {
		if (cv == 10) {
			this.dialogue("intro", "cave_tut_2", 2);
		} else if (cv == 11) {
			this.dialogue("intro", "save_point", 0);
		} else {
			this.s1 = 1;
		}
		//if (cv == 2) { // energy, wall climb, wall jump
			//this.set_scene_state("intro", "cave_tut", 1, 1);
		//} else if (cv == 3) {
			//this.set_scene_state("intro", "cave_tut", 2, 1);
		//} else if (cv == 4) {
			//this.set_scene_state("intro", "cave_tut_2", 1, 1);
		//}
		
	}
} else if (this.s1 == 1) {
	if (this.player_freeze_help()) {
		if (cv == 2) { // energy, wall climb, wall jump
			this.dialogue("intro", "cave_tut", 0);	
		} else if (cv == 3) {
			this.dialogue("intro", "cave_tut", 3);	
		} else if (cv == 4) {
			this.dialogue("intro", "cave_tut_2", 0);	
		}
		this.s1 = 2;
	}
} else if (this.s1 == 2) {
	if (!this.dialogue_is_on()) { // Yes or No to seeing first tutorial
		//if (this.d_last_yn() == 0) {
			this.s1 = 3;
			this.run_tutorial(cv+1); // 3,4,5 = en, wall climb, wall jump
		//} else {
			//this.s1 = 0;
		//}
	}
} else if (this.s1 == 3) {
	if (this.tutorial_done()) {
		this.s1 = 0;
	}
} else if (this.s1 == 4) {
	
}