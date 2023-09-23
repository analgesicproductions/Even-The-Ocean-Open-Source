// Vera in room

if (this.s1 == 0) {
	if (this.get_scene_state("hill", "storeroom_talked", 1) == 1) { // Saw ending stuff. should be here with altenrate dialogue
		this.s1 = 5;
	} else if (this.get_ss("hill","bay_outside",1) == 1 && this.get_ss("hill","trent_outside",1) == 1 ) { // TODO: If both bay/trent found (should be gone)
		this.s1 = 4;
		this.visible = false;
	} else if (this.get_scene_state("hill", "bay_in_vera_room", 1) == 1) { // Saw bay/vera cutscene. Should talk about bay.
		if (this.get_scene_state("hill", "room_vera_after_bay", 1) == 1) { // Gave you the map already
			this.s1 = 3;
			//this.visible = false;
		} else { // Give you the map stuff
			this.s1 = 2;
		}
	} else { // Before bay
		this.s1 = 1;
	}
} else if (this.s1 == 1) { // havent talked to bay yet
	if (this.try_to_talk()) {
		this.dialogue("hill", "room_vera", 0);
	}
	
	if (this.get_scene_state("hill", "bay_in_vera_room", 1) == 1) {
		this.s1 = 2;
	}
} else if (this.s1 == 2) { // After bay: give you the map
	if (this.try_to_talk()) {
		this.dialogue("hill", "room_vera_after_bay", 1);
		this.set_scene_state("hill", "room_vera_after_bay", 1, 1);
		this.s1 = 3;
	}
	
} else if (this.s1 == 3 && this.doff()) { // After giving the map
	
	if (this.get_ss("hill", "bay_outside", 1) == 1 && this.get_ss("hill", "trent_outside", 1) == 1 ) {
		this.s1 = 4;
		this.visible = false;
	}
	if (this.try_to_talk()) {
		this.dialogue("hill", "room_vera_after_bay", 0);
	}
} else if (this.s1 == 4) { // At the store room (gone)
	
} else if (this.s1 == 5) { // After storeroom
	if (this.try_to_talk()) {
		this.dialogue("hill", "room_vera",1);
	}
}