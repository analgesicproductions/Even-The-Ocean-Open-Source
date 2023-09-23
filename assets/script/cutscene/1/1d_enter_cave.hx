// after cave

if (!this.child_init) {
	R.player.shieldless_sprite = false;
	//this.set_event(23);
	if (this.event(23)) {
		
		this.broadcast_to_children("off");
		this.SCRIPT_OFF = true;
		this.only_visible_in_editor = true;
		return;
	} 
	this.child_init = true;
	this.has_trigger = true;
	this.make_trigger(this.x - 48, this.y, 96, 32);
	this.make_child("intro_armor_pile", false);
	
	
	this.make_child("aliphshield", false, "", true);
	this.fg_sprites.members[0].scrollFactor.set(0, 0);
	this.fg_sprites.members[0].alpha = 0;
	this.fg_sprites.members[0].exists = true;
	
	this.s2 = 0;
	if (this.get_scene_state("intro", "cave", 1) == 3) {
		this.s1 = 18;
		this.s2 = 0;
		return;
	} else if (this.get_scene_state("intro", "cave", 1) == 2) {
		this.s1 = 10;
		R.player.shieldless_sprite = true;
		this.play_music("cassisdead", false);
	} else if (this.get_scene_state("intro", "cave", 1) == 1) {
		R.player.shieldless_sprite = true;
		this.s1 = 4;
		this.play_music("cassisdead", false);
		this.trigger.x = 30 * 16;
		this.trigger.y = 27 * 16;
	} else {
		R.player.shieldless_sprite = true;
		this.play_music("null", false);
	}
	
	//this.s1 = 10;
}

var pile = this.sprites.members[0];
var drawing = this.fg_sprites.members[0];


if (this.s1 == 0) {
	if (R.player.overlaps(this.trigger)) {
		//this.bg_sprites.remove(drawing, true);
		this.s1 = 1;
		R.TEST_STATE.cutscene_handle_signal(5); // Put dialogue box on top
	}  
} 
if (this.s2 == 0) {
	if (this.s1 == 18) {
		
		pile.animation.play("no_shield");
	} else {
		pile.animation.play("has_shield");
	}
	pile.alpha = 1; pile.exists = true;
	pile.x = 8 * 16;
	pile.y = 22 * 16;
	this.s2 = 1;
}

