// Trent in room
// Gone if room_bay talked to. does not reappear until at least one person talked to in the post-storeroom scene


if (this.s1 == 0) {
	if (this.get_scene_state("hill", "storeroom_talked", 1) == 1) { // Saw ending stuff. should be here with altenrate dialogue
		this.s1 = 3;
	} else if (this.get_scene_state("hill", "bay_in_vera_room", 1) != 0) { // Saw bay/vera cutscene. should be gone
		this.s1 = 2; 
		this.visible = false;
	} else {
		this.s1 = 1;
	}
} else if (this.s1 == 1) {
	if (this.s2 == 0) {
		if (this.try_to_talk()) {
			this.dialogue("hill", "room_trent", 0);
			this.s2 = 1;
		}
	} else if (this.s2 == 1) {
		if (!this.dialogue_is_on()) {
			this.set_scene_state("hill", "room_trent", 1, 1);
			this.s2 = 0;
		}
	}
	
	if (this.get_scene_state("hill", "bay_in_vera_room", 1) != 0) {
		this.s1 = 2;
		this.visible = false;
	}
} else if (this.s1 == 2) {
	
} else if (this.s1 == 3) {
	if (this.try_to_talk()) {
		this.dialogue("hill", "room_trent_2", 0);
	}
}