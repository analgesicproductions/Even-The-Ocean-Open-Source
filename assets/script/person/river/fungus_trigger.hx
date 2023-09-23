if (this.s1 == 0) {
	if (this.get_scene_state("river", "fungus_3", 1) != 0) {
		this.s1 = 1;
	} else {
		this.s1 = 2;
	} 
} else if (this.s1 == 1) {
	
} else if (this.s1 == 2) {
	if (this.nr_LIGHT_received != 0) {
		this.s1 = 1;
		this.dialogue("river", "fungus_3", 0);
		this.set_scene_state("river", "fungus_2", 2, 1);
	}
}