if (this.s1 == 1) {
	if (this.player_freeze_help()) {
		this.dialogue("intro", "cave", 0); 
		this.s1 = 2;
	}
} else if (this.s1 == 2) {
	if (!this.dialogue_is_on()) {
		this.play_music("cassisdead",false);
		R.TEST_STATE.cutscene_handle_signal(2, [0.01]); // Fade away the fg_fade
		this.energy_bar_move_set(true);
		this.s1 = 3;
		R.player.pause_toggle(false);
		//R.set_flag(6, true);
		//R.player.change_vistype(0, 1); 
		// should actually be non-shield
	}
} else if (this.s1 == 3) {
	if (R.TEST_STATE.cutscene_just_finished(2) == true) {
		this.s1 = 4;
		R.TEST_STATE.cutscene_handle_signal(4, [0xff000000]); // make it black
		this.trigger.x = 30 * 16;
		this.trigger.y = 27 * 16;
		
		this.set_scene_state("intro", "cave", 1, 1);	
	}
} else if (this.s1 == 4) {
	if (this.try_to_talk(0, pile,true) || this.try_to_talk(0, this,true)) {
		this.s1 = 40;
		
			this.broadcast_to_children("off");
		if (R.player.overlaps(pile)) {
			this.dialogue("intro", "cave", 12, false);
			this.s1 = 11;
			this.set_ss("intro", "cave", 1, 2);
		} else {
			this.dialogue("intro", "cave", 7);
		}
	} else {
		if (R.player.overlaps(this.trigger)) {
			this.s1 = 5;
			this.trigger.x += 8;
			this.dialogue("intro", "cave", 9, false);
			R.player.animation.play("irx");
			R.player.velocity.x = 0;
		}
	}
	
} else if (this.s1 == 5 && this.doff()) {
	// TrainTrigger ID, how long to wait, velocity, outvel? , stay?, wait for ret?
	this.pan_camera(0, 0, 150, 0, true, false);
	this.s1 = 6;
} else if (this.s1 == 6 && this.pan_done()) {
	this.dialogue("intro", "cave", 10,false);
	this.s1 = 7;
} else if (this.s1 == 7 && this.doff()) {
	this.pan_camera(1, 0, 150, 0, true, false);
	this.s1 = 8;
}  else if (this.s1 == 8 && this.pan_done()) {
	this.dialogue("intro", "cave", 11);
	this.s1 = 9;
} else if (this.s1 == 9 && this.doff()) {
	this.camera_to_player(true);
	this.s1 = 10;
	this.set_ss("intro", "cave", 1, 2);
} else if (this.s1 == 10 && this.doff()) {
	if (this.try_to_talk(0, pile, true) || this.try_to_talk(0, this, true)) {
		
			this.broadcast_to_children("off");
		if (R.player.overlaps(pile)) {
			this.s1 =  11;
			this.dialogue("intro", "cave", 12,false);
		} else {
			this.dialogue("intro", "cave", 7);
		}
	} 
	
	if (R.player.overlaps(this.trigger)) {
		this.s1 = 100;
		R.player.x = this.trigger.x - R.player.width;
		R.player.velocity.x = 0;
		
	}
} else if (this.s1 == 100) {
	if (this.player_freeze_help()) {
		this.dialogue("intro", "cave", 18);
		this.s1 = 101;
	}
} else if (this.s1 == 101 && this.doff()) {
	R.player.enter_cutscene();
	R.player.velocity.x = -80;
	R.player.animation.play("wln");
	this.s1 = 102;
} else if (this.s1 == 102) {
	if (R.player.x < this.trigger.x - 16) {
		R.player.velocity.x = 0;
		R.player.animation.play("ilx");
		R.player.facing = 0x1;
		R.player.enter_main_state();
		this.s1 = 10;
	}
} else if (this.s1 == 11 && this.doff()) {
	//R.TEST_STATE.cutscene_handle_signal(0, [0.01]);
	this.s1 = 12;
} else if (this.s1 == 12) {
	this.dialogue("intro", "cave", 13,false); // if i take this, and strap this here...
	this.s1 = 13;
	// flip aliph sprite to shield having
	drawing.alpha = 0; drawing.exists = true;
	drawing.visible = true;
	drawing.scrollFactor.set(0, 0);
	//this.parent_state.add(drawing);
	this.t_1 = 0;
} else if (this.s1 == 13 && this.doff() ) {
	// aliph fixing sprite fades in - add it here? lol hack
	drawing.alpha += 0.05;
	this.t_1++;
	if (this.t_1 > 40) {
		drawing.alpha = 1;
		R.player.shieldless_sprite = false;
	pile.animation.play("no_shield");
		R.player.animation.play("irn");
		R.player.facing = 0x0010;
		this.dialogue("intro", "cave", 14, false);
		this.s1 = 14;	
	}
} else if (this.s1 == 14 && this.doff()) {
	drawing.alpha -= 0.15;
	if (drawing.alpha < 0.05) {
		drawing.alpha = 0;
		//this.parent_state.remove(drawing, true);
		//R.TEST_STATE.cutscene_handle_signal(2, [0.01]);
		this.s1 = 15;
	}
} else if (this.s1 == 15) {
	//if (R.TEST_STATE.cutscene_just_finished(2)) {
		this.dialogue("intro", "cave", 15,false);
		this.s1 = 16;
	//}
} else if (this.s1 == 16) {
	if (!this.dialogue_is_on()) { // Yes or No to seeing tutorial
		//if (this.d_last_yn() == 0) {
			this.s1 = 17;
			this.run_tutorial(2);
		//} else {
			//this.s1 = 17;
		//}
	}
} else if (this.s1 == 17) {
	if (this.tutorial_done()) {
		this.s1 = 18;
		R.player.enter_main_state();
		R.player.pause_toggle(false);
		this.energy_bar_move_set(true, false);
		R.there_is_a_cutscene_running = false;
		this.set_scene_state("intro", "cave", 1, 3);	
	}
} else if (this.s1 == 18) {
	
	if (this.try_to_talk(0, pile, true) || this.try_to_talk(0, this, true)) {
		
			this.broadcast_to_children("off");
		this.s1 = 19;
		if (R.player.overlaps(pile)) {
			this.dialogue("intro", "cave", 17);
		} else {
			this.dialogue("intro", "cave", 7);
		}
	}  
} else if (this.s1 == 19 && this.doff()) {
	this.s1 = 18;
}
 
// 32 27
if (this.s1 == 40 || this.s1 == 50) {
	if (this.doff()) {
		this.s1 = 4;
	}
}



