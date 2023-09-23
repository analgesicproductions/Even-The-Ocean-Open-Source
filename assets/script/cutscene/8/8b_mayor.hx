if (!this.child_init) {
	this.has_trigger = true;
	this.make_trigger(this.x+144, this.y-100, 20, 132);
	this.child_init = true;
	this.only_visible_in_editor = true;
	this.s1 = 0;
	this.s2 = 0;
	
	//this._trace("DEBUG 8c_mayor");
	//this.set_ss("ending", "city_enter", 1, 1);
	//this.set_ss("ending", "mayor", 1, 0);
	//this.play_music("rain");
	//this.s1 = 2;
	
	if (this.get_ss("ending", "city_enter", 1) == 1 && this.get_ss("ending","mayor",1) == 0) {
		this.make_child("biggs",false,"idle");
		this.make_child("", false, "", false, 0xff50ef9e); // beam
		this.make_child("mayor_bullet", false, "charge"); // bullet 
		this.make_child("mayor_bullet", false, "tip"); // bullet 
		this.set_vars(this.sprites.members[0], this.x, this.y, 1);
		this.set_vars(this.sprites.members[2], this.x - 32, this.y, 1);
		this.set_vars(this.sprites.members[3], this.x - 32, this.y, 1);
		this.set_vars(this.sprites.members[1], this.x - 32, this.y, 1);
		this.sprites.members[2].alpha = 0.8;
		this.sprites.members[3].alpha = 0;
		this.sprites.members[1].alpha = 0;
		this.sprites.members[1].origin.set(0, 0);
		R.player.x = R.player.last.x = 849;
		R.player.y = R.player.last.y = 315;
		R.player.facing = 0x1;
		R.ignore_door = true;
	} else {
		this.SCRIPT_OFF = true;
		return;
	}
}
//this._trace(R.attempted_door);

var mayor = this.sprites.members[0];
var bullet = this.sprites.members[2];
var tip = this.sprites.members[3];
var beam = this.sprites.members[1];
bullet.width = bullet.height = 8;
tip.offset.set(4, 4);
tip.width = tip.height = 8;
beam.scale.y = 2;


