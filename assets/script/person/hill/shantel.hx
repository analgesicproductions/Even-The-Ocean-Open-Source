if (this.s1 == 0) {
	if (this.get_scene_state("hill", "wilbert", 1) == 0) {
		this.s1 = 1;
	} else {
		this.s1 = 2;
	}
} else if (this.s1 == 1) {
	if (this.try_to_talk()) {
		if (this.get_scene_state("hill", "shantel", 1) == 0) {
			this.dialogue("hill", "shantel", 4); 
		} else {
			this.dialogue("hill", "shantel", 0);
		}
	}
} else if (this.s1 == 2) {
	if (this.try_to_talk()) {
		this.dialogue("hill", "shantel", 0);
	}
}