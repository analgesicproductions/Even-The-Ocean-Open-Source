if (!this.child_init) {
	this.child_init = true;
	this.has_trigger = true;
	this.make_trigger(this.x - 40, this.y, 100, 32);
	
	if (this.get_scene_state("intro", "pad", 1) == 1) {
		this.s1 = -1;
		this.only_visible_in_editor = true;
		this.broadcast_to_children("off");
		this.broadcast_to_children("energize");
		return;
	} else {
		this.scale.x = -1;
		this.energy_bar_move_set(true);
	}
	//this._trace(this.width);
}

if (this.s1 == 0) {
	if (R.player.wasTouching== 0x1000 && R.player.overlaps(this.trigger)) {
		this.s1 = 1;
		R.player.change_vistype(0, 0); // force armor aliph
		this._trace("Pad scene turning intro cave off");
		R.set_flag(6, false);
	}
} else if (this.s1 == 1) {
	if (this.player_freeze_help()) {
		this.dialogue("intro", "pad", 0); // Step on the pad!
		this.s1 = 2;
		
		this.trigger.makeGraphic(16, 32, 0xffff5522);
		this.trigger.alpha = 0.7;
		this.trigger.x = this.x + 8;
		this.trigger.y = this.y;
	}
} else if (this.s1 == 2000) {
	if (this.doff()) {
		this.s1 = 2;
	}
} else if (this.s1 == 2 && this.doff()) {
	if (this.nr_ENERGIZE_received == 1) { // door risen
		this.t_1++;
		if (this.t_1 > 50) {
			this.s1 = 3;
			this.s2 = this.x;
			this.velocity.x = 70;
			this.scale.x = 1;
			this.play_anim("r");
			this.broadcast_to_children("off");
			
			R.player.activate_npc_bubble("speech_disappear");
			this.turned_on_bubble = false;
		}
	} else if (this.try_to_talk(this, 0, true)) { 
		this.dialogue("intro", "pad", 4);
		this.broadcast_to_children("off");
		this.s1 = 2000;
		return;
	}
} else if (this.s1 == 3) {
	if (this.x - this.s2 > 150) {
		this.velocity.x = 0;
		this.play_anim("idle");
		this.s1 = 4;
	}
} else if (this.s1 == 4) {
	if (this.nr_ENERGIZE_received == 2) {
		this.dialogue("intro", "pad", 2);//Great! blah blah *runs off*
		this.energy_bar_move_set(false);
		this.s1 = 5;
	}
}else if (this.s1 == 5) {
	if (!this.dialogue_is_on()) {
		this.play_anim("r");
		this.velocity.x = 80;
		this.s1 = 6;
R.player.enter_cutscene();
		R.player.pause_toggle(false); 
		R.player.animation.play("wln");
		R.player.velocity.x = -70;
		R.player.facing = 0x0010;
		this.t_1 = 0;

	}
} else if (this.s1 == 6) {
	this.t_1 ++;
	if (this.t_1 > 50) {
		this.s1 = 7;
		R.player.animation.play("irn");
		R.player.velocity.x = 0;
	}
} else if (this.s1 == 7) {
	this.player_freeze_help();
	if (this.is_offscreen(this)) {
		this.visible = false;
		this.set_scene_state("intro", "pad", 1, 1);	
		R.player.enter_main_state();
		R.player.pause_toggle(false);
		this.energy_bar_move_set(true);
		this.s1 = 8;
	}
}






