// earthquake

if (!this.child_init) {
	this.child_init = true;
	this.make_child("intro_bridge",false,"idle",true); 
	this.make_child("intro_lightning",false,"",true); 
	this.has_trigger = true;
	this.make_trigger(this.x-64, this.y-200, 32, 72);
	this.play_anim("shock"); // Cassidy has shock anim
	this.fg_sprites.members[0].height = 16;
	this.fg_sprites.members[0].offset.y = 112;
	this.set_vars(this.fg_sprites.members[0], this.x - 80, this.y - 144, 1, true);
	this.fg_sprites.members[1].move(this.fg_sprites.members[0].x + 64, this.fg_sprites.members[0].y - 80 - 112);
	//this.sprites.members[0].exists = true;
	//this.sprites.members[0].alpha = 1;
	
	// Bridge, lightning, Cassidy not visible - also send signal to barbed wire to disappear?
	if (this.get_scene_state("intro", "earthquake", 1) == 1) {
		this.s1 = -1;
		this.only_visible_in_editor = true;
		this.fg_sprites.members[0].y += 8 * 16;
		this.fg_sprites.members[0].offset.y += 3;
		
		//this.sprites.members[0].alpha = 0;
		
		this.broadcast_to_children("dark_off");
		return;
	}
	
	//this.s1 = 6;
}


var bridge = this.fg_sprites.members[0];
bridge.immovable = true;
this.player_separate(bridge);


if (this.s1 == -1) {
	
	bridge.animation.play("broken");
	this.s1 = -2;
	return;
} else if (this.s1 == -2) {
	return;
}

if (this.s1 == 0) {
	if (R.player.overlaps(this.trigger)) {
		this.s1 = 1;
		//R.player.change_vistype(0, 0); // force armor aliph
		//R.set_flag(6, false);
		this.set_scene_state("intro", "earthquake", 1, 1);	
	} else {
		return;
	}
} 


var lightning = this.fg_sprites.members[1];



if (this.s1 == 1) {
	if (this.player_freeze_help()) {
		
		if (0 == this.get_ss("intro","message",1)) {
			R.player.change_vistype(0, 0); // force armor aliph
			R.player.y -= 16;
		}
		
		R.player.enter_cutscene();
		R.player.pause_toggle(false);
		R.player.animation.play("wrr");
		R.player.velocity.x = 70;
		this.s1 = 1000;
		
	}
} else if (this.s1 == 1000) {
	if (R.player.x > this.trigger.x + 52) {
		R.player.x = this.trigger.x + 52;
		R.player.velocity.x = 0;
		R.player.animation.play("irn");
		this.dialogue("intro", "earthquake", 0,false); 
		this.s1 = 2;
		R.player.enter_cutscene();
	}
} else if (this.s1 == 2) {
	if (!this.dialogue_is_on()) { 
		this.s1 = 3;
		// TrainTrigger ID, how long to wait, velocity, outvel? , if true then stay
		this.pan_camera(1, 0, 120, 0, true, true);
		//this.pan_camera_try_send_return();
	}
} else if (this.s1 == 3) {
	this.t_1++;
	if (this.t_1 > 90) {
		this.dialogue("intro", "earthquake", 1);
		this.energy_bar_move_set(false);
		this.s1 = 4;
		this.t_1 = 0;
		
	}
} else if (this.s1 == 4) {
	this.player_freeze_help();
	
	if (!this.dialogue_is_on()) {
		
		this.t_1 ++;
		if (this.t_1 == 60) {
			this.play_sound("checkpoint.wav");// wire off
			this.broadcast_to_children("dark_off");
		} else if (this.t_1 == 120) {
			this.acceleration.y = 40;
		}
	}
	if (this.t_1 == 360 && !this.dialogue_is_on() && this.pan_camera_try_send_return()) {
		this.s1 = 5;
		this.t_1 = 0;
	}
}else if (this.s1 == 5) { // aliph runs right off bridge
	this.t_1++;
	if (this.t_1 > 150) {
		R.player.pause_toggle(false);
		R.player.animation.play("wrn");
		R.player.velocity.x = 50;
		
		this.s1 = 6;
		this.t_1 = 0;
	}
} else if (this.s1 == 6) {
	this.t_1 ++;
	if (this.t_1 > 42) {
		//this.t_1 = 0;
		if (this.t_1 == 43) {
			this.play_sound("lightning_hi.wav");
			R.sound_manager.accessibility_str = R.dialogue_manager.lookup_sentence("ui", "sound_labels", 1);
			this.set_vars(lightning, lightning.x, lightning.y, 1, true);
			bridge.animation.play("broken");
			
			R.player.velocity.x = 0;
			
			
			for (i in [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26]) {
				this.make_child("n/a", false, "n/a", true, 0xffffbbff);
				
				this.fg_sprites.members[i + 2].velocity.x = -9+18*this.random();
				this.fg_sprites.members[i + 2].velocity.y = -10-20*this.random();
				if (i < 9) {
					this.fg_sprites.members[i + 2].move(bridge.x +16 +this.random() * 3, bridge.y+12	);
				} else if (i < 18) {
					this.fg_sprites.members[i + 2].move(bridge.x -16 + bridge.width + this.random() * 3, bridge.y+12);
				} else {
					this.fg_sprites.members[i + 2].move(R.player.x+4+3*this.random(),R.player.y+10+4*this.random());
				}
				this.fg_sprites.members[i + 2].alpha = 1;
				this.fg_sprites.members[i + 2].exists = true;
				this.fg_sprites.members[i + 2].acceleration.y = 25 / 5;
				
			}
			
			
		R.player.enter_cutscene();
		R.player.pause_toggle(false);
			R.player.animation.play("slump");
			this.shake(0.0045, 4.5);
		}
		lightning.alpha -= (1/290);
		if (this.t_1 == 280) {
			this.shake(0.003,1.3);
			bridge.acceleration.y = 10;
			this.s1 = 7;
			R.TEST_STATE.cutscene_handle_signal(0, [0.0034, 0xffffffff], true); 
			R.TEST_STATE.cutscene_handle_signal(5); // Put dialogue box on top
		}
	}
} else if (this.s1 == 7) {
	R.player.y = bridge.y - R.player.height;
	if (R.TEST_STATE.cutscene_just_finished(0)) {
		bridge.acceleration.y = bridge.velocity.y = 0;
		this.play_sound("bridgefall.wav");
		this.s1 = 8;
		this.t_1 = 0;
	}
} else if (this.s1 == 8) {
	// wait for sound to end
	this.t_1 ++;
	if (this.t_1 == 100) R.song_helper.fade_to_this_song("null", false);
	if (this.t_1 > 420) {
		this.t_1 = 0;
		this.s1 = 9;
		
		R.set_flag(6, true);
		R.player.change_vistype(0, 1); 
		this.change_map("ROUGE_4", 14,27, true);
		R.TEST_STATE.skip_fade_lighten = true;

	}
}


//
//right so i think this sort of makes sense: C gets hit by lightning, suit weakened, C falls into wire which further hurts her and suit. eventually wire burns out and C falls to the ground, dead.
//Aliph's gets hit by lightning as well, suit weakened. falls to the ground and suit breaks
//but since the wire is gone Aliph doesn't die



