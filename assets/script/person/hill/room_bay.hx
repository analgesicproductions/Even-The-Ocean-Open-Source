
if (this.s1 == 0) {
	if (this.get_scene_state("hill", "storeroom_talked", 1) == 1) { // Saw ending stuff. should be here with altenrate dialogue
		this.s1 = 3;
	} else if (this.get_scene_state("hill", "room_bay", 1) != 0) { // talked once, stormed out
		this.s1 = 1;
		this.visible = false;
	} else {
		this.s1 = 2;
		this.has_trigger = true;
		this.make_trigger(this.x - 32, this.y-30, 20, 60);
	}
} else if (this.s1 == 1) {
	// stormed out
} else if (this.s1 == 2) {
	if (this.s2 == 0) {
		if (R.player.overlaps(this.trigger)) {
			this.s2 = 1;
		}
	} else if (this.s2 == 1){ 
		if (this.player_freeze_help()) {
			this.s2 = 2;
			this.dialogue("hill", "room_bay", 0,false);
			R.player.pause_toggle(true);

		}
	} else if (this.s2 == 2) {
		if (!this.dialogue_is_on()) {
			this.velocity.x = -45;
			this.animation.play("walk_l");
			if (this.x < R.player.x + R.player.width) {
				this.velocity.x = 0;
				this.play_anim("idle");
				this.dialogue("hill", "room_bay", 9,false);
				this.s2 = 12;
			}
		}
	} else if (this.s2 == 12) {
		// TODO bay walks over a bit
		if (!this.dialogue_is_on()) {
			this.velocity.x = 60;
			this.scale.x = -1;
			this.animation.play("walk_r");
			this.set_scene_state("hill", "room_bay", 1, 1);
			this.s2 = 13;
		}
	} else if (this.s2 == 13) {
		this.alpha -= 0.01;
		if (this.alpha <= 0) {
			this.visible = false;
			this.velocity.x = 0;
			this.dialogue("hill", "pantry", 0);
			this.s2 = 14;
		}
	} else if (this.s2 == 14 && this.doff()) {
		R.player.pause_toggle(false);
		this.s2 = 15;
	}
	
} else if (this.s1 == 3) {
	// after storeroom
	if (this.try_to_talk()) {
		this.dialogue("hill", "room_bay_2", 0);
	}
}