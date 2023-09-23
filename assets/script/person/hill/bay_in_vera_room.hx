
if (R.editor.editor_active) {
	this.debug_name.visible = true;
} else {
	this.debug_name.visible = false;
}

if (this.s1 == 0) {
	this.has_trigger = true;
	this.make_trigger(this.x - 132, this.y-180, 20, 200);
	this.x += 64;
	this.scale.x = -1;
	//this.set_ss("hill", "room_bay", 1, 1);
	//this.set_ss("hill", "bay_in_vera_room", 1, 0);
	if (this.get_scene_state("hill", "bay_in_vera_room", 1) != 0 || this.get_scene_state("hill", "room_bay", 1) == 0 ) { // saw the cutscene, or didnt talk to bay yet.
		this.s1 = 1;
		this.visible = false;
	} else {
		this.s1 = 2;
	}
} else if (this.s1 == 1) {
	// saw cut scene already or didn talk to bay
	if (this.get_scene_state("hill", "bay_in_vera_room", 1) == 0 && this.get_scene_state("hill", "room_bay", 1) == 1) {
		this.s1 = 2;
		this.visible = true;
	}
} else if (this.s1 == 2) {
	if (this.s2 == 0) {
		if (R.player.overlaps(this.trigger)) {
			this.s2 = 1;
			this.visible = true;
		}
	} else if (this.s2 == 1){ 
		if (this.player_freeze_help()) {
			this.s2 = 2;
			this.dialogue("hill","bay_in_vera_room",0);
		}
	} else if (this.s2 == 2) {
		if (!this.dialogue_is_on()) {
			this.scale.x = 1;
			this.velocity.x = -100;
			this.immovable = false;
			this.velocity.y = 50;
			this.animation.play("walk_l");
			this.set_scene_state("hill", "bay_in_vera_room", 1, 1);
			this.s2 = 3;
		}
	} else if (this.s2 == 3) {
		
		this.alpha -= 0.015;
		this._minslopebump = 0;
			this.velocity.y = 50;
		this.y += (1 / 60) * this.velocity.y;
		this.separate(this);
		if (this.touching != 0) {
			this.y = this.last.y;
		}
		if (this.alpha == 0 || this.is_offscreen(this)) {
			this.visible = false;
			this.s2 = 4;
		}
	}
	
}