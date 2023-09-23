if (this.s2 == 0) {
	if (this.get_scene_state("river", "fungus_blocker", 1) != 0) {
		this.visible = false;
		return;
	}
} else if (this.s2 == 1) {
	this.alpha -= 0.005;
	return;
}



if (this.s1 == 0) {
	this.immovable = true;
	this.player_separate(this);
	if (this.try_to_talk(3,this)) {
		this.dialogue("river", "fungus_blocker", 0);
		this.s1 = 1;
	}
} else if (this.s1 == 1) {
	if (this.parent_state.dialogue_box.last_yn != -1 ){
		if (this.parent_state.dialogue_box.last_yn == 0) {
			this.s1 = 0;
		} else if (R.inventory.is_item_found(13) && this.parent_state.dialogue_box.last_yn == 1) {
			this.s1 = 2;
		} else if (R.inventory.is_item_found(15) && this.parent_state.dialogue_box.last_yn == 2) {
			this.s1 = 3;
			this.parent_state.dialogue_box.last_yn = -1;
		} else {
			this.s1 = 0;
		}
	}
} else if (this.s1 == 2) { // Used clippers - play sound, start dialogue and fade out the blocker
	if (!this.dialogue_is_on()) {
		this.t_1++;
		if (this.t_1 > 60) {
			this.t_1 = 0;
			this.dialogue("river", "fungus_blocker", 3);
			this.set_scene_state("river", "fungus_blocker", 1, 1);
			this.s2 = 1;
		}
	}
} else if (this.s1 == 3) { // used burn
	if (this.parent_state.dialogue_box.last_yn != -1) {
		if (this.parent_state.dialogue_box.last_yn == 0) {
			this.s1 = 4;
		} else {
			this.s1 = 0;
		}
	}
} else if (this.s1 == 4) {
	if (!this.dialogue_is_on()) {
		this.t_1++;
		if (this.t_1 > 60) {
			this.t_1 = 0;
			this.s2 = 1;
			this.set_scene_state("river", "fungus_blocker", 1, 1);
			this.dialogue("river", "fungus_blocker", 6);
		}
	}
}


// fungus bits = 14
//shears = 13
//matches = 15