if (this.s1 == 0) {
	bullet.alpha = 0;
	mayor.scale.x = -1;
	if (this.s2 == 1) {
		if (this.player_freeze_help()) {
			this.s2 = 4;
			this.camera_off();
			this.pan_camera(10, 0.5, 100, 50, true, false);

			
			this.set_ss("ending", "mayor", 1, 1);
			R.player.energy_bar.OFF = true;
		}
	} else if (this.s2 == 4) {
		this.t_1++;
		if (this.t_1 > 40) {
			this.s1 = 1;
			this.dialogue("ending", "mayor", 0);
			this.t_1 = 0;
		}
	// out of bounds
	} else if (this.s2 == 2) {
		if (this.player_freeze_help()) {
			this.dialogue("ending", "elevator", 1);
			this.s2 = 3;
		}
	} else if (this.s2 == 3 && this.doff()) {
		R.attempted_door = "";
		this.s2 = 0;
	} else if (this.doff()) {
			if (R.player.overlaps(this.trigger)) {
				this.s2 = 1;
			}
			if (R.attempted_door != null && R.attempted_door.length > 1) {
				this.s2 = 2;
			}
	}
} else if (this.s1 == 1 && this.doff()) {
//<rumble/screenshake. The apex section begins to rise. Cutscene showing this from a further out angle.
//Aliph runs to eadge to see what’s happening?>
	R.player.pause_toggle(true);
	R.easycutscene.activate("4b_mayor");
	this.s1 = 2;
} else if (this.s1 == 2 && R.easycutscene.is_off()) {
	R.player.pause_toggle(false);
	this.s1 = 10;
	this.dialogue("ending", "mayor_2", 0);
} else if (this.s1 == 10 && this.doff()) {
// aliph steps lcoser
this.s1 = 11;
} else if (this.s1 == 11) {
	this.dialogue("ending", "mayor_3", 0);
	this.s1 = 12;
} else if (this.s1 == 12 && this.doff()) {
	
// mayor aims gun
this.s1 = 13;
mayor.animation.play("gun_l");
bullet.alpha = 0.8;
bullet.x = mayor.x + 20;
bullet.y = mayor.y + 9;
} else if (this.s1 == 13) {
	// If anim done..
	this.dialogue("ending", "mayor_3", 2);
	this.s1 = 14;
	this.t_1 = 0;
} else if (this.s1 == 14) {
	if (this.t_1 == 0) {
		this.play_sound("followLaserHit.wav");
	}
	this.t_1++;
	if (this.t_1 == 60) {
		R.player.enter_cutscene();
		this.t_1 = 0;
	}
	if (this.doff()) {
		this.s1 = 15;
	}
	
//aliph runs to mayor with shield
} else if (this.s1 == 15) {
	// If aliph close enough
	// Stop aliph / change anim
	//mayor yells
	this.s1 = 16;
	this.t_1 = 0;
} else if (this.s1 == 16 && this.doff()) {
	this.t_1 ++;
	
	if (this.t_1 > 30) {
		mayor.animation.play("recoil");
		R.player.enter_cutscene();
		R.player.animation.play("ill");
		this.play_sound("lock_shield.wav");
		R.player.draw_start_lock_shield_effect = true;
		tip.alpha = 1;
		beam.alpha = 1;
		tip.x = R.player.x - 14;
		tip.y = R.player.y + 2;
		tip.alpha = 0.8;
		beam.x = bullet.x + 8;
		beam.y = bullet.y + 7;
		beam.scale.x = tip.x - bullet.x - 5;
		beam.alpha = 0.7;
		this.s1 = 17;
		this.t_1 = 0;
	}
// wait a bit..
// Mayor shoot anim, aliph starts running 
} else if (this.s1 == 17) {
//check for energy/bullets bounce off shield

	beam.alpha = this.random() * 0.5 + 0.3;
	this.t_1 ++;
	if (this.t_1 == 60) {
		R.player.animation.play("wll");
		R.player.velocity.x = -70;
		R.TEST_STATE.cutscene_handle_signal(0, [0.03]);
	}
//Aliph knocks out the mayor with shield (pause motion a bit, play sound)
	// fade in to black

	tip.x = R.player.x - 14;
	tip.alpha = 0.8;
	beam.x = bullet.x + 8;
	beam.scale.x = tip.x - bullet.x - 5;
	
	if (R.TEST_STATE.cutscene_just_finished(0)) {
		this.s1 = 18;
		R.player.velocity.x = 0;
		this.t_1 = 0;
	}

} else if (this.s1 == 18 && this.doff()) {
	
	this.t_1++;
	if (this.t_1 == 40) {
		this.play_sound("OuchOutlet_Shock.wav");
		this.play_sound("OuchOutlet_Shock.wav");
		//this.play_sound("pew_hit.wav");
		this.t_1 = 0;
		this.s1 = 19;
		this.dialogue("ending", "mayor_3", 9);
		mayor.animation.play("dead");
		R.player.animation.play("iln");
		R.player.last.x = R.player.x = mayor.x + mayor.width + 4;
		bullet.alpha = beam.alpha = tip.alpha = 0;
	}
} else if (this.s1 == 19 && this.doff()) {
	
	this.t_1++;
	if (this.t_1 == 1) {
		R.TEST_STATE.cutscene_handle_signal(2, [0.03]);
	}
	
	if (R.TEST_STATE.cutscene_just_finished(2)) {
		this.dialogue("ending", "mayor_3", 10);
		this.s1 = 20;
		this.t_1 = 0;	
	}
} else if (this.s1 == 20 && this.doff()) {
	this.t_1 ++;
	if (this.t_1 > 30) {
		this.dialogue("ending", "wf_cut_rise", 2);
		this.s1 = 100;
	}
} else if (this.s1 == 100 && this.doff()) {
	this.s1 = 101;
	
	// turn off rain
		R.song_helper.permanent_song_name = R.song_helper.permanent_song_name.substr(0, 0);
		if (R.story_mode) {
			this.change_map("RADIO_B2", 12, 25, true);
		} else {
			this.change_map("RADIO_G1", 111, 100, true);
		}
	// cahgne map